import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghost_message/models/reply_model.dart';
import 'package:ghost_message/services/achievement_firestore_service.dart';
import 'package:ghost_message/services/notification_service.dart';

class SocialService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  Future<String> _getUsernameByUid(String uid) async {
    final doc = await _instance.collection("users").doc(uid).get();
    if (!doc.exists) {
      return "Someone";
    }
    final data = doc.data();
    return data?["username"] ?? "Someone";
  }

  Future<String?> _getPostOwnerId(String postId) async {
    final doc = await _instance.collection("posts").doc(postId).get();
    if (!doc.exists) {
      return null;
    }
    final data = doc.data();
    return data?["author_id"];
  }

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
        await _instance
            .collection('leaderboards')
            .doc('likes')
            .collection('entries')
            .doc(postOwnerId)
            .update({
          'count': FieldValue.increment(1),
          'updated_at': FieldValue.serverTimestamp(),
        });

        final String actorName = await _getUsernameByUid(userId);

        await NotificationService().createUserNotification(
          recipientUid: postOwnerId,
          actorUid: userId,
          actorName: actorName,
          type: "like",
          title: "New Like",
          body: "$actorName liked your post",
          postId: postId,
        );

        await AchievementFirestoreService().incrementProgress(
          uid: postOwnerId,
          type: "QUEST_GET_LIKE",
        );
      } else {
        await _instance
            .collection('leaderboards')
            .doc('likes')
            .collection('entries')
            .doc(postOwnerId)
            .update({
          'count': FieldValue.increment(-1),
          'updated_at': FieldValue.serverTimestamp(),
        });

        await AchievementFirestoreService().decrementProgress(
          uid: postOwnerId,
          type: "QUEST_GET_LIKE",
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addReply({
    required ReplyModel reply,
  }) async {
    final batch = _instance.batch();

    final replyRef = _instance
        .collection("posts")
        .doc(reply.postId)
        .collection("replies")
        .doc(reply.replyId);

    batch.set(replyRef, reply.toMap());

    final postRef = _instance.collection("posts").doc(reply.postId);
    batch.update(postRef, {
      "reply_count": FieldValue.increment(1),
    });

    final String? postOwnerId = await _getPostOwnerId(reply.postId);

    try {
      await batch.commit();

      if (postOwnerId != null && postOwnerId != reply.authorId) {
        final String actorName = await _getUsernameByUid(reply.authorId);

        await NotificationService().createUserNotification(
          recipientUid: postOwnerId,
          actorUid: reply.authorId,
          actorName: actorName,
          type: "reply",
          title: "New Reply",
          body: "$actorName replied to your post",
          postId: reply.postId,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String postId, String userId) async {
  final batch = _instance.batch();
  
  final postRef = _instance.collection("posts").doc(postId);
  final userRef = _instance.collection("users").doc(userId);

  batch.delete(postRef);

  batch.update(userRef, {
    "liked_posts": FieldValue.arrayRemove([postId])
  });

  await batch.commit();
}

  Future<void> deleteReply(String postId, String replyId, String userId) async {
  final batch = _instance.batch();
  
  final replyRef = _instance.collection('posts').doc(postId).collection('replies').doc(replyId);
  final postRef = _instance.collection('posts').doc(postId);
  final userRef = _instance.collection('users').doc(userId);

  batch.delete(replyRef);
  batch.update(postRef, {"reply_count": FieldValue.increment(-1)});

  batch.update(userRef, {
    "liked_replies": FieldValue.arrayRemove([replyId])
  });

  await batch.commit();
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