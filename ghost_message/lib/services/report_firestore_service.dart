import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghost_message/models/report_model.dart';

enum ReportType {
  user,
  message
}

class ReportFirestoreService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  Future<void> submitToReport({
    required ReportType type,
    required String targetId,
    required String reportedByUid,
    required String reason,
  }) async {
    final batch = _instance.batch();
    final reference = _instance.collection("reports").doc();
    batch.set(reference, {
      "report_type" : type.name,
      "target_id": targetId,
      "reported_by_uid": reportedByUid,
      "reason": reason,
      "status": "pending",
      "created_at": FieldValue.serverTimestamp(),
    });

    if (type == ReportType.user) {
      final userRef = _instance.collection("users").doc(targetId);
      batch.update(userRef, {
        "report_count": FieldValue.increment(1),
      });
    }
    else if (type == ReportType.message) {
      final messageRef = _instance.collection("messsage").doc(targetId);
      batch.update(messageRef, {
        "report_count": FieldValue.increment(1),
      });
    }

    try {
      await batch.commit();
    }
    catch(e) {
      rethrow;
    }
  }

  CollectionReference? get _reportData {
    return _instance.collection("report");
  }

  Stream<QuerySnapshot> getReportStream() {
    if (_reportData == null) {
      return Stream.empty();
    }
    final reportDataStream = _reportData!.orderBy("is_checked", descending: false).orderBy("created_at", descending: false).snapshots();
    return reportDataStream;
  }

  Stream<List<ReportModel>> getReportList() {
    return getReportStream().map((snapshots) {
      return snapshots.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ReportModel.fromMap(doc.id, data);
      }).toList();
    });
  }
}