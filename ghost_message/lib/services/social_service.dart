import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghost_message/models/reply_model.dart';
import 'package:ghost_message/services/achievement_firestore_service.dart';

class SocialService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  Future<void> toggleLike({
    required String postId,
    required String userId,
    required String postOwnerId,
    required bool isCurrentlyLiked,
  }) async {
    final batch = _instance.batch();
    final postRef = _instance.collection("posts").doc(postId);
    final userRef = _instance.collection("users").doc(userId);

    if (isCurrentlyLiked) {
      batch.update(postRef, {
        "like_count": FieldValue.increment(-1)
      });
      batch.update(userRef, {
        "liked_posts": FieldValue.arrayRemove([postId]),
      });
    }
    else {
      batch.update(userRef, {
        "liked_posts": FieldValue.arrayUnion([postId]),
      });
      batch.update(postRef, {
        "like_count": FieldValue.increment(1)
      });
    }
    try {
      await batch.commit();
      if (!isCurrentlyLiked) {
         await AchievementFirestoreService().incrementProgress(
            uid: postOwnerId,
            type: "QUEST_GET_LIKE"
          );
      }
      else {
        await AchievementFirestoreService().decrementProgress(
            uid: postOwnerId,
            type: "QUEST_GET_LIKE"
          );
      }
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> addReply({
    required ReplyModel reply,
  }) async {
    final batch = _instance.batch();
    final replyRef = _instance.collection("posts").doc(reply.postId)
    .collection("replies").doc(reply.replyId);

    batch.set(replyRef, reply.toMap());
    
    final postRef = _instance.collection("posts").doc(reply.postId);
    batch.update(postRef, {
      "reply_count": FieldValue.increment(1),
    });

    try {
      await batch.commit();
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReply(String postId, String replyId) async {
    await _instance
        .collection('posts')
        .doc(postId)
        .collection('replies')
        .doc(replyId)
        .delete();

    await _instance.collection('posts').doc(postId).update({
      "reply_count": FieldValue.increment(-1)
    });
  }

  Future<void> toggleLikeReply({
    required String postId,
    required String replyId,
    required String userId,
    required bool isCurrentlyLiked,
  }) async {
    final batch = _instance.batch();
    final replyRef = _instance.collection("posts").doc(postId).collection("replies").doc(replyId);
    
    final userRef = _instance.collection("users").doc(userId);

    if (isCurrentlyLiked) {
      batch.update(replyRef, {"like_reply_count": FieldValue.increment(-1)});
      batch.update(userRef, {"liked_replies": FieldValue.arrayRemove([replyId])});
    } else {
      batch.update(replyRef, {"like_reply_count": FieldValue.increment(1)});
      batch.update(userRef, {"liked_replies": FieldValue.arrayUnion([replyId])});
    }

    try {
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ReplyModel>> getRepliedStream(String postId) {
    return _instance.collection("posts").doc(postId).collection("replies")
            .orderBy("like_reply_count", descending: true).snapshots()
            .map((snapshot) => 
            snapshot.docs.map((doc) => ReplyModel.fromMap(doc.id, doc.data())).toList());
  }
}