-- Fix Authentication and Storage Issues
-- Run this in your Supabase SQL Editor

-- Step 1: WORK AROUND EMAIL CONFIRMATION (since auth.config doesn't exist)
-- Let's see what tables we actually have in the auth schema
SELECT 'Auth schema tables:' as info;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'auth' 
ORDER BY table_name;

-- Check current users and their confirmation status
SELECT 'Current users:' as info;
SELECT 
    email, 
    confirmed_at, 
    email_confirmed_at,
    created_at,
    CASE 
        WHEN confirmed_at IS NOT NULL THEN 'CONFIRMED'
        ELSE 'NOT CONFIRMED' 
    END as status
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 10;

-- Auto-confirm all existing unconfirmed users (only update email_confirmed_at)
-- confirmed_at is a generated column, so we only update email_confirmed_at
UPDATE auth.users 
SET email_confirmed_at = COALESCE(email_confirmed_at, NOW())
WHERE email_confirmed_at IS NULL;

SELECT 'Auto-confirmed all unconfirmed users!' as result;

-- Step 2: Completely disable RLS temporarily for debugging
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.blogs DISABLE ROW LEVEL SECURITY;

-- Step 3: Check current users and clean up
SELECT 'Current users:' as info, email, confirmed_at, email_confirmed_at 
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 5;

-- Step 4: Enable sign-ups without confirmation
-- This SQL won't work directly, you need to do this in the dashboard:
-- Go to Authentication > Settings > Enable email confirmations = OFF

-- Step 5: Verify storage bucket permissions
SELECT 
    id, 
    name, 
    public, 
    file_size_limit,
    allowed_mime_types
FROM storage.buckets 
WHERE id = 'blog_images';

-- Step 6: Check storage policies
SELECT 
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
AND policyname LIKE '%blog%';

-- Step 7: Completely open storage permissions for testing
DROP POLICY IF EXISTS "Enable uploads for authenticated users" ON storage.objects;
DROP POLICY IF EXISTS "Enable downloads for everyone" ON storage.objects;
DROP POLICY IF EXISTS "allow_all_storage_operations" ON storage.objects;

-- Create super permissive storage policies
CREATE POLICY "allow_all_storage_operations" ON storage.objects
    FOR ALL 
    TO anon, authenticated 
    USING (bucket_id = 'blog_images') 
    WITH CHECK (bucket_id = 'blog_images');

SELECT 'Authentication and storage debugging setup complete!' as status;

-- Step 8: Instructions for manual fixes in dashboard
SELECT '1. Go to Authentication > Settings' as step, 'Disable email confirmations' as action
UNION ALL
SELECT '2. Go to Authentication > Settings' as step, 'Set Site URL to: http://localhost:3000' as action  
UNION ALL
SELECT '3. Go to Authentication > Settings' as step, 'Add redirect URL: http://localhost:3000' as action
UNION ALL
SELECT '4. Test creating a new user account' as step, 'Should work without email confirmation' as action;