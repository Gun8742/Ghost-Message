import 'package:flutter/material.dart';
import 'package:ghost_message/models/achievement_model.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:provider/provider.dart';

String getAchievementAssetPath(int sequence) {
  switch (sequence) {
    case 1:
      return 'assets/images/achievements/ghost_message_1.png';
    case 2:
      return 'assets/images/achievements/ghost_message_5.png';
    case 3:
      return 'assets/images/achievements/ghost_message_50.png';
    case 4:
      return 'assets/images/achievements/ghost_message_250.png';
    case 5:
      return 'assets/images/achievements/ghost_message_1000.png';
    case 6:
      return 'assets/images/achievements/ghost_like_1.png';
    case 7:
      return 'assets/images/achievements/ghost_like_10.png';
    case 8:
      return 'assets/images/achievements/ghost_like_100.png';
    case 9:
      return 'assets/images/achievements/ghost_like_500.png';
    case 10:
      return 'assets/images/achievements/ghost_like_1000.png';
    default:
      return 'assets/images/achievements/default_ghost.png';
  }
}

Widget buildAchievement(BuildContext context, AchievementModel item, String uid) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final bool isDark = themeProvider.isDarkMode;

  return Container(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    decoration: BoxDecoration(
      color: isDark ? ThemeProvider.fieldDark : (item.isCompleted ? Colors.green.withOpacity(0.05) : ThemeProvider.bgLight),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: item.isCompleted
            ? Colors.green.withOpacity(0.2)
            : (isDark ? Colors.black26 : Colors.grey.shade100),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.isCompleted ? Colors.green : (isDark ? ThemeProvider.buttonDark : Colors.deepPurple.shade50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Opacity(
                opacity: item.isCompleted ? 1 : 0.55,
                child: Image.asset(
                  getAchievementAssetPath(item.sequence),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        item.title.isNotEmpty ? item.title[0] : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? ThemeProvider.textDark
                              : Colors.deepPurple.shade700,
                          fontSize: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ),
          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? ThemeProvider.textDark : (item.isCompleted ? Colors.grey : ThemeProvider.textLight),
                  ),
                ),
                SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 8,
                    backgroundColor: isDark ? ThemeProvider.buttonDark.withOpacity(0.3) : ThemeProvider.pillLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.isCompleted ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${item.currentValue.toInt()} / ${item.targetValue.toInt()}",
                  style: TextStyle(fontSize: 12, color: isDark ? ThemeProvider.textDark.withOpacity(0.85) : ThemeProvider.textLight.withOpacity(0.85)),
                ),
              ],
            ),
          ),

          // if (!item.isCompleted)
          //   IconButton(
          //     icon: Icon(Icons.add_circle_outline, color: isDark ? ThemeProvider.textDark : Colors.blueAccent),
          //     onPressed: () {
          //       AchievementFirestoreService().updateProgress(
          //         uid,
          //         item.id,
          //         item.currentValue + 1,
          //         item.targetValue,
          //       );
          //     },
          //   ),
        ],
      ),
    ),
  );
}

Widget buildBadge(BuildContext context, AchievementModel item, String uid) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final bool isDark = themeProvider.isDarkMode;

  return Column(
    children: [
      Container(
        width: 125,
        height: 125,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? ThemeProvider.fieldDark : ThemeProvider.bgLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? ThemeProvider.borderDark : ThemeProvider.borderLight,
            width: 3.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Image.asset(
              getAchievementAssetPath(item.sequence),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.emoji_events, size: 50, color: Colors.amber.shade200);
              },
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: 100,
        child: Text(
          item.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
          ),
        ),
      ),
    ],
  );
}

Widget achievementColumnBuild(BuildContext context, List<AchievementModel> items, String uid) {
  return Column(
    children: items.map((item) {
      return Column(
        children: [
          buildAchievement(context, item, uid),
          SizedBox(height: 5),
        ],
      );
    }).toList(),
  );
}