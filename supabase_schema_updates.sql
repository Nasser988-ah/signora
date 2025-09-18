-- SQL Schema Updates for PDF and Audio File Support
-- Run these commands in your Supabase SQL Editor

-- 1. Add PDF and Audio URL columns to courses table
ALTER TABLE courses 
ADD COLUMN IF NOT EXISTS pdf_urls TEXT[], 
ADD COLUMN IF NOT EXISTS audio_urls TEXT[];

-- 2. Create storage buckets for course materials (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('course-materials', 'course-materials', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Create a simple policy that allows all operations (no RLS modification needed)
-- Drop existing policy if it exists, then create new one
DROP POLICY IF EXISTS "Allow all operations on course materials" ON storage.objects;
CREATE POLICY "Allow all operations on course materials"
ON storage.objects
FOR ALL
USING (bucket_id = 'course-materials');

-- 4. Make sure the bucket allows public access
UPDATE storage.buckets 
SET public = true 
WHERE id = 'course-materials';

-- 5. Create indexes for better performance (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_courses_pdf_urls ON courses USING GIN (pdf_urls);
CREATE INDEX IF NOT EXISTS idx_courses_audio_urls ON courses USING GIN (audio_urls);

-- 5. Add comments for documentation
COMMENT ON COLUMN courses.pdf_urls IS 'Array of PDF file URLs for course materials';
COMMENT ON COLUMN courses.audio_urls IS 'Array of audio file URLs for course materials';

-- 6. Update existing courses to have empty arrays (optional - prevents null issues)
UPDATE courses 
SET pdf_urls = '{}', audio_urls = '{}' 
WHERE pdf_urls IS NULL OR audio_urls IS NULL;

-- 7. Create a function to clean up orphaned files (optional utility)
CREATE OR REPLACE FUNCTION cleanup_orphaned_course_files()
RETURNS void AS $$
BEGIN
  -- This function can be used to clean up files that are no longer referenced
  -- Run periodically as maintenance
  DELETE FROM storage.objects 
  WHERE bucket_id = 'course-materials' 
  AND created_at < NOW() - INTERVAL '30 days'
  AND name NOT IN (
    SELECT unnest(pdf_urls || audio_urls) 
    FROM courses 
    WHERE pdf_urls IS NOT NULL OR audio_urls IS NOT NULL
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Grant necessary permissions
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT ALL ON storage.objects TO authenticated;
GRANT ALL ON storage.buckets TO authenticated;

-- 9. Create profiles table for professor bio and subject information
CREATE TABLE IF NOT EXISTS profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT NOT NULL,
    user_type TEXT NOT NULL CHECK (user_type IN ('student', 'professor')),
    bio TEXT,
    subject TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Create unique index on email and user_type combination
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_email_user_type 
ON profiles (email, user_type);

-- 11. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_user_type ON profiles (user_type);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles (email);

-- 12. Add RLS (Row Level Security) policies for profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all professor profiles (for public display)
CREATE POLICY "Allow reading professor profiles" ON profiles
FOR SELECT
USING (user_type = 'professor');

-- Policy: Users can only update their own profile
CREATE POLICY "Allow users to update own profile" ON profiles
FOR ALL
USING (auth.jwt() ->> 'email' = email);

-- 13. Add comments for documentation
COMMENT ON TABLE profiles IS 'User profiles containing bio and subject information';
COMMENT ON COLUMN profiles.email IS 'User email address from authentication';
COMMENT ON COLUMN profiles.user_type IS 'Type of user: student or professor';
COMMENT ON COLUMN profiles.bio IS 'User biography/about section';
COMMENT ON COLUMN profiles.subject IS 'Subject taught by professor';

-- 14. Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 15. Create trigger to automatically update updated_at on profile changes
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
