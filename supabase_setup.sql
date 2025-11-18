-- Supabase Database Setup for Blog App
-- Run these SQL commands in your Supabase SQL Editor

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table for user data
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create blogs table for blog posts
CREATE TABLE IF NOT EXISTS public.blogs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    poster_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    topics TEXT[] DEFAULT '{}',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blogs ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Anyone can view blogs" ON public.blogs;
DROP POLICY IF EXISTS "Users can create blogs" ON public.blogs;
DROP POLICY IF EXISTS "Users can update own blogs" ON public.blogs;
DROP POLICY IF EXISTS "Users can delete own blogs" ON public.blogs;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles 
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles 
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles 
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Blogs policies
CREATE POLICY "Anyone can view blogs" ON public.blogs 
    FOR SELECT USING (true);

CREATE POLICY "Users can create blogs" ON public.blogs 
    FOR INSERT WITH CHECK (auth.uid() = poster_id);

CREATE POLICY "Users can update own blogs" ON public.blogs 
    FOR UPDATE USING (auth.uid() = poster_id);

CREATE POLICY "Users can delete own blogs" ON public.blogs 
    FOR DELETE USING (auth.uid() = poster_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_blogs_poster_id ON public.blogs(poster_id);
CREATE INDEX IF NOT EXISTS idx_blogs_created_at ON public.blogs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_blogs_title ON public.blogs USING gin(to_tsvector('english', title));

-- Function to automatically create profile when user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, name)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'name', NEW.email));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically create profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.blogs TO authenticated;
GRANT SELECT ON public.profiles TO anon;
GRANT SELECT ON public.blogs TO anon;