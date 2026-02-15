import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? photoPath;
  final String role;
  final int level;
  final bool isDarkMode;
  final String language;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel ({
    required this.uid,
    required this.email,
    required this.username,
    this.photoPath,
    this.role = "user",
    this.level = 1,
    this.isDarkMode = false,
    this.language = "eng",
    required this.createdAt,
    required this.lastActive
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data["email"] ?? "",
      username: data["username"] ?? "Anonymous",
      photoPath: data["photo_path"],
      role: data["role"] ?? "user",
      level: data["level"] ?? 1,
      isDarkMode: data["is_dark_mode"] ?? false,
      language: data["language"] ?? "eng",
      createdAt: (data["created_at"] as Timestamp).toDate(),
      lastActive: (data["last_active"] as Timestamp).toDate()
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'photo_path': photoPath,
      'role': role,
      'level': level,
      'is_dark_mode': isDarkMode,
      'language': language,
      'created_at': Timestamp.fromDate(createdAt),
      'last_active': FieldValue.serverTimestamp(),
    };
  }
}
