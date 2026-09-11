import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghost_message/models/admin_message_model.dart';
class AdminFirestoreService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;
  Future<void> toggleSuspend(String uid, bool isSuspended) async {
    await _instance.collection("users").doc(uid).update({
      "is_suspended": !isSuspended,
    });
  }
  Stream<List<AdminMessageModel>> streamAllContent() {
    final controller = StreamController<List<AdminMessageModel>>();
    
    List<AdminMessageModel> posts = [];
    List<AdminMessageModel> replies = [];

    void mergeList() {
      final allMessages = [...posts, ...replies];
      allMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(allMessages);
    }
    _instance.collection("posts")
      .orderBy("created_at", descending: true)
      .snapshots()
      .listen((snapshot) {
        posts = snapshot.docs.map((doc) {
          final data = doc.data();
          return AdminMessageModel(
            messageId: doc.id,
            content: data['message'] ?? '',
            authorId: data['author_id'] ?? '',
            createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
            type: 'post',
            reportCount: data['report_count'] ?? 0,
          );
        }).toList();
        
        mergeList();
    });
    _instance.collectionGroup("replies")
      .orderBy("created_at", descending: true)
      .snapshots()
      .listen((snapshot) {
        replies = snapshot.docs.map((doc) {
          final data = doc.data();
          
          final parentId = doc.reference.parent.parent?.id; 

          return AdminMessageModel(
            messageId: doc.id,
            content: data['message'] ?? '',
            authorId: data['author_id'] ?? '',
            createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
            type: 'reply',
            parentPostId: parentId,
            reportCount: data["report_reply_count"] ?? 0,
          );
        }).toList();

        mergeList();
    });
    return controller.stream;
  }

  Future<void> deleteContent(AdminMessageModel item) async {
    if (item.type == 'post') {
      await deletePost(item.messageId);
    } else if (item.type == 'reply' && item.parentPostId != null) {
      await deleteReply(item.parentPostId!, item.messageId);
    }
  }

  Future<void> deletePost(String postId) async {
    await _instance.collection('posts').doc(postId).delete();
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
  Future<void> deleteContentByReport({required String targetId, required String type}) async {
    try {
      if (type == 'post') {
        await _instance.collection('posts').doc(targetId).delete();
      } 
      else if (type == 'reply') {
        final query = await _instance.collectionGroup('replies').where(FieldPath.documentId, isEqualTo: targetId).get();

        for (var doc in query.docs) {
          final parentId = doc.reference.parent.parent?.id;
          
          if (parentId != null) {
            await deleteReply(parentId, targetId);
          } else {
            await doc.reference.delete();
          }
        }
      }
    } catch (e) {
      print("Delete Error: $e");
    }
  }
}
