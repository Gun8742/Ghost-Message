import 'package:flutter/material.dart';
import 'package:ghost_message/models/achievement_model.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/services/achievement_firestore_service.dart';
import 'package:ghost_message/services/user_firestore_service.dart';
import 'package:ghost_message/widgets/achievement_list_build.dart';
import 'package:ghost_message/widgets/utility.dart';
import 'package:ghost_message/screens/leaderboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ghost_message/services/image_service.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectIndex = 0;
  File? _imageFile;
  final _imageService = ImageService();
  final AchievementFirestoreService _achievementFirestoreService =
      AchievementFirestoreService();
  late Stream<List<AchievementModel>> _achievementStream;

  @override
  void initState() {
    final String currentUid = FirebaseAuth.instance.currentUser!.uid;
    super.initState();
    _achievementStream = _achievementFirestoreService.getAchievements(
      currentUid,
    );
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    if (currentUser == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
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
          final finishedAchievement =
              allAchievement.where((i) => i.isCompleted).toList();

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
                        child:
                            _imageFile != null
                                ? Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                  width: 200,
                                  height: 200,
                                )
                                : (currentUser.photoPath != null &&
                                    currentUser.photoPath!.isNotEmpty)
                                ? Image.network(
                                  currentUser.photoPath!,
                                  fit: BoxFit.cover,
                                  width: 200,
                                  height: 200,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.person,
                                          size: 100,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                                : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 80,
                    bottom: 0,
                    child: IconButton(
                      icon: Icon(Icons.edit_square),
                      onPressed: () {
                        _imageService.showImageOptions(
                          context: context,
                          onImageSelected: (File file) async {
                            setState(() {
                              _imageFile = file;
                            });
                            final String uid = currentUser.uid;
                            String? url = await _imageService
                                .uploadProfileImage(uid, file);

                            if (url != null) {
                              await UserFirestoreService().updateUserPhotoEverywhere(
                                uid: uid,
                                photoPath: url,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l.profilePicUpdated),
                                ),
                              );
                            }
                          },
                        );
                      },
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
                        showEditUsernameDialog(
                          context,
                          l,
                          currentUser.username,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Column(
                children: [
                  Text(
                    "Level ${currentUser.level}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: currentUser.exp / (currentUser.level * 100),
                        minHeight: 12,
                        backgroundColor: themeProvider.currentHintColor.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  Text(
                    "${currentUser.exp} / ${currentUser.level * 100} EXP",
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.currentHintColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              if(finishedAchievement.isNotEmpty) ...[
                Text(
                  textAlign: TextAlign.center,
                  l.badgeTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: finishedAchievement.length,
                    itemBuilder: (context, index) {
                      return buildBadge(
                        context,
                        finishedAchievement[index],
                        currentUser.uid,
                      );
                    },
                  ),
                ),
                SizedBox(height: 30),
              ],
              Text(
                textAlign: TextAlign.center,
                l.achievementTitle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? ThemeProvider.buttonDark : ThemeProvider.buttonLight,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    l.leaderboardButton,
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? ThemeProvider.textDark : ThemeProvider.textLight),
                  ),
                ),
              ),

              SizedBox(height: 30),
              IndexedStack(
                index: _selectIndex,
                children:
                    separatedAchievement.map((items) {
                      return achievementColumnBuild(
                        context,
                        items,
                        currentUser.uid,
                      );
                    }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: _selectIndex > 0 
                          ? themeProvider.currentTextColor 
                          : themeProvider.currentHintColor,
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
                      // 🟢 ใช้ currentTextColor
                      color: themeProvider.currentTextColor, 
                    ),
                  ),
                  SizedBox(width: 7),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                     color: _selectIndex < separatedAchievement.length - 1
                              ? themeProvider.currentTextColor
                              : themeProvider.currentHintColor,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_selectIndex < separatedAchievement.length - 1) {
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
