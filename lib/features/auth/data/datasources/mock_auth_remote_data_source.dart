import 'package:blog_app/core/common/entities/user.dart';
import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app/features/auth/data/models/user_model.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  User? _currentUser;

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Create mock user
    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
    );

    return _currentUser as UserModel;
  }

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Create mock user for any login attempt
    _currentUser = UserModel(
      id: 'demo-user-id',
      email: email,
      name: 'Demo User',
    );

    return _currentUser as UserModel;
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return current user if logged in
    return _currentUser as UserModel?;
  }
}
