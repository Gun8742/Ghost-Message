import 'package:flutter/material.dart';
import 'package:ghost_message/models/admin_message_model.dart';
import 'package:ghost_message/models/report_model.dart';
import 'package:ghost_message/models/user_model.dart';
import 'package:ghost_message/providers/admin_provider.dart';
import 'package:ghost_message/providers/report_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/widgets/admin_utilities.dart';
import 'package:provider/provider.dart';
import 'package:ghost_message/services/admin_firestore_service.dart';
import 'package:ghost_message/services/report_firestore_service.dart';
import 'package:flutter/services.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedMainTab = 0;
  int _selectedSubTab = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).initReports();
      Provider.of<AdminProvider>(context, listen: false).initMessages();
    });

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    final l = Provider.of<L>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final String query = _searchController.text.toLowerCase();

    final filteredUsers =
        userProvider.allUser
            .where(
              (user) =>
                  user.username.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query) ||
                  user.uid.toLowerCase().contains(query),
            )
            .toList();

    final filteredMessages =
        adminProvider.allMessages
            .where(
              (m) =>
                  m.content.toLowerCase().contains(query) ||
                  m.messageId.toLowerCase().contains(query),
            )
            .toList();

    final isUserTab = _selectedMainTab == 0;
    final bool isAllUserTab = _selectedSubTab == 0;

    final subTabTitles =
        isUserTab
            ? [
              l.adminSubUserList,
              "${l.adminSubReportedUser} (Pending)",
              "Checked Users",
            ]
            : [
              l.adminSubMessage,
              "${l.adminSubReportedMessage} (Pending)",
              "Checked Messages",
            ];

    List<dynamic> currentList;

    if (isUserTab) {
      if (_selectedSubTab == 0) {
        currentList = filteredUsers;
      } else if (_selectedSubTab == 1) {
        currentList =
            reportProvider.allReports.where((r) {
              return r.type.name == 'user' && r.isChecked == false;
            }).toList();
      } else {
        currentList =
            reportProvider.allReports.where((r) {
              return r.type.name == 'user' && r.isChecked == true;
            }).toList();
      }
    } else {
      if (_selectedSubTab == 0) {
        currentList = filteredMessages;
      } else if (_selectedSubTab == 1) {
        currentList =
            reportProvider.allReports.where((r) {
              return (r.type.name == 'message' || r.type.name == 'reply') &&
                  r.isChecked == false;
            }).toList();
      } else {
        currentList =
            reportProvider.allReports.where((r) {
              return (r.type.name == 'message' || r.type.name == 'reply') &&
                  r.isChecked == true;
            }).toList();
      }
    }
    final buttonText =
        isAllUserTab
            ? (isUserTab ? l.adminUserDetailBtn : l.adminMessageDetailBtn)
            : "Check";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.adminTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: isDark ? ThemeProvider.bgDark : ThemeProvider.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              buildSearchTextField(
                searchController: _searchController,
                hintText: l.adminSearchHint,
                filterText: l.adminFilter,
                textColor:
                    isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                hintColor:
                    isDark
                        ? ThemeProvider.textDark.withOpacity(0.7)
                        : ThemeProvider.textDark.withOpacity(0.7),
                fieldBgColor: isDark ? ThemeProvider.fieldDark : null,
                borderColor:
                    isDark
                        ? ThemeProvider.borderDark
                        : ThemeProvider.borderLight,
                filterBgColor:
                    isDark
                        ? ThemeProvider.buttonDark
                        : ThemeProvider.buttonLight,
                filterTextColor:
                    isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
              ),
              const SizedBox(height: 20),

              buildTabItem(
                tabs: [l.adminTabUser, l.adminTabMessage],
                selectedIndex: _selectedMainTab,
                isMainTab: true,
                selectedColor:
                    isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                unselectedColor:
                    isDark
                        ? ThemeProvider.textDark.withOpacity(0.7)
                        : ThemeProvider.textDark.withOpacity(0.7),
                underlineColor:
                    isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                onTabSelected: (index) {
                  setState(() {
                    _selectedMainTab = index;
                    _selectedSubTab = 0;
                  });
                },
              ),

              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: buildTabItem(
                  tabs: subTabTitles,
                  selectedIndex: _selectedSubTab,
                  selectedColor:
                      isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                  unselectedColor:
                      isDark
                          ? ThemeProvider.textDark.withOpacity(0.7)
                          : ThemeProvider.textDark.withOpacity(0.7),
                  underlineColor:
                      isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                  onTabSelected:
                      (index) => setState(() => _selectedSubTab = index),
                ),
              ),

              Expanded(
                child: ListView.separated(
                  itemCount: currentList.length,
                  separatorBuilder: (ctx, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    final item = currentList[index];

                    String titleText = "";

                    if (item is UserModel) {
                      titleText = item.username;
                    } else if (item is AdminMessageModel) {
                      titleText = item.content;
                    } else if (item is ReportModel) {
                      titleText = "${l.adminReportReason}: ${item.reason}";
                    }

                    return buildDashboardListItem(
                      title: titleText,
                      buttonText: buttonText,
                      titleColor:
                          isDark
                              ? ThemeProvider.textDark
                              : ThemeProvider.textLight,
                      buttonBgColor:
                          isDark
                              ? ThemeProvider.buttonDark
                              : ThemeProvider.buttonLight,
                      buttonTextColor:
                          isDark
                              ? ThemeProvider.textDark
                              : ThemeProvider.textLight,
                      onPressed: () {
                        if (item is UserModel) {
                          _showUserDialog(item);
                        } else if (item is AdminMessageModel) {
                          _showMessageDialog(item);
                        } else if (item is ReportModel) {
                          _showReportActionDialog(item);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDialog(UserModel user) {
    final l = Provider.of<L>(context, listen: false);

    String formatDate(DateTime? date) {
      if (date == null) return "-";
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      (user.photoPath!.isNotEmpty)
                          ? NetworkImage(user.photoPath!)
                          : null,
                  child:
                      (user.photoPath!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  user.role == 'admin'
                                      ? Colors.blue
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    user.role == 'admin'
                                        ? Colors.white
                                        : Colors.black87,
                              ),
                            ),
                          ),
                          if (user.isSuspended) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "BANNED",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.adminAccountInfo,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Divider(height: 10),
                  _buildInfoRow(l.adminUid, user.uid, isCopyable: true),
                  _buildInfoRow(l.adminEmail, user.email),
                  _buildInfoRow(l.adminLanguage, user.language.toUpperCase()),

                  const SizedBox(height: 15),

                  Text(
                    l.adminActivityStats,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Divider(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          l.adminLevel,
                          user.level.toString(),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoRow(
                          l.adminLikesGiven,
                          "${user.likedPosts.length + user.likedReplies.length}",
                        ),
                      ),
                    ],
                  ),
                  _buildInfoRow(l.adminJoined, formatDate(user.createdAt)),
                  _buildInfoRow(l.adminLastActive, formatDate(user.lastActive)),

                  if (user.reportCount > 0) ...[
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${l.adminReportedCountPrefix}${user.reportCount}${l.adminReportedCountSuffix}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.adminClose),
              ),
              if (user.role != "admin")
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        user.isSuspended ? Colors.green : Colors.red,
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    await AdminFirestoreService().toggleSuspend(
                      user.uid,
                      user.isSuspended,
                    );
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          user.isSuspended
                              ? l.unbannedUserSuccessfully
                              : l.bannedUserSuccessfully,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    user.isSuspended ? l.unban : l.ban,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child:
                isCopyable
                    ? SelectableText(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                    : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(AdminMessageModel message) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final l = Provider.of<L>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(userProvider.getUsernameById(message.authorId)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.content),
                  const SizedBox(height: 10),
                  SelectableText(
                    "ID: ${message.messageId}",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.adminClose),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  await AdminFirestoreService().deleteContent(message);
                  messenger.showSnackBar(
                    SnackBar(content: Text(l.adminDeleted)),
                  );
                },
                child: Text(
                  l.adminDelete,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showReportActionDialog(ReportModel report) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final l = Provider.of<L>(context, listen: false);
    String idLabel = report.type.name == 'user' ? "UID" : "Message ID";
    bool isTargetAdmin = false;

    if (report.type.name == 'user') {
      try {
        final targetUser = userProvider.allUser.firstWhere((u) => u.uid == report.targetId);
        
        if (targetUser.role.toLowerCase() == 'admin') {
          isTargetAdmin = true;
        }
      } catch (e) {
        isTargetAdmin = false;
      }
    }
    
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(l.adminReportDetail),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${l.adminReportReason}: ${report.reason}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Divider(height: 20),

                Text("${l.adminReportType}: ${report.type.name}"),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              idLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            SelectableText(
                              report.targetId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.blue),
                        tooltip: "Copy",
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: report.targetId),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Copied ID!"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (isTargetAdmin) ...[
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text("Admin Account", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
                if (report.isChecked) ...[
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Center(
                      child: Text(
                        "ตรวจสอบแล้ว (Checked)",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            actions: [
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isTargetAdmin)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(context);

                        if (report.type.name == 'user') {
                          await AdminFirestoreService().toggleSuspend(
                            report.targetId,
                            false,
                          );
                        } else {
                          await AdminFirestoreService().deleteContentByReport(
                            targetId: report.targetId,
                            type: report.type.name,
                          );
                        }

                        await ReportFirestoreService().deleteReport(report.id);

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              report.type.name == 'user'
                                  ? l.adminMsgBanSuccess
                                  : l.adminMsgDeleteSuccess,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        report.type.name == 'user'
                            ? l.adminBanUser
                            : l.adminDeleteContent,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  if (!report.isChecked) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(context);
                        await ReportFirestoreService().markAsChecked(report.id);
                        messenger.showSnackBar(
                          SnackBar(content: Text(l.adminMsgAckKeep)),
                        );
                      },
                      child: Text(l.adminAckKeep),
                    ),
                    const SizedBox(height: 8),
                  ],

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l.adminClose,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }
}
