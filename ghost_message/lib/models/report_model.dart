enum ReportType { user, message }

class ReportModel {
  final String id; 
  final ReportType type; 
  final String targetId; 
  final String reportedByUid; 
  final String reason; 
  final bool isChecked;
  final DateTime createdAt; 

  ReportModel({
    required this.id,
    required this.type,
    required this.targetId,
    required this.reportedByUid,
    required this.reason,
    this.isChecked = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name, 
      'target_id': targetId,
      'reported_by_uid': reportedByUid,
      'reason': reason,
      'is_checked': isChecked,
    };
  }

  factory ReportModel.fromMap(String documentId, Map<String, dynamic> map) {
    return ReportModel(
      id : documentId,
      type: ReportType.values.firstWhere(
        (e) => e.name == map["type"],
        orElse: () => ReportType.user,
      ),
      targetId: map['target_id'] ?? '',
      reportedByUid: map['reported_by_uid'] ?? '',
      reason: map['reason'] ?? '',
      isChecked: map['is_checked'] ?? false,
      createdAt: map['created_at'] != null 
          ? map['created_at'].toDate() 
          : DateTime.now(),
    );
  }
}