import 'package:flutter/material.dart';
import 'package:ghost_message/providers/navigation_provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/services/user_firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notification = true;
  bool _nearbyChatNotification = true;
  bool _location = true;

  int _chatDistanceIndex = 0;
  
  final UserFirestoreService _userFirestoreService = UserFirestoreService();


  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final l = Provider.of<L>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final user = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentUser = user.currentUser;

    if (currentUser == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
    String email = user.currentUser!.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.settingTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            l.sectionNotification,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: Text(
                  l.settingNotification,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Switch(
                value: _notification,
                onChanged: (val) {
                  setState(() {
                    _notification = val;
                  });
                },
                activeColor: Colors.green,
              )
            ],
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Text(
                  l.settingNearbyChat,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Switch(
                value: _nearbyChatNotification,
                onChanged: (val) {
                  setState(() {
                    _nearbyChatNotification = val;
                  });
                },
                activeColor: Colors.green,
              )
            ],
          ),

          SizedBox(height: 35),

          Text(
            l.sectionLocation,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: Text(
                  l.settingLocation,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Switch(
                value: _location,
                onChanged: (val) {
                  setState(() {
                    _location = val;
                  });
                },
                activeColor: Colors.green,
              )
            ],
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Text(
                  l.settingChatDistance,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _chatDistanceIndex = 0;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: _chatDistanceIndex == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          l.low,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _chatDistanceIndex = 1;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: _chatDistanceIndex == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          l.high,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          SizedBox(height: 35),

          Text(
            l.sectionProfile,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),

          Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(l.email, style: TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: Text(
                  email,
                  style: TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  showEditEmailDialog(context, l, email, (newVal) {
                    setState(() {
                      email = newVal;
                    });
                  });
                },
                child: Text(
                  l.edit,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),

          SizedBox(height: 18),

          Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(l.password, style: TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: Text(
                  "********",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showEditPasswordDialog(context, l);
                },
                child: Text(
                  l.edit,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),

          SizedBox(height: 35),

          Text(
            l.sectionAppearance,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: Text(l.theme, style: TextStyle(fontSize: 16)),
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        themeProvider.updateTheme(false);
                        _userFirestoreService.updateTheme(currentUser.uid, false);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: !themeProvider.isDarkMode ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          l.light,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        themeProvider.updateTheme(true);
                        _userFirestoreService.updateTheme(currentUser.uid, true);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          l.dark,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Text(l.languages, style: TextStyle(fontSize: 16)),
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        langProvider.setLanguage("th");
                        _userFirestoreService.updateLanguage(currentUser.uid, "th");
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: langProvider.languageIndex == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          l.thai,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        langProvider.setLanguage("eng");
                        _userFirestoreService.updateLanguage(currentUser.uid, "eng");
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: langProvider.languageIndex == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          l.english,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      l.confirmtoSignOutTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )
                      ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          l.cancel,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )
                          )
                      ),
                      TextButton(
                        onPressed: () async {
                          navigationProvider.setIndex(1);
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, "/sign-in", (route) => false );
                          }
                        },
                        child: Text(
                          l.signOutButton,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )
                        )
                      )
                    ],
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                elevation: 0,
                side: BorderSide(color: Colors.red.shade200),
                shape: StadiumBorder(),
              ),
              child: Text(
                l.signOutButton,
                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
            ),
          SizedBox(height: 120),
        ],
      ),
    );
  }
}

void showEditEmailDialog(BuildContext context, L l, String currentEmail, Function(String) onConfirm) {
  TextEditingController controller = TextEditingController(text: currentEmail);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.email,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: l.newEmailHint,
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    onConfirm(controller.text);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: StadiumBorder(),
                  ),
                  child: Text(
                    l.confirm,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: StadiumBorder(),
                  ),
                  child: Text(
                    l.cancel,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

void showEditPasswordDialog(BuildContext context, L l) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.password,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: l.newPassHint,
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: l.confirmPassHint,
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: StadiumBorder(),
                  ),
                  child: Text(
                    l.confirm,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: StadiumBorder(),
                  ),
                  child: Text(
                    l.cancel,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}