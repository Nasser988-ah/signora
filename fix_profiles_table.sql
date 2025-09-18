-- Fix Profiles Table Schema
-- Run this in your Supabase SQL Editor

-- Drop existing table if it exists (to start fresh)
DROP TABLE IF EXISTS profiles CASCADE;

-- Create profiles table with all required columns
CREATE TABLE profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT NOT NULL,
    user_type TEXT NOT NULL CHECK (user_type IN ('student', 'professor')),
    bio TEXT,
    subject TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create unique index on email and user_type combination
CREATE UNIQUE INDEX idx_profiles_email_user_type ON profiles (email, user_type);

-- Create indexes for better performance
CREATE INDEX idx_profiles_user_type ON profiles (user_type);
CREATE INDEX idx_profiles_email ON profiles (email);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Allow reading professor profiles (for public display)
CREATE POLICY "Allow reading professor profiles" ON profiles
FOR SELECT
USING (user_type = 'professor');

-- Policy: Allow users to insert their own profile
CREATE POLICY "Allow users to insert own profile" ON profiles
FOR INSERT
WITH CHECK (auth.jwt() ->> 'email' = email);

-- Policy: Allow users to update their own profile
CREATE POLICY "Allow users to update own profile" ON profiles
FOR UPDATE
USING (auth.jwt() ->> 'email' = email)
WITH CHECK (auth.jwt() ->> 'email' = email);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at on profile changes
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add comments for documentation
COMMENT ON TABLE profiles IS 'User profiles containing bio and subject information';
COMMENT ON COLUMN profiles.email IS 'User email address from authentication';
COMMENT ON COLUMN profiles.user_type IS 'Type of user: student or professor';
COMMENT ON COLUMN profiles.bio IS 'User biography/about section';
COMMENT ON COLUMN profiles.subject IS 'Subject taught by professor';

-- Update lessons table to use YouTube URLs instead of video file URLs
ALTER TABLE lessons 
DROP COLUMN IF EXISTS video_url,
ADD COLUMN IF NOT EXISTS youtube_url TEXT NOT NULL DEFAULT '';

-- Update existing lessons to have empty YouTube URLs (you'll need to populate these manually)
UPDATE lessons SET youtube_url = '' WHERE youtube_url IS NULL;

-- Add index for YouTube URL searches
CREATE INDEX IF NOT EXISTS idx_lessons_youtube_url ON lessons (youtube_url);

-- Add comment for documentation
COMMENT ON COLUMN lessons.youtube_url IS 'YouTube URL for the lesson video';
