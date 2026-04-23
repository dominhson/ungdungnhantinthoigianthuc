-- Migration: Add online status to users table
-- Created: 2026-04-23
-- Description: Adds is_online and last_seen columns to users table for tracking online status

-- Add columns to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS last_seen TIMESTAMP WITH TIME ZONE;

-- Create index for online status queries
CREATE INDEX IF NOT EXISTS idx_users_is_online ON users(is_online);
CREATE INDEX IF NOT EXISTS idx_users_last_seen ON users(last_seen);

-- Update existing users to have default values
UPDATE users 
SET is_online = false, 
    last_seen = NOW() 
WHERE is_online IS NULL;
