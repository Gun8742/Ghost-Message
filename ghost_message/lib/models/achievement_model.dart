class AchievementModel {
  final String title;
  final double progress; // 0 - 1
  final bool isCompleted;

  AchievementModel({
    required this.title,
    required this.progress,
    this.isCompleted = false,
  });
}