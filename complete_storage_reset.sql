-- Complete Storage Bucket Reset and Setup for Blog App
-- This will remove existing buckets and create everything fresh
-- Run this in your Supabase SQL Editor

-- Step 1: Clean up existing storage (if any)
-- Remove all objects and policies first
DROP POLICY IF EXISTS "Allow authenticated users to upload images" ON storage.objects;
DROP POLICY IF EXISTS "Allow everyone to view images" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to update own images" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to delete own images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated upload" ON storage.objects;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON storage.objects;
DROP POLICY IF EXISTS "Enable read for all users" ON storage.objects;

-- Delete all objects in the bucket (if any)
DELETE FROM storage.objects WHERE bucket_id = 'blog_images';

-- Remove the bucket itself
DELETE FROM storage.buckets WHERE id = 'blog_images';

-- Step 2: Create fresh storage bucket
INSERT INTO storage.buckets (
    id, 
    name, 
    public, 
    file_size_limit, 
    allowed_mime_types,
    created_at,
    updated_at
) VALUES (
    'blog_images',
    'blog_images', 
    true,                                    -- Public bucket
    10485760,                               -- 10MB file size limit
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'],
    NOW(),
    NOW()
);

-- Step 3: Create storage policies

-- Policy 1: Allow authenticated users to upload/insert images
CREATE POLICY "Enable uploads for authenticated users" 
ON storage.objects 
FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'blog_images');

-- Policy 2: Allow everyone to view/select images (since bucket is public)
CREATE POLICY "Enable downloads for everyone" 
ON storage.objects 
FOR SELECT 
TO anon, authenticated 
USING (bucket_id = 'blog_images');

-- Policy 3: Allow authenticated users to update their own images
CREATE POLICY "Enable updates for users on their own images" 
ON storage.objects 
FOR UPDATE 
TO authenticated 
USING (bucket_id = 'blog_images');

-- Policy 4: Allow authenticated users to delete their own images
CREATE POLICY "Enable deletes for users on their own images" 
ON storage.objects 
FOR DELETE 
TO authenticated 
USING (bucket_id = 'blog_images');

-- Step 4: Verify the setup
-- You can run these SELECT statements to verify everything was created correctly

-- Check if bucket exists
-- SELECT * FROM storage.buckets WHERE id = 'blog_images';

-- Check policies
-- SELECT * FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname LIKE '%blog%';

-- Success message
SELECT 'Storage bucket setup completed successfully!' as status;