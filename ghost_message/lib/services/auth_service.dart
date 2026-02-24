import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
      print("Start to signup");
    try {
      print("wait for create account");
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      print("Done");
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

  Future<void> updateEmail(String newEmail) async {
    try {
      final userAuth = _auth.currentUser;
      if (userAuth != null) {
        await userAuth.verifyBeforeUpdateEmail(newEmail);
      }
    }
    on FirebaseAuthException catch(e) {
      print(e);
    }

  }

  Future<void> updatePassword(BuildContext context, String oldPassword, String newPassword) async {
    final l = Provider.of<L>(context);
    final userAuth = FirebaseAuth.instance.currentUser;
    if (userAuth != null && userAuth.email != null) {
      
      AuthCredential credential = EmailAuthProvider.credential(
        email: userAuth.email!,
        password: oldPassword,
      );

      await userAuth.reauthenticateWithCredential(credential);
      
      await userAuth.updatePassword(newPassword);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.passwordChanged)),);
      }
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }

}