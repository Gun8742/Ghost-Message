import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ghost_message/models/user_model.dart';
import 'package:ghost_message/services/user_firestore_service.dart';

class UserProvider extends ChangeNotifier {
  List<UserModel> _allUsers = [];
  StreamSubscription? _userSubscription;
  final UserFirestoreService _userFirestoreService = UserFirestoreService();

  List<UserModel> get allUser {
    return _allUsers;
  }

  List<UserModel> get allReportedUser {

    return _allUsers.where((user) => user.reportCount > 0).toList();
  }

  UserModel? get currentUser {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _allUsers.isEmpty) return null;
    try {
      return _allUsers.firstWhere((user) => user.uid == uid);
    }
    catch(e) {
      return null;
    }
  }
  
  void initUser() {
    _userSubscription = _userFirestoreService.getUsers().listen((users) {
    _allUsers = users;

    // final authUser = FirebaseAuth.instance.currentUser;
    // if (authUser != null) {
    //   final bool userExists = users.any((u) => u.uid == authUser.uid);
    //   final creationTime = authUser.metadata.creationTime;
    //   final bool isBrandNewUser = creationTime != null &&
    //         DateTime.now().toUtc().difference(creationTime.toUtc()).inSeconds < 120;

    //   if (!userExists && !isBrandNewUser) {
    //       FirebaseAuth.instance.signOut();
    //     }
    // }
    notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}