import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._auth);

  final FirebaseAuth _auth;

  Stream<UserModel?> authStateChanges() {
    return _auth
        .authStateChanges()
        .map((user) => user == null ? null : UserModel.fromFirebase(user));
  }

  UserModel? get currentUser {
    final u = _auth.currentUser;
    return u == null ? null : UserModel.fromFirebase(u);
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserModel.fromFirebase(credential.user!);
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user!.updateDisplayName(displayName);
    }
    return UserModel.fromFirebase(credential.user!);
  }

  Future<void> signOut() => _auth.signOut();
}
