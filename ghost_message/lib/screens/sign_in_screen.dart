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
          final user = state.credential.user;
          if (user != null) {
            String defaultUsername = "Ghost User";
            if (user.displayName != null && user.displayName!.isNotEmpty) {
              defaultUsername = user.displayName!;
            } 
            else if (user.email != null) {
              defaultUsername = user.email!.split('@')[0];
            }
            await userFirestoreService.setupInitialUser(uid: user.uid, username: defaultUsername, email: user.email ?? "");
            await achievementFirestoreService.setupInitialAchievement(user.uid);
          }
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, "/main-wrapper");
          }
        }),
        AuthStateChangeAction<SignedIn> ((context, state) {
          Navigator.pushReplacementNamed(context, "/main-wrapper");
        })
      ],
    );
  }
}