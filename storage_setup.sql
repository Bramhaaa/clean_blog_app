-- Storage Bucket Setup for Blog App Images
-- Run this in your Supabase SQL Editor after running the main setup

-- Create storage bucket for blog images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'blog_images',
  'blog_images', 
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Policy to allow authenticated users to upload images
CREATE POLICY "Allow authenticated users to upload images" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'blog_images');

-- Policy to allow everyone (including anonymous users) to view images
CREATE POLICY "Allow everyone to view images" ON storage.objects
FOR SELECT TO anon, authenticated
USING (bucket_id = 'blog_images');

-- Policy to allow users to update their own uploaded images
CREATE POLICY "Allow users to update own images" ON storage.objects
FOR UPDATE TO authenticated
USING (bucket_id = 'blog_images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Policy to allow users to delete their own uploaded images  
CREATE POLICY "Allow users to delete own images" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'blog_images' AND auth.uid()::text = (storage.foldername(name))[1]);