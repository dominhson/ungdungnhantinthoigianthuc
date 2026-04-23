-- Create friends table
CREATE TABLE IF NOT EXISTS friends (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, friend_id),
  CHECK (user_id != friend_id)
);

-- Create friend_requests table
CREATE TABLE IF NOT EXISTS friend_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(sender_id, receiver_id),
  CHECK (sender_id != receiver_id)
);

-- Enable RLS
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE friend_requests ENABLE ROW LEVEL SECURITY;

-- Friends policies
CREATE POLICY "Users can view their own friends"
  ON friends FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE POLICY "Users can add friends"
  ON friends FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove friends"
  ON friends FOR DELETE
  USING (auth.uid() = user_id);

-- Friend requests policies
CREATE POLICY "Users can view their friend requests"
  ON friend_requests FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can send friend requests"
  ON friend_requests FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update received friend requests"
  ON friend_requests FOR UPDATE
  USING (auth.uid() = receiver_id);

CREATE POLICY "Users can delete their sent friend requests"
  ON friend_requests FOR DELETE
  USING (auth.uid() = sender_id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_friends_user_id ON friends(user_id);
CREATE INDEX IF NOT EXISTS idx_friends_friend_id ON friends(friend_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_sender_id ON friend_requests(sender_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_receiver_id ON friend_requests(receiver_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_status ON friend_requests(status);

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
$$ LANGUAGE plpgsql;

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
$$ LANGUAGE plpgsql;
