class ReplyModel {
  final String replyId;
  final String postId;
  final String authorId;
  final String message;
  final int likeCount;
  final DateTime createdAt;

  ReplyModel({
    required this.replyId,
    required this.postId,
    required this.authorId,
    required this.message,
    this.likeCount = 0,
    required this.createdAt,
  });

  factory ReplyModel.fromMap(String documentId, Map<String, dynamic> data) {
    return ReplyModel(
      replyId: documentId,
      postId: data["post_id"] ?? "",
      authorId: data["author_id"] ?? "",
      message: data["message"] ?? "",
      likeCount: data["like_reply_count"] ?? 0,
      createdAt: data["created_at"] != null 
          ? (data["created_at"] as dynamic).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "post_id": postId,
      "author_id": authorId,
      "message": message,
      "like_reply_count": likeCount,
      "created_at": createdAt,
    };
  }
}