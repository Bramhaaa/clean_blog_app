import 'dart:io';

import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  });
  Future<List<BlogModel>> getAllBlogs();
}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  final SupabaseClient supabaseClient;
  BlogRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      print('DEBUG: Attempting to upload blog: ${blog.toJson()}');
      print('DEBUG: Current user ID: ${supabaseClient.auth.currentUser?.id}');

      final blogData =
          await supabaseClient.from('blogs').insert(blog.toJson()).select();

      print('DEBUG: Blog uploaded successfully: $blogData');
      return BlogModel.fromJson(blogData.first);
    } on PostgrestException catch (e) {
      print(
          'DEBUG: PostgrestException - Code: ${e.code}, Message: ${e.message}, Details: ${e.details}');
      throw ServerException('Database Error: ${e.message} (Code: ${e.code})');
    } catch (e) {
      print('DEBUG: General Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  }) async {
    try {
      await supabaseClient.storage.from('blog_images').upload(
            blog.id,
            image,
          );

      return supabaseClient.storage.from('blog_images').getPublicUrl(
            blog.id,
          );
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final blogs =
          await supabaseClient.from('blogs').select('*, profiles (name)');
      return blogs
          .map(
            (blog) => BlogModel.fromJson(blog).copyWith(
              posterName: blog['profiles']['name'],
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
