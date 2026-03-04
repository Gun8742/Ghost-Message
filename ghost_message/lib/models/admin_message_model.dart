class AdminMessageModel {
  final String messageId;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final String type;
  final String? parentPostId;
  final int reportCount;

  AdminMessageModel({
    required this.messageId,
    required this.content,
    required this.authorId,
    required this.createdAt,
    required this.type,
    this.parentPostId,
    required this.reportCount,
  });
}