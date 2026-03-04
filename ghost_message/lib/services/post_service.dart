import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghost_message/models/post_model.dart';
import 'package:ghost_message/services/achievement_firestore_service.dart';

class PostService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  Future<void> createPost({
    required String authorId,
    required String message,
    required double latitude,
    required double longitude,
  }) async {
    final reference = _instance.collection("posts").doc();

    final newPost = PostModel(
      postId: reference.id,
      authorId: authorId,
      message: message,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
    );
 
   await reference.set(newPost.toMap());
   await AchievementFirestoreService().incrementProgress(
        uid: authorId, 
        type: "QUEST_SEND_MSG"
      );
  }
  Future<void> deletePost(String postId) async {
    await _instance.collection('posts').doc(postId).delete();
  }


  Stream<List<PostModel>> streamNearByPosts() {
    return _instance.collection("posts")
    .orderBy("created_at", descending: true)
    .limit(100)
    .snapshots()
    .map((snapshots) => snapshots.docs
    .map((doc) => PostModel.fromMap(doc.id, doc.data())).toList());
  }
}