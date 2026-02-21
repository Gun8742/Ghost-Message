import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
      // print(0);
    try {
      // print(1);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // print(2);
      return userCredential.user;
    }
    on FirebaseAuthException catch(e) {
      print(e);
      rethrow;
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try { 
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    }
    on FirebaseException catch(e) {
      throw e.message ?? "Sign in failed";
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }

}