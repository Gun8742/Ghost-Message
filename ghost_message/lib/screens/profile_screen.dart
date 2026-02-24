import 'package:flutter/material.dart';
import 'package:ghost_message/models/achievement_model.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/services/achievement_firestore_service.dart';
import 'package:ghost_message/widgets/achievement_list_build.dart';
import 'package:ghost_message/widgets/utility.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectIndex = 0;
  final AchievementFirestoreService _achievementFirestoreService = AchievementFirestoreService();
  late Stream<List<AchievementModel>> _achievementStream;


  @override
  void initState() {
    final String currentUid = FirebaseAuth.instance.currentUser!.uid;
    super.initState();
    _achievementStream = _achievementFirestoreService.getAchievements(currentUid);
  }

  List<List<AchievementModel>> _chunkList(
    List<AchievementModel> list,
    int chunkSize,
  ) {
    List<List<AchievementModel>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize < list.length ? i + chunkSize : list.length,
        ),
      );
    }

    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<L>(context);
    final user = Provider.of<UserProvider>(context);
    final currentUser = user.currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        )
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.profileTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<AchievementModel>>(
        stream: _achievementStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }
          final allAchievement = snapshot.data ?? [];
          final separatedAchievement = _chunkList(allAchievement, 4);
          final finishedAchievement = allAchievement.where((i) => i.isCompleted).toList();

          return ListView(
            padding: EdgeInsets.all(12),
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 200,
                      height: 200,
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
                    ),
                  ),
                  Positioned(
                    right: 80,
                    bottom: 0,
                    child: IconButton(
                      icon: Icon(Icons.edit_square),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 40),
                    Text(
                      currentUser.username,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.edit_square),
                      onPressed: () {
                        showEditUsernameDialog(context, l, currentUser.username);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                textAlign: TextAlign.center,
                l.badgeTitle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  padding: EdgeInsets.all(12),
                  scrollDirection: Axis.horizontal,
                  itemCount: finishedAchievement.length,
                  itemBuilder: (context, index) {
                   return buildBadge(context, finishedAchievement[index], currentUser.uid);
                  },
                ),
              ),
              SizedBox(height: 30),
              Text(
                textAlign: TextAlign.center,
                l.achievementTitle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 30),
              IndexedStack(
                index: _selectIndex,
                children:
                    separatedAchievement.map((items) {
                      return achievementColumnBuild(context, items, currentUser.uid);
                    }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: _selectIndex > 0 ? Colors.black : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_selectIndex > 0) {
                          _selectIndex--;
                        }
                      });
                    },
                  ),
                  Text(
                    "${_selectIndex + 1}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 7),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color:
                          _selectIndex < separatedAchievement.length - 1 ? Colors.black : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_selectIndex <
                            separatedAchievement.length - 1) {
                          _selectIndex++;
                        }
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }
}

