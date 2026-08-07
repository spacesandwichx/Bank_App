import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<UserEntity?> authStateChanges() => _remote.authStateChanges();

  @override
  UserEntity? get currentUser => _remote.currentUser;

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _remote.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.code));
    } catch (_) {
      throw const UnexpectedFailure('Something went wrong. Please try again.');
    }
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      return await _remote.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.code));
    } catch (_) {
      throw const UnexpectedFailure('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> signOut() => _remote.signOut();

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
