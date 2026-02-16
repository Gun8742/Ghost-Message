import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:ghost_message/services/achievement_firestore_service.dart';
import 'package:ghost_message/services/user_firestore_service.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserFirestoreService userFirestoreService = UserFirestoreService();
    final AchievementFirestoreService achievementFirestoreService = AchievementFirestoreService();
    return SignInScreen(
      providers: [
        EmailAuthProvider()
      ],
      actions: [
        AuthStateChangeAction<UserCreated> ((context, state) async {
          
          print("0");
          final user = state.credential.user;
          if (user != null) {
            String defaultUsername = "Ghost User";
            try {
              print("1");
              await userFirestoreService.setupInitialUser(uid: user.uid, username: defaultUsername, email: user.email ?? "");
              print("2");
              await achievementFirestoreService.setupInitialAchievement(user.uid);
              print("3");
            }
            catch(e) {
              print("Database Setup Error: $e");
            }
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, "/main-wrapper");
            }
          }
        }),
      ],
    );
  }
}