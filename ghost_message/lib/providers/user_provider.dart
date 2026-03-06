import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String getUsernameById(String uid) {
    try {
        final user = allUser.firstWhere((user) => user.uid == uid);
        return user.username;
      } 
    catch (e) {
      return "Anonymous";
    }
  }

  String? getPhotoPath(String uid) {
      try {
        final user = allUser.firstWhere((u) => u.uid == uid);
        return user.photoPath; 
      } catch (e) {
        return null;
      }
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

  Future<void> removeInvalidLikedItem(String id, bool isPost) async {
  if (currentUser == null) return;

  if (isPost) {
    currentUser!.likedPosts.remove(id);
  } else {
    currentUser!.likedReplies.remove(id);
  }

  await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser!.uid)
      .update({
    isPost ? "liked_posts" : "liked_replies": 
        FieldValue.arrayRemove([id])
  });

  notifyListeners();
}
  
  Future<void> initUser() async {
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

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _userFirestoreService.updateLastActive(currentUser.uid);
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}