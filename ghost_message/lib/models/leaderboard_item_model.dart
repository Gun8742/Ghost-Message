class LeaderboardItemModel {
  final String uid;
  final String name;
  final String photoPath;
  final int count;

  LeaderboardItemModel({
    required this.uid,
    required this.name,
    required this.photoPath,
    required this.count,
  });

  factory LeaderboardItemModel.fromMap(Map<String, dynamic> map) {
    return LeaderboardItemModel(
      uid: map['uid'] ?? '',
      name: map['username'] ?? '',
      photoPath: map['photo_path'] ?? '',
      count: map['count'] ?? 0,
    );
  }
}