-- Create message_reactions table
CREATE TABLE IF NOT EXISTS message_reactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  emoji TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure one user can only react once with the same emoji per message
  UNIQUE(message_id, user_id, emoji)
);

-- Create indexes for better query performance
CREATE INDEX idx_message_reactions_message_id ON message_reactions(message_id);
CREATE INDEX idx_message_reactions_user_id ON message_reactions(user_id);
CREATE INDEX idx_message_reactions_emoji ON message_reactions(emoji);
CREATE INDEX idx_message_reactions_created_at ON message_reactions(created_at);

-- Enable Row Level Security
ALTER TABLE message_reactions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for message_reactions

-- Users can view reactions on messages they have access to
CREATE POLICY "Users can view reactions on accessible messages"
ON message_reactions FOR SELECT
USING (
  message_id IN (
    SELECT m.id FROM messages m
    INNER JOIN conversation_participants cp ON m.conversation_id = cp.conversation_id
    WHERE cp.user_id = auth.uid()
  )
);

-- Users can add reactions to messages in their conversations
CREATE POLICY "Users can add reactions to their messages"
ON message_reactions FOR INSERT
WITH CHECK (
  user_id = auth.uid() AND
  message_id IN (
    SELECT m.id FROM messages m
    INNER JOIN conversation_participants cp ON m.conversation_id = cp.conversation_id
    WHERE cp.user_id = auth.uid()
  )
);

-- Users can only delete their own reactions
CREATE POLICY "Users can delete their own reactions"
ON message_reactions FOR DELETE
USING (user_id = auth.uid());

-- Create function to get reaction counts for a message
CREATE OR REPLACE FUNCTION get_message_reaction_counts(p_message_id UUID)
RETURNS TABLE (
  emoji TEXT,
  count BIGINT,
  user_ids UUID[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mr.emoji,
    COUNT(*)::BIGINT as count,
    ARRAY_AGG(mr.user_id) as user_ids
  FROM message_reactions mr
  WHERE mr.message_id = p_message_id
  GROUP BY mr.emoji
  ORDER BY COUNT(*) DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to check if user has reacted with specific emoji
CREATE OR REPLACE FUNCTION user_has_reacted(
  p_message_id UUID,
  p_user_id UUID,
  p_emoji TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM message_reactions
    WHERE message_id = p_message_id
    AND user_id = p_user_id
    AND emoji = p_emoji
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comment to table
COMMENT ON TABLE message_reactions IS 'Stores emoji reactions for messages';
COMMENT ON COLUMN message_reactions.emoji IS 'Unicode emoji character';
