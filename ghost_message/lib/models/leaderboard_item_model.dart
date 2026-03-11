class LeaderboardItemModel {
  final String uid;
  final String name;
  final int count;

  LeaderboardItemModel({
    required this.uid,
    required this.name,
    required this.count,
  });

  factory LeaderboardItemModel.fromMap(Map<String, dynamic> map) {
    return LeaderboardItemModel(
      uid: map['uid'] ?? '',
      name: map['username'] ?? '',
      count: map['count'] ?? 0,
    );
  }
}