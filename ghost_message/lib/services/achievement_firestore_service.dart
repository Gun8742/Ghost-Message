import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghost_message/models/achievement_model.dart';
class AchievementFirestoreService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  Stream<List<AchievementModel>> getAchievements(String uid) {
    final collectionReference = _instance.collection("users").doc(uid).collection("achievements");

    return collectionReference.orderBy("is_completed", descending: false).orderBy("sequence", descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AchievementModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addAchievement(String uid, String title, String description, double targetValue, String? iconPath) async {
    final reference = _instance.collection("users").doc(uid).collection("achievements");
    final snapshot = await reference.get();
    final int nextSequence = snapshot.size + 1;
    await reference.add({
      "sequence" : nextSequence,
      "title" : title,
      "description" : description,
      "current_value" : 0,
      "target_value" : targetValue,
      "progress" : 0,
      "icon_path" : iconPath,
      "is_completed" : false,
    });
  }

  Future<void> updateProgress(String uid,String docID, double newCurrentValue, double targetValue) async {
    final reference = _instance.collection("users").doc(uid).collection("achievements");
    bool isFinished = newCurrentValue >= targetValue;
    await reference.doc(docID).update({
      "current_value" : newCurrentValue,
      "is_completed" : isFinished,
    });
  }

  Future<void> incrementProgress({
    required uid,
    required type,
    double amount = 1,
  }) async {
    final reference = _instance.collection("users").doc(uid).collection("achievements");

    final snapshot = await reference.where("type", isEqualTo: type).where("is_completed", isEqualTo: false).get();
    final batch = _instance.batch();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      double current = (data["current_value"] ?? 0).toDouble();
      double target = (data["target_value"] ?? 1).toDouble();
      double newValue = current + amount;
      bool isFinished = newValue >= target;

      batch.update(doc.reference, {
        "current_value": newValue,
        "is_completed": isFinished,
      });
    }
    
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }
  Future<void> decrementProgress({
    required uid,
    required type,
    double amount = -1,
  }) async {
    final reference = _instance.collection("users").doc(uid).collection("achievements");

    final snapshot = await reference.where("type", isEqualTo: type).where("is_completed", isEqualTo: false).get();
    final batch = _instance.batch();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      double current = (data["current_value"] ?? 0).toDouble();
      double target = (data["target_value"] ?? 1).toDouble();
      double newValue = current + amount;
      bool isFinished = newValue >= target;

      batch.update(doc.reference, {
        "current_value": newValue,
        "is_completed": isFinished,
      });
    }
    
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  
  Future<void> setupInitialAchievement(String uid) async {
    final collectionReference = _instance.collection("users").doc(uid).collection("achievements");
    final List<Map<String, dynamic>> initialTask = [
      {
        "sequence" : 1,
        "title": "Welcome Ghost",
        "type": "QUEST_SEND_MSG",
        "description": "เริ่มต้นการเดินทางใน Ghost Message",
        "current_value": 0,
        "target_value": 1,
        "is_completed": false,
      },
      {
        "sequence" : 2,
        "title": "Social Phantom",
        "type": "QUEST_SEND_MSG",
        "description": "ส่งข้อความครบ 5 ครั้ง",
        "current_value": 0,
        "target_value": 5,
        "is_completed": false,
      },
      {
        "sequence" : 3,
        "title": "Social Monster",
        "type": "QUEST_SEND_MSG",
        "description": "ส่งข้อความครบ 50 ครั้ง",
        "current_value": 0,
        "target_value": 50,
        "is_completed": false,
      },
      {
        "sequence" : 4,
        "title": "Social Lord",
        "type": "QUEST_SEND_MSG",
        "description": "ส่งข้อความครบ 200 ครั้ง",
        "current_value": 0,
        "target_value": 250,
        "is_completed": false,
      },
      {
        "sequence" : 5,
        "title": "Social Emperor",
        "type": "QUEST_SEND_MSG",
        "description": "ส่งข้อความครบ 1000 ครั้ง",
        "current_value": 0,
        "target_value": 1000,
        "is_completed": false,
      },
      {
        "sequence" : 6,
        "title": "First like?",
        "type": "QUEST_GET_LIKE",
        "description": "ได้รับ Like ครบ 1 ครั้ง",
        "current_value": 0,
        "target_value": 1,
        "is_completed": false,
      },
      {
        "sequence" : 7,
        "title": "Popular Ghost",
        "type": "QUEST_GET_LIKE",
        "description": "ได้รับ Like ครบ 10 ครั้ง",
        "current_value": 0,
        "target_value": 10,
        "is_completed": false,
      },
      {
        "sequence" : 8,
        "title": "Celebrity Ghost",
        "type": "QUEST_GET_LIKE",
        "description": "ได้รับ Like ครบ 100 ครั้ง",
        "current_value": 0,
        "target_value": 100,
        "is_completed": false,
      },
      {
        "sequence" : 9,
        "title": "Influencer Ghost",
        "type": "QUEST_GET_LIKE",
        "description": "ได้รับ Like ครบ 500 ครั้ง",
        "current_value": 0,
        "target_value": 500,
        "is_completed": false,
      },
      {
        "sequence" : 10,
        "title": "No one don't know this guy",
        "type": "QUEST_GET_LIKE",
        "description": "ได้รับ Like ครบ 1000 ครั้ง",
        "current_value": 0,
        "target_value": 1000,
        "is_completed": false,
      },
    ];

    final batch = FirebaseFirestore.instance.batch();

    for (Map<String, dynamic> i in initialTask) {
      batch.set(collectionReference.doc(), i);
    }
    await batch.commit();
  }
}