-- Emergency RLS Fix - Temporarily Disable and Debug
-- Run this to temporarily disable RLS and identify the exact issue

-- Step 1: Temporarily disable RLS to allow operations
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.blogs DISABLE ROW LEVEL SECURITY;

-- Step 2: Check if there are any existing users/profiles that might be causing issues
SELECT 
    'Current auth users:' as info,
    count(*) as user_count 
FROM auth.users;

SELECT 
    'Current profiles:' as info,
    count(*) as profile_count 
FROM public.profiles;

-- Step 3: Clean up any orphaned data that might be causing conflicts
-- Delete any profiles without corresponding auth users
DELETE FROM public.profiles 
WHERE id NOT IN (SELECT id FROM auth.users);

-- Step 4: Create a simple, permissive policy structure
-- Enable RLS back but with very permissive policies for testing

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blogs ENABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies to start fresh
DO $$ 
DECLARE
    pol RECORD;
BEGIN
    -- Drop all policies on profiles table
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'profiles' AND schemaname = 'public'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON public.profiles';
    END LOOP;
    
    -- Drop all policies on blogs table  
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'blogs' AND schemaname = 'public'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON public.blogs';
    END LOOP;
END $$;

-- Step 5: Create very simple, permissive policies for testing
-- Profiles policies - allow all operations for authenticated users
CREATE POLICY "allow_all_for_authenticated_profiles" ON public.profiles
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "allow_select_for_anon_profiles" ON public.profiles
    FOR SELECT TO anon USING (true);

-- Blogs policies - allow all operations for authenticated users  
CREATE POLICY "allow_all_for_authenticated_blogs" ON public.blogs
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "allow_select_for_anon_blogs" ON public.blogs
    FOR SELECT TO anon USING (true);

-- Step 6: Update the user creation trigger to be more robust
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Use UPSERT to handle any conflicts
    INSERT INTO public.profiles (id, name, created_at)
    VALUES (
        NEW.id, 
        COALESCE(
            NEW.raw_user_meta_data->>'name', 
            NEW.raw_user_meta_data->>'full_name',
            SPLIT_PART(NEW.email, '@', 1),
            'User'
        ),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        created_at = EXCLUDED.created_at;
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail signup
        RAISE LOG 'Profile creation error for user %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 7: Make sure trigger exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Step 8: Grant broad permissions for testing
GRANT ALL ON public.profiles TO authenticated, anon;
GRANT ALL ON public.blogs TO authenticated, anon;

SELECT 'Permissive RLS policies applied - try your app now!' as status;