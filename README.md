# 📱 Flutter Blog App with Clean Architecture

A modern, full-stack blog application built with Flutter and Clean Architecture principles. Features user authentication, blog creation with image uploads, and real-time data synchronization using Supabase backend.


[![Live Demo](https://img.shields.io/badge/Demo-Live-brightgreen)](https://flutter-blog-app-clean.web.app)

## 🌐 Live Demo

**[View Live App](https://flutter-blog-app-clean.web.app)** | **[Firebase Console](https://console.firebase.google.com/project/flutter-blog-app-clean/overview)**

## ✨ Features

- 🔐 **User Authentication** - Secure email/password authentication with Supabase
- 📝 **Blog Management** - Create, read, update, and delete blog posts
- 🖼️ **Image Uploads** - Upload and manage blog post images
- 🎨 **Responsive Design** - Works seamlessly on web, iOS, and Android
- 💾 **Offline Support** - Local caching with Hive for offline access
- 🔄 **Real-time Sync** - Automatic data synchronization with Supabase
- 🏗️ **Clean Architecture** - Follows clean architecture principles with clear separation of concerns
- 🎯 **BLoC Pattern** - State management using BLoC (Business Logic Component)
- 🔒 **Row Level Security** - Database-level security policies with Supabase RLS

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation between layers:

```
lib/
├── core/                          # Core functionality
│   ├── common/                    # Shared widgets and cubits
│   ├── constants/                 # App-wide constants
│   ├── error/                     # Error handling
│   ├── network/                   # Network utilities
│   ├── theme/                     # App theming
│   └── utils/                     # Utility functions
│
├── features/                      # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/                  # Data layer
│   │   │   ├── datasources/       # Remote & local data sources
│   │   │   ├── models/            # Data models
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/                # Domain layer
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   └── usecases/          # Business use cases
│   │   └── presentation/          # Presentation layer
│   │       ├── bloc/              # BLoC state management
│   │       ├── pages/             # UI pages
│   │       └── widgets/           # Reusable widgets
│   │
│   └── blog/                      # Blog feature (same structure)
│
└── init_dependencies.dart         # Dependency injection setup
```

### Architecture Layers

- **Presentation Layer**: UI components, pages, and BLoC for state management
- **Domain Layer**: Business logic, entities, and use cases
- **Data Layer**: Data sources (remote/local), models, and repository implementations

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.29.2** - UI framework
- **Dart** - Programming language
- **BLoC Pattern** - State management
- **GetIt** - Dependency injection
- **Hive** - Local storage

### Backend
- **Supabase** - Backend as a Service
- **PostgreSQL** - Database
- **Row Level Security (RLS)** - Database security
- **Storage Buckets** - Image storage

### Deployment
- **Firebase Hosting** - Web deployment
- **Firebase CLI** - Deployment tools

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.29.2 or higher)
- Dart SDK
- A Supabase account
- A Firebase account (for deployment)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Bramhaaa/clean_blog_app.git
   cd clean_blog_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase**
   
   Create a new Supabase project at [supabase.com](https://supabase.com)
   
   Run the SQL scripts in your Supabase SQL Editor:
   ```bash
   # 1. Set up database tables and policies
   supabase_setup.sql
   
   # 2. Set up storage bucket
   storage_setup.sql
   
   # 3. Fix authentication and storage (if needed)
   fix_auth_and_storage.sql
   ```

4. **Configure Supabase credentials**
   
   Update `lib/core/secrets/app_secrets.dart`:
   ```dart
   class AppSecrets {
     static const supabaseUrl = 'YOUR_SUPABASE_URL';
     static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   }
   ```

5. **Disable email confirmation in Supabase**
   - Go to Authentication → Settings
   - Turn off "Confirm email"

### Running the App

```bash
# Run on web
flutter run -d chrome

# Run on iOS simulator
flutter run -d "iPhone 16 Pro"

# Run on Android emulator
flutter run -d android

# Build for production
flutter build web
flutter build apk --release
flutter build ios --release
```

## 📦 Key Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.6              # State management
  get_it: ^8.0.3                    # Dependency injection
  supabase_flutter: ^2.9.0          # Supabase client
  hive: ^2.2.3                      # Local storage
  hive_flutter: ^1.1.0              # Hive Flutter integration
  image_picker: ^1.1.2              # Image selection
  uuid: ^4.5.1                      # UUID generation
  fpdart: ^1.1.0                    # Functional programming
  internet_connection_checker_plus: ^2.5.2  # Network checking
```

## 🔧 Configuration Files

### Supabase Setup
- `supabase_setup.sql` - Database tables and RLS policies
- `storage_setup.sql` - Storage bucket configuration
- `fix_auth_and_storage.sql` - Authentication fixes

### Firebase Setup
- `firebase.json` - Firebase hosting configuration
- `.firebaserc` - Firebase project configuration

## 📱 Features Breakdown

### Authentication
- Email/password registration
- Secure login
- Automatic profile creation
- Session management
- Token-based authentication

### Blog Management
- Create new blog posts
- Add cover images
- Select topics/categories
- View all blogs
- Read individual blog posts
- Calculate reading time
- Format publish dates

### Data Persistence
- Online/offline functionality
- Automatic data caching
- Background sync
- Optimistic updates

## 🎨 UI/UX Features

- Modern gradient design
- Responsive layouts
- Custom theme
- Loading states
- Error handling
- Smooth animations
- Intuitive navigation

## 🔒 Security

- Row Level Security (RLS) policies
- Secure authentication flow
- Protected API endpoints
- Input validation
- XSS protection
- CORS configuration

## 🌐 Deployment

### Deploy to Firebase Hosting

```bash
# Build the web app
flutter build web

# Deploy to Firebase
firebase deploy

# Your app will be live at:
# https://your-project.web.app
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

## 📖 API Documentation

### Supabase Tables

**profiles**
- `id` (UUID) - User ID
- `name` (TEXT) - User name
- `created_at` (TIMESTAMP) - Profile creation time

**blogs**
- `id` (UUID) - Blog ID
- `poster_id` (UUID) - Author ID
- `title` (TEXT) - Blog title
- `content` (TEXT) - Blog content
- `image_url` (TEXT) - Cover image URL
- `topics` (TEXT[]) - Blog topics/categories
- `created_at` (TIMESTAMP) - Creation time
- `updated_at` (TIMESTAMP) - Last update time

### Storage Buckets

**blog_images**
- Public bucket for blog cover images
- 5MB file size limit
- Supports: JPEG, PNG, GIF, WebP

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Run with coverage
flutter test --coverage
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Project Structure Philosophy

This project follows **Clean Architecture** principles:

- **Independence**: Business logic is independent of frameworks and UI
- **Testability**: Business logic can be tested without UI, database, or external elements
- **UI Independence**: UI can change without changing business logic
- **Database Independence**: Can swap databases without affecting business logic
- **External Agency Independence**: Business logic doesn't depend on external agencies

## 🔍 Code Quality

- Follows Flutter best practices
- Uses dependency injection
- Implements SOLID principles
- Includes error handling
- Uses meaningful naming conventions
- Comments for complex logic

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [BLoC Pattern Documentation](https://bloclibrary.dev/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 👤 Author

**Bramha Bajannavar**

- GitHub: [@Bramhaaa](https://github.com/Bramhaaa)
- Project Link: [https://github.com/Bramhaaa/clean_blog_app](https://github.com/Bramhaaa/clean_blog_app)
- Live Demo: [https://flutter-blog-app-clean.web.app](https://flutter-blog-app-clean.web.app)
