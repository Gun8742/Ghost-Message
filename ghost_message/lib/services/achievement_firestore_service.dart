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

  
  Future<void> setupInitialAchievement(String uid) async {
    final collectionReference = _instance.collection("users").doc(uid).collection("achievements");
    final List<Map<String, dynamic>> initialTask = [
      {
        "sequence" : 1,
        "title": "Welcome Ghost",
        "description": "เริ่มต้นการเดินทางใน Ghost Message",
        "current_value": 0,
        "target_value": 1,
        "is_completed": false,
      },
      {
        "sequence" : 2,
        "title": "Social Phantom",
        "description": "ส่งข้อความครบ 5 ครั้ง",
        "current_value": 0,
        "target_value": 5,
        "is_completed": false,
      },
      {
        "sequence" : 3,
        "title": "Social Monster",
        "description": "ส่งข้อความครบ 50 ครั้ง",
        "current_value": 0,
        "target_value": 50,
        "is_completed": false,
      },
      {
        "sequence" : 4,
        "title": "Social Lord",
        "description": "ส่งข้อความครบ 200 ครั้ง",
        "current_value": 0,
        "target_value": 250,
        "is_completed": false,
      },
      {
        "sequence" : 5,
        "title": "Social Emperor",
        "description": "ส่งข้อความครบ 1000 ครั้ง",
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