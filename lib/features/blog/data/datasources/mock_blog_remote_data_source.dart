import 'dart:io';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:blog_app/features/blog/data/datasources/blog_remote_data_source.dart';

class MockBlogRemoteDataSource implements BlogRemoteDataSource {
  final List<BlogModel> _blogs = [
    BlogModel(
      id: '1',
      posterId: 'demo-user',
      title: 'Welcome to Flutter Blog App',
      content:
          'This is a demo blog post showing the app functionality. Create your Supabase project to add real blogs!',
      imageUrl:
          'https://via.placeholder.com/600x300/4285F4/FFFFFF?text=Welcome+Post',
      topics: ['Flutter', 'Demo'],
      updatedAt: DateTime.now(),
      posterName: 'Demo User',
    ),
    BlogModel(
      id: '2',
      posterId: 'demo-user',
      title: 'Clean Architecture in Flutter',
      content:
          'This app demonstrates clean architecture principles with BLoC state management, repository pattern, and dependency injection.',
      imageUrl:
          'https://via.placeholder.com/600x300/FF5722/FFFFFF?text=Architecture+Post',
      topics: ['Architecture', 'Flutter', 'BLoC'],
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      posterName: 'Demo User',
    ),
  ];

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final newBlog = blog.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      updatedAt: DateTime.now(),
    );

    _blogs.insert(0, newBlog);
    return newBlog;
  }

  @override
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  }) async {
    // Return a placeholder image URL
    await Future.delayed(const Duration(seconds: 1));
    return 'https://via.placeholder.com/600x300/4285F4/FFFFFF?text=Blog+Image';
  }

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_blogs);
  }
}
