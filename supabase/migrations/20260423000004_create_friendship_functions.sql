-- Migration: Create functions for friendship management
-- Created: 2026-04-23
-- Description: Creates functions and triggers for automatic friendship creation and friend suggestions

-- Create trigger for friend_requests updated_at
CREATE TRIGGER update_friend_requests_updated_at
  BEFORE UPDATE ON friend_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to automatically create bidirectional friendship
CREATE OR REPLACE FUNCTION create_bidirectional_friendship()
RETURNS TRIGGER AS $$
BEGIN
  -- When a friend request is accepted, create friendship entries for both users
  IF NEW.status = 'accepted' AND OLD.status = 'pending' THEN
    -- Add friendship from sender to receiver
    INSERT INTO friends (user_id, friend_id)
    VALUES (NEW.sender_id, NEW.receiver_id)
    ON CONFLICT (user_id, friend_id) DO NOTHING;
    
    -- Add friendship from receiver to sender
    INSERT INTO friends (user_id, friend_id)
    VALUES (NEW.receiver_id, NEW.sender_id)
    ON CONFLICT (user_id, friend_id) DO NOTHING;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic friendship creation
CREATE TRIGGER on_friend_request_accepted
  AFTER UPDATE ON friend_requests
  FOR EACH ROW
  EXECUTE FUNCTION create_bidirectional_friendship();

-- Function to get friend suggestions based on mutual friends
CREATE OR REPLACE FUNCTION get_friend_suggestions(current_user_id UUID, limit_count INT DEFAULT 10)
RETURNS TABLE (
  user_id UUID,
  full_name TEXT,
  email TEXT,
  avatar_url TEXT,
  bio TEXT,
  is_online BOOLEAN,
  mutual_friends_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.full_name,
    u.email,
    u.avatar_url,
    u.bio,
    u.is_online,
    COUNT(DISTINCT f2.friend_id) as mutual_friends_count
  FROM users u
  LEFT JOIN friends f1 ON f1.user_id = current_user_id
  LEFT JOIN friends f2 ON f2.user_id = f1.friend_id AND f2.friend_id = u.id
  WHERE u.id != current_user_id
    AND u.id NOT IN (
      SELECT friend_id FROM friends WHERE user_id = current_user_id
    )
    AND u.id NOT IN (
      SELECT receiver_id FROM friend_requests 
      WHERE sender_id = current_user_id AND status = 'pending'
    )
    AND u.id NOT IN (
      SELECT sender_id FROM friend_requests 
      WHERE receiver_id = current_user_id AND status = 'pending'
    )
  GROUP BY u.id, u.full_name, u.email, u.avatar_url, u.bio, u.is_online
  ORDER BY mutual_friends_count DESC, u.created_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comments
COMMENT ON FUNCTION create_bidirectional_friendship() IS 'Automatically creates bidirectional friendship when friend request is accepted';
COMMENT ON FUNCTION get_friend_suggestions(UUID, INT) IS 'Returns friend suggestions based on mutual friends count';
