class AchievementModel {
  final String id;
  final int sequence;
  final String title;
  final String description;
  final double currentValue;
  final double targetValue;
  final String? iconPath;
  final bool isCompleted;

  AchievementModel({
    required this.id,
    required this.sequence,
    required this.title,
    required this.description,
    this.currentValue = 0,
    required this.targetValue,
    this.iconPath,
    this.isCompleted = false,
  });

  double get progress {
    return currentValue <= targetValue ? currentValue / targetValue : 1;
  }

  bool get isFinished {
    return progress == 1 ? true : false;
  }

  factory AchievementModel.fromMap(String id, Map<String, dynamic> data) {
    double current = (data["current_value"] ?? 0).toDouble();
    double target = (data["target_value"] ?? 1).toDouble();
    bool dbCompleted = data["is_completed"] ?? false;

    bool isFinished = dbCompleted || (current >= target);
    return AchievementModel(
      id: id,
      sequence: data["sequence"] ?? 0,
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      currentValue: current, 
      targetValue: target,
      iconPath: data['icon_path'],
      isCompleted: isFinished,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      "sequence" : sequence,
      "title": title,
      "description": description,
      "current_value": currentValue,
      "target_value": targetValue,
      "icon_path": iconPath,
      "is_completed": isFinished,
    };
  }

}