# Blog App Setup Requirements

This document outlines everything you need to add to make this Flutter blog app run properly.

## 1. Current Status ✅
- Supabase configuration is already set up in `lib/core/secrets/app_secrets.dart`
- Flutter dependencies are installed and working
- Clean architecture structure is properly implemented

## 2. Issues Found and Fixes Needed

### A. Platform Compatibility Issues

#### Web Platform Fix Required
The app crashes on web due to Hive database initialization using `path_provider`. 

**Fix**: Modify `lib/init_dependencies.main.dart` to handle web platform differently:

```dart
// Replace line 14 in init_dependencies.main.dart:
// Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

// With this platform-specific code:
if (!kIsWeb) {
  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;
} else {
  // For web, Hive will use IndexedDB automatically
  await Hive.initFlutter();
}
```

You'll also need to add this import at the top:
```dart
import 'package:flutter/foundation.dart';
```

#### macOS/Desktop Fix
Update dependencies to fix compatibility issues.

**Fix**: Update `pubspec.yaml` dependencies:
```yaml
dependencies:
  # ... existing dependencies
  win32: ^5.5.0  # Update to latest version
  hive: ^2.2.3   # Use stable version instead of dev version
  hive_flutter: ^1.1.0  # Add this for better web support
```

### B. Missing Assets Configuration
Add assets folder structure for images:

**Required Directory Structure:**
```
assets/
  images/
    (blog images will be uploaded to Supabase storage)
```

**Fix**: Update `pubspec.yaml` to include assets:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

### C. Supabase Database Setup Required

The app uses Supabase but you need to set up the database schema:

**Required Tables:**
1. **profiles** table (for user authentication)
2. **blogs** table (for blog posts)
3. **blog_images** storage bucket

**Supabase Setup Steps:**
1. Go to your Supabase dashboard: https://ugayfwynrapzzjuhtqio.supabase.co
2. Create the following tables:

```sql
-- Profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Blogs table  
CREATE TABLE blogs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  poster_id UUID REFERENCES profiles(id) NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  topics TEXT[] DEFAULT '{}',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE blogs ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles 
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles 
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles 
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Blogs policies
CREATE POLICY "Anyone can view blogs" ON blogs 
  FOR SELECT USING (true);

CREATE POLICY "Users can create blogs" ON blogs 
  FOR INSERT WITH CHECK (auth.uid() = poster_id);

CREATE POLICY "Users can update own blogs" ON blogs 
  FOR UPDATE USING (auth.uid() = poster_id);

CREATE POLICY "Users can delete own blogs" ON blogs 
  FOR DELETE USING (auth.uid() = poster_id);
```

3. Create storage bucket:
   - Go to Storage section
   - Create a new bucket called `blog_images`
   - Make it public for reading
   - Allow authenticated users to upload

### D. Environment Setup for Development

**Required Files to Create:**

1. **Create `.env` file** (optional, for different environments):
```env
SUPABASE_URL=https://ugayfwynrapzzjuhtqio.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnYXlmd3lucmFwenpqdWh0cWlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDkxNjU3MTAsImV4cCI6MjAyNDc0MTcxMH0._c5Jwldgjn0JQ17lOxsX_dOxUFpwtsNVnVGrgP1kRsE
```

2. **Update `.gitignore`** to include:
```
# Environment files
.env
.env.local
.env.*.local

# Supabase
.supabase/

# Additional Flutter files
*.lock
*.iml
.flutter-plugins-dependencies
```

## 3. Steps to Get App Running

### Step 1: Fix Dependencies
```bash
cd /path/to/blog-app-clean-architecture
flutter clean
flutter pub get
```

### Step 2: Apply Platform Fixes
- Update `init_dependencies.main.dart` with web platform fix
- Update `pubspec.yaml` with corrected dependencies

### Step 3: Set Up Supabase Database
- Create required tables using the SQL above
- Set up storage bucket
- Configure Row Level Security policies

### Step 4: Create Assets Folder
```bash
mkdir -p assets/images
```

### Step 5: Test the App
```bash
# For web (recommended for initial testing):
flutter run -d chrome

# For mobile:
flutter run

# For desktop (after fixing dependencies):
flutter run -d macos
```

## 4. Known Working Features

Once set up properly, the app should have:
- ✅ User registration and authentication
- ✅ User login/logout
- ✅ Create blog posts with images
- ✅ View all blog posts
- ✅ Offline storage using Hive
- ✅ Image upload to Supabase storage
- ✅ Clean architecture with BLoC pattern

## 5. Additional Recommendations

1. **Update Dependencies**: Run `flutter pub outdated` and update to latest versions
2. **Add Error Handling**: Consider adding better error handling for network issues
3. **Add Loading States**: Improve UX with loading indicators
4. **Add Pagination**: For large numbers of blog posts
5. **Add Search**: Filter blogs by title or content
6. **Add Categories**: Organize blogs by categories

## 6. Original Author Notes

This project was cloned from a GitHub repository where the original author removed:
- API keys (✅ You have working Supabase keys)
- Database schema (❌ You need to create this)
- Asset files (❌ Optional, but recommended to create structure)

The core code architecture is complete and well-structured following clean architecture principles with BLoC pattern.