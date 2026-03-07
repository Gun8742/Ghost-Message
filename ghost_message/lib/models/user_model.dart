import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? photoPath;
  final String role;
  final int level;
  final int exp;
  final bool isDarkMode;
  final String language;
  final DateTime createdAt;
  final DateTime lastActive;
  final int reportCount;
  final List<String> likedPosts;
  final List<String> likedReplies;
  final bool isSuspended;
  final bool isNotificationEnabled;
  final bool isNearbyChatEnabled;
  final bool isLocationEnabled;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.photoPath,
    this.role = "user",
    this.level = 1,
    this.exp = 0,
    this.isDarkMode = false,
    this.language = "eng",
    required this.createdAt,
    required this.lastActive,
    this.reportCount = 0,
    this.likedPosts = const [],
    this.likedReplies = const [],
    this.isSuspended = false,
    this.isLocationEnabled = true,
    this.isNearbyChatEnabled = true,
    this.isNotificationEnabled = true,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data["email"] ?? "",
      username: data["username"] ?? "Anonymous",
      photoPath: data["photo_path"],
      role: data["role"] ?? "user",
      level: data["level"] ?? 1,
      exp: data["exp"] ?? 0,
      isDarkMode: data["is_dark_mode"] ?? false,
      language: data["language"] ?? "eng",
      createdAt:
          data["created_at"] != null
              ? (data["created_at"] as Timestamp).toDate()
              : DateTime.now(),
      lastActive:
          data['last_active'] != null
              ? (data['last_active'] as Timestamp).toDate()
              : DateTime.now(),
      reportCount: data["report_count"] ?? 0,
      likedPosts: List<String>.from(data["liked_posts"] ?? []),
      likedReplies: List<String>.from(data["liked_replies"] ?? []),
      isSuspended: data["is_suspended"] ?? false,
      isLocationEnabled: data["is_location_enabled"] ?? true,
      isNearbyChatEnabled: data["is_nearby_chat_enabled"] ?? true,
      isNotificationEnabled: data["is_notification_enabled"] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "username": username,
      "photo_path": photoPath,
      "role": role,
      "level": level,
      "exp": exp,
      "is_dark_mode": isDarkMode,
      "language": language,
      "created_at": Timestamp.fromDate(createdAt),
      "last_active": FieldValue.serverTimestamp(),
      "report_count": reportCount,
      "liked_posts": likedPosts,
      "liked_replies": likedReplies,
      "is_suspended": isSuspended,
      "is_notification_enabled": isNotificationEnabled,
      "is_nearby_chat_enabled": isNearbyChatEnabled,
      "is_location_enabled": isLocationEnabled,
    };
  }

  UserModel copyWith({
    bool? isNotificationEnabled,
    bool? isNearbyChatEnabled,
    bool? isLocationEnabled,
    int? level,
    int? exp,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username,
      photoPath: photoPath,
      role: role,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      isDarkMode: isDarkMode,
      language: language,
      createdAt: createdAt,
      lastActive: lastActive,
      reportCount: reportCount,
      likedPosts: likedPosts,
      likedReplies: likedReplies,
      isSuspended: isSuspended,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      isNearbyChatEnabled: isNearbyChatEnabled ?? this.isNearbyChatEnabled,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
    );
  }
}
