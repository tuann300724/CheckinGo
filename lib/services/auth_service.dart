import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirestoreService? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirestoreService();

  final FirebaseAuth _auth;
  final FirestoreService _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return _firestore.getUser(user.uid);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return;

    final username = '@${name.toLowerCase().replaceAll(' ', '_')}';
    await _firestore.createUser(
      UserModel(
        id: user.uid,
        name: name,
        username: username,
        avatarUrl:
            'https://ui-avatars.com/api/?background=FF6B1A&color=fff&name=${Uri.encodeComponent(name)}',
      ),
    );
  }

  Future<void> signOut() => _auth.signOut();
}
