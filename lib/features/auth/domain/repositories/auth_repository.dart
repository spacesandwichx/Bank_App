import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();

  UserEntity? get currentUser;

  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();
}
