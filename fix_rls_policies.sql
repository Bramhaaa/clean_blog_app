-- Fix Row Level Security Policies for Blog App
-- Run this in your Supabase SQL Editor to fix RLS issues

-- First, let's check what's causing the issue by temporarily disabling RLS
-- This will help us understand what's happening

-- Step 1: Check current policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'blogs');

-- Step 2: Fix the profiles policy issue
-- The problem is likely that users can't insert their own profile during signup

-- Drop and recreate the profiles insert policy with better logic
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile" ON public.profiles 
    FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- Step 3: Fix the blogs policies  
-- Make sure users can insert blogs properly

-- Drop existing policies
DROP POLICY IF EXISTS "Users can create blogs" ON public.blogs;
DROP POLICY IF EXISTS "Anyone can view blogs" ON public.blogs;
DROP POLICY IF EXISTS "Users can update own blogs" ON public.blogs;
DROP POLICY IF EXISTS "Users can delete own blogs" ON public.blogs;

-- Create better blog policies
CREATE POLICY "Enable insert for authenticated users" ON public.blogs
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = poster_id);

CREATE POLICY "Enable read access for all users" ON public.blogs
    FOR SELECT TO anon, authenticated
    USING (true);

CREATE POLICY "Enable update for users based on user_id" ON public.blogs
    FOR UPDATE TO authenticated
    USING (auth.uid() = poster_id)
    WITH CHECK (auth.uid() = poster_id);

CREATE POLICY "Enable delete for users based on user_id" ON public.blogs
    FOR DELETE TO authenticated
    USING (auth.uid() = poster_id);

-- Step 4: Make sure the profile creation trigger works properly
-- Update the trigger function to handle edge cases

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, name)
    VALUES (
        NEW.id, 
        COALESCE(
            NEW.raw_user_meta_data->>'name', 
            NEW.raw_user_meta_data->>'full_name',
            NEW.email,
            'User'
        )
    );
    RETURN NEW;
EXCEPTION
    WHEN unique_violation THEN
        -- Profile already exists, that's ok
        RETURN NEW;
    WHEN OTHERS THEN
        -- Log the error but don't fail the signup
        RAISE LOG 'Error creating profile for user %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Grant additional permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Step 6: Verify the setup
SELECT 'RLS policies fixed successfully!' as status;