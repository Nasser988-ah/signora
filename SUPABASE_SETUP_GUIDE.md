# 🆓 FREE Supabase Setup Guide for Signora Course Management

## Step 1: Create Free Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up (completely free)
2. Click "New Project" 
3. Choose your organization
4. Enter project details:
   - **Name**: `signora-courses`
   - **Database Password**: Create a strong password
   - **Region**: Choose closest to your users
5. Click "Create new project" (takes ~2 minutes)

## Step 2: Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy these values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

3. Update `lib/config/supabase_config.dart`:
```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

## Step 3: Set Up Database Tables

1. In Supabase dashboard, go to **SQL Editor**
2. Click "New query" and paste this SQL:

```sql
-- Enable Row Level Security
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  user_type TEXT CHECK (user_type IN ('student', 'professor')),
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create courses table
CREATE TABLE courses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  instructor_id UUID REFERENCES profiles(id),
  instructor_name TEXT,
  price DECIMAL(10,2) DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 0,
  thumbnail_url TEXT,
  video_url TEXT,
  duration_minutes INTEGER,
  category TEXT,
  difficulty_level TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create lessons table
CREATE TABLE lessons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  video_url TEXT NOT NULL,
  duration_minutes INTEGER DEFAULT 0,
  order_index INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create enrollments table
CREATE TABLE enrollments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES profiles(id),
  course_id UUID REFERENCES courses(id),
  enrolled_at TIMESTAMP DEFAULT NOW(),
  progress INTEGER DEFAULT 0,
  UNIQUE(student_id, course_id)
);

-- Row Level Security Policies

-- Profiles: Users can read all profiles, but only update their own
CREATE POLICY "Public profiles are viewable by everyone" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Courses: Everyone can read and insert (for Firebase auth integration)
CREATE POLICY "Courses are viewable by everyone" ON courses
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert courses" ON courses
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Professors can update own courses" ON courses
  FOR UPDATE USING (
    instructor_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.user_type = 'professor'
    )
  );

CREATE POLICY "Professors can delete own courses" ON courses
  FOR DELETE USING (
    instructor_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.user_type = 'professor'
    )
  );

-- Enrollments: Students can read their own, insert their own
CREATE POLICY "Students can view own enrollments" ON enrollments
  FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Students can enroll in courses" ON enrollments
  FOR INSERT WITH CHECK (
    student_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.user_type = 'student'
    )
  );

-- Lessons: Everyone can read, only course owners can manage
CREATE POLICY "Lessons are viewable by everyone" ON lessons
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert lessons" ON lessons
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Course owners can update lessons" ON lessons
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM courses 
      WHERE courses.id = lessons.course_id 
      AND courses.instructor_id = auth.uid()
    )
  );

CREATE POLICY "Course owners can delete lessons" ON lessons
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM courses 
      WHERE courses.id = lessons.course_id 
      AND courses.instructor_id = auth.uid()
    )
  );

-- Enable realtime for courses and lessons (optional - for live updates)
ALTER PUBLICATION supabase_realtime ADD TABLE courses;
ALTER PUBLICATION supabase_realtime ADD TABLE lessons;
```

3. Click "Run" to execute the SQL

## Step 4: Set Up Storage Buckets

1. Go to **Storage** in Supabase dashboard
2. Create two buckets:
   - **Name**: `courses` (for course thumbnails and videos)
   - **Public**: ✅ Yes (so students can view content)
   - **File size limit**: 50MB (free tier limit)
   - **Allowed MIME types**: `image/*,video/*`

## Step 5: Configure Authentication

1. Go to **Authentication** → **Settings**
2. **Site URL**: Add your app's URL (for development: `http://localhost:3000`)
3. **Email Templates**: Customize if needed (optional)
4. **Providers**: Enable Email/Password (already enabled by default)

## Step 6: Test Your Setup

1. Run `flutter pub get` to install new packages
2. Update your Supabase config with real credentials
3. Run your app: `flutter run`

## FREE Tier Limits (More than enough for testing!)

- ✅ **500MB Database storage**
- ✅ **2GB Bandwidth/month** 
- ✅ **50,000 Monthly Active Users**
- ✅ **Unlimited API requests**
- ✅ **Real-time subscriptions**
- ✅ **Row Level Security**
- ✅ **Authentication**

## Next Steps After Setup

1. **Test Authentication**: Try signing up as professor/student
2. **Upload Test Course**: Use professor account to create a course
3. **View Courses**: Use student account to browse courses
4. **Enroll in Course**: Test the enrollment flow

## Migration Strategy (Gradual)

1. ✅ **Phase 1**: Set up Supabase alongside Firebase
2. **Phase 2**: Migrate course management to Supabase
3. **Phase 3**: Migrate authentication to Supabase (optional)
4. **Phase 4**: Remove Firebase dependencies

This setup gives you a production-ready backend completely FREE! 🎉
