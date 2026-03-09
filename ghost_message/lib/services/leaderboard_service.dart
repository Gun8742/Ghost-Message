import 'package:ghost_message/models/leaderboard_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  Stream<List<LeaderboardItemModel>> streamLeaderboard({
    required String boardId,
    int limit = 20,
  }) {
    return _instance
        .collection('leaderboards')
        .doc(boardId)
        .collection('entries')
        .orderBy('count', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LeaderboardItemModel.fromMap(doc.data());
      }).toList();
    });
  }
}