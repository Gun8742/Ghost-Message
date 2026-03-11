import 'package:flutter/material.dart';
import 'package:ghost_message/providers/navigation_provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/services/user_firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/language_provider.dart';
import 'package:ghost_message/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ghost_message/widgets/utility.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notification = true;
  bool _nearbyChatNotification = true;

  final UserFirestoreService _userFirestoreService = UserFirestoreService();

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final l = Provider.of<L>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final user = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          buildSectionTitle(l.sectionNotification),

          buildSettingSwitchRow(
            title: l.settingNotification,
            value: currentUser.isNotificationEnabled,
            onChanged: (val) {
              user.updateNotificationSetting(val);
              _userFirestoreService.updateNotificationSetting(currentUser.uid, val);
            },
          ),

          const SizedBox(height: 10),

          buildSettingSwitchRow(
            title: l.settingNearbyChat,
            value: currentUser.isNearbyChatEnabled,
            onChanged: (val) {
              user.updateNearbyChatSetting(val);
              _userFirestoreService.updateNearbyChatSetting(currentUser.uid, val);
            },
          ),

          const SizedBox(height: 35),

          buildSectionTitle(l.sectionLocation),

          buildSettingSwitchRow(
            title: l.settingLocation,
            value: currentUser.isLocationEnabled, 
            onChanged: (val) {
              user.updateLocationSetting(val);
              
              _userFirestoreService.updateLocationSetting(currentUser.uid, val);
            },
          ),

          const SizedBox(height: 35),

          buildSectionTitle(l.sectionProfile),

          buildSettingEditRow(
            context: context,
            label: l.email,
            valueText: email,
            editText: l.edit,
            onEdit: () {
              
              showEditEmailDialog(context, l, email, (newVal) {
                setState(() {
                  email = newVal;
                });
              });
            },
          ),

          const SizedBox(height: 18),

          buildSettingEditRow(
            context: context,
            label: l.password,
            valueText: "********",
            editText: l.edit,
            onEdit: () {
              showEditPasswordDialog(context, l);
            },
          ),

          const SizedBox(height: 35),

          buildSectionTitle(l.sectionAppearance),

          Row(
            children: [
              Expanded(
                child: Text(l.theme, style: const TextStyle(fontSize: 16)),
              ),
              buildSegmentPill(
                context: context,
                items: [l.light, l.dark],
                selectedIndex: themeProvider.isDarkMode ? 1 : 0,
                onTap: (i) {
                  final isDark = i == 1;
                  themeProvider.updateTheme(isDark);
                  _userFirestoreService.updateTheme(currentUser.uid, isDark);
                },
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Text(l.languages, style: const TextStyle(fontSize: 16)),
              ),
              buildSegmentPill(
                context: context,
                items: [l.thai, l.english],
                selectedIndex: langProvider.languageIndex,
                onTap: (i) {
                  if (i == 0) {
                    langProvider.setLanguage("th");
                    _userFirestoreService.updateLanguage(currentUser.uid, "th");
                  } else {
                    langProvider.setLanguage("eng");
                    _userFirestoreService.updateLanguage(currentUser.uid, "eng");
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          l.cancel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          navigationProvider.setIndex(1);
                          await NotificationService().stopInAppNotificationListener();
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/sign-in",
                              (route) => false,
                            );
                          }
                        },
                        child: Text(
                          l.signOutButton,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? ThemeProvider.buttonDark : ThemeProvider.pillLight,
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                elevation: 0,
                shape: const StadiumBorder(),
                side: BorderSide(
                  color: isDark ? ThemeProvider.borderDark : ThemeProvider.borderLight,
                ),
              ),
              child: Text(
                l.signOutButton,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          if (currentUser.role == "admin") ...[
            Text(
              l.adminTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/admin-dashboard");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? ThemeProvider.buttonDark : ThemeProvider.pillLight,
                  foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  side: BorderSide(
                    color: isDark ? ThemeProvider.borderDark : ThemeProvider.borderLight
                  ),
                ),
                child: Text(
                  l.adminButton,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}