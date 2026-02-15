import 'package:flutter/material.dart';
import 'package:ghost_message/models/achievement_model.dart';
import 'package:ghost_message/services/achievement_firestore_service.dart';

Widget buildAchievement(AchievementModel item, String uid) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    decoration: BoxDecoration(
      color: item.isCompleted ? Colors.green.withOpacity(0.05) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: item.isCompleted ? Colors.green.withOpacity(0.2) : Colors.grey.shade100,
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
              color: item.isCompleted ? Colors.green : Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: item.isCompleted 
                ? Icon(Icons.check, color: Colors.white)
                : Text(
                    item.title[0], 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.deepPurple.shade700,
                      fontSize: 20
                    )
                  ),
            ),
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
                    color: item.isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.isCompleted ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${item.currentValue.toInt()} / ${item.targetValue.toInt()}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          if (!item.isCompleted)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
              onPressed: () {
                AchievementFirestoreService().updateProgress(
                  uid, 
                  item.id, 
                  item.currentValue + 1, 
                  item.targetValue
                );
              },
            ),
        ],
      ),
    ),
  );
}

Widget buildBadge() {
  return Container(
    width: 150,
    height: 150,
    padding: EdgeInsets.all(4), 
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.grey.shade300,
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
      child: Image.asset(
        "assets/images/black.png",
        fit: BoxFit.cover,
      ),
    ),
  );
}

Widget achievementColumnBuild(List<AchievementModel> items, String uid) {
  return Column(
    children: items.map((item){
      return Column(
        children: [
          buildAchievement(item, uid),
          SizedBox(height: 5),
        ],
      );
    }).toList()
  );
}