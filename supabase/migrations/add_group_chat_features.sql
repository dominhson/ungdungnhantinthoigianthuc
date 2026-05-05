-- Add group chat support to conversations table
ALTER TABLE conversations 
ADD COLUMN IF NOT EXISTS name VARCHAR(255),
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS is_group BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS description TEXT;

-- Add role column to conversation_participants for group admin/moderator
ALTER TABLE conversation_participants
ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member'));

-- Create group_settings table for additional group configurations
CREATE TABLE IF NOT EXISTS group_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE UNIQUE,
  only_admins_can_send BOOLEAN DEFAULT false,
  only_admins_can_add_members BOOLEAN DEFAULT false,
  only_admins_can_edit_info BOOLEAN DEFAULT false,
  allow_member_to_leave BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on group_settings
ALTER TABLE group_settings ENABLE ROW LEVEL SECURITY;

-- Group settings policies
CREATE POLICY "Users can view group settings for their conversations"
  ON group_settings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_participants.conversation_id = group_settings.conversation_id
      AND conversation_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "Group admins can update group settings"
  ON group_settings FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_participants.conversation_id = group_settings.conversation_id
      AND conversation_participants.user_id = auth.uid()
      AND conversation_participants.role = 'admin'
    )
  );

CREATE POLICY "Users can create group settings"
  ON group_settings FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_participants.conversation_id = group_settings.conversation_id
      AND conversation_participants.user_id = auth.uid()
      AND conversation_participants.role = 'admin'
    )
  );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_conversations_is_group ON conversations(is_group);
CREATE INDEX IF NOT EXISTS idx_conversations_created_by ON conversations(created_by);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_role ON conversation_participants(role);
CREATE INDEX IF NOT EXISTS idx_group_settings_conversation_id ON group_settings(conversation_id);

-- Create trigger for group_settings updated_at
CREATE TRIGGER update_group_settings_updated_at
  BEFORE UPDATE ON group_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to search users by name or email
CREATE OR REPLACE FUNCTION search_users(
  search_query TEXT,
  current_user_id UUID,
  limit_count INT DEFAULT 20
)
RETURNS TABLE (
  id UUID,
  full_name TEXT,
  email TEXT,
  avatar_url TEXT,
  bio TEXT,
  is_online BOOLEAN,
  last_seen TIMESTAMP WITH TIME ZONE
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
    u.last_seen
  FROM users u
  WHERE u.id != current_user_id
    AND (
      u.full_name ILIKE '%' || search_query || '%'
      OR u.email ILIKE '%' || search_query || '%'
    )
  ORDER BY 
    CASE 
      WHEN u.full_name ILIKE search_query || '%' THEN 1
      WHEN u.email ILIKE search_query || '%' THEN 2
      ELSE 3
    END,
    u.full_name
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to search messages in a conversation
CREATE OR REPLACE FUNCTION search_messages(
  conversation_id_param UUID,
  search_query TEXT,
  current_user_id UUID,
  limit_count INT DEFAULT 50
)
RETURNS TABLE (
  id UUID,
  conversation_id UUID,
  sender_id UUID,
  text TEXT,
  type VARCHAR(20),
  media_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  sender_name TEXT,
  sender_avatar TEXT
) AS $$
BEGIN
  -- Check if user is participant
  IF NOT EXISTS (
    SELECT 1 FROM conversation_participants
    WHERE conversation_participants.conversation_id = conversation_id_param
    AND conversation_participants.user_id = current_user_id
  ) THEN
    RAISE EXCEPTION 'User is not a participant of this conversation';
  END IF;

  RETURN QUERY
  SELECT 
    m.id,
    m.conversation_id,
    m.sender_id,
    m.text,
    m.type,
    m.media_url,
    m.created_at,
    u.full_name as sender_name,
    u.avatar_url as sender_avatar
  FROM messages m
  JOIN users u ON u.id = m.sender_id
  WHERE m.conversation_id = conversation_id_param
    AND m.text ILIKE '%' || search_query || '%'
  ORDER BY m.created_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get group members with their roles
CREATE OR REPLACE FUNCTION get_group_members(
  conversation_id_param UUID,
  current_user_id UUID
)
RETURNS TABLE (
  user_id UUID,
  full_name TEXT,
  email TEXT,
  avatar_url TEXT,
  is_online BOOLEAN,
  role VARCHAR(20),
  joined_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  -- Check if user is participant
  IF NOT EXISTS (
    SELECT 1 FROM conversation_participants
    WHERE conversation_participants.conversation_id = conversation_id_param
    AND conversation_participants.user_id = current_user_id
  ) THEN
    RAISE EXCEPTION 'User is not a participant of this conversation';
  END IF;

  RETURN QUERY
  SELECT 
    u.id as user_id,
    u.full_name,
    u.email,
    u.avatar_url,
    u.is_online,
    cp.role,
    cp.joined_at
  FROM conversation_participants cp
  JOIN users u ON u.id = cp.user_id
  WHERE cp.conversation_id = conversation_id_param
  ORDER BY 
    CASE cp.role
      WHEN 'admin' THEN 1
      WHEN 'moderator' THEN 2
      ELSE 3
    END,
    cp.joined_at;
END;
$$ LANGUAGE plpgsql;

-- Add full-text search index for messages
CREATE INDEX IF NOT EXISTS idx_messages_text_search ON messages USING gin(to_tsvector('english', text));

-- Add full-text search index for users
CREATE INDEX IF NOT EXISTS idx_users_name_search ON users USING gin(to_tsvector('english', full_name));
CREATE INDEX IF NOT EXISTS idx_users_email_search ON users(email);

COMMENT ON TABLE group_settings IS 'Settings and permissions for group conversations';
COMMENT ON FUNCTION search_users IS 'Search users by name or email with ranking';
COMMENT ON FUNCTION search_messages IS 'Search messages within a conversation';
COMMENT ON FUNCTION get_group_members IS 'Get all members of a group with their roles';
