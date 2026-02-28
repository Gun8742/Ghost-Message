import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostModel {
  final String postId;
  final String authorId;
  final String message;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final int likeCount;
  final int replyCount;
  final int reportCount;

  PostModel({
    required this.postId,
    required this.authorId,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.likeCount = 0,
    this.replyCount = 0,
    this.reportCount = 0,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory PostModel.fromMap(String documentId, Map<String, dynamic> data) {
    return PostModel(
      postId: documentId,
      authorId: data["author_id"] ?? "",
      message: data["message"] ?? "",
      latitude: (data["latitude"] as num).toDouble(),
      longitude: (data["longitude"] as num).toDouble(),
      createdAt: data["created_at"] != null 
          ? (data["created_at"] as dynamic).toDate() 
          : DateTime.now(),
      likeCount: data["like_count"] ?? 0,
      replyCount: data["reply_count"] ?? 0,
      reportCount: data["report_count"] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "author_id": authorId,
      "message": message,
      "latitude": latitude,
      "longitude": longitude,
      "created_at": createdAt,
      "like_count": likeCount,
      "reply_count": replyCount,
      "report_count": reportCount,
    };
  }
}