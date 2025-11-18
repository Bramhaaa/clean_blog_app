-- Delete blog and associated storage
-- Replace 'YOUR_BLOG_TITLE_HERE' with the actual title of your blog

-- First, find the blog you want to delete
SELECT id, title, poster_id, image_url 
FROM public.blogs 
WHERE title ILIKE '%YOUR_BLOG_TITLE_HERE%'
ORDER BY created_at DESC;

-- Delete the blog (replace 'BLOG_ID_HERE' with actual blog ID from above query)
-- DELETE FROM public.blogs WHERE id = 'BLOG_ID_HERE' AND poster_id = auth.uid();

-- Note: The image in storage will remain, you can delete it manually from Storage > blog_images