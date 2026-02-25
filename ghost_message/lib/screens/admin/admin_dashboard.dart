import 'package:flutter/material.dart';
import 'package:ghost_message/models/user_model.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/widgets/admin_utilities.dart';
import 'package:provider/provider.dart';

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
    final l = Provider.of<L>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final List<UserModel> _users = userProvider.allUser;
    final List<UserModel> _reportedUser = userProvider.allReportedUser;

    final List<String> _messages = List.generate(
      10,
      (index) => "Message: $index",
    );

    final String query = _searchController.text.toLowerCase();
    final filteredUsers = _users.where((user) => 
      user.username.toLowerCase().contains(query) || user.email.toLowerCase().contains(query)
    ).toList();
    final filteredReported = _reportedUser.where((user) => 
      user.username.toLowerCase().contains(query)
    ).toList();

    final filteredMessages = _messages.where((message) => 
      message.toLowerCase().contains(query)
    ).toList();

    final isUserTab = _selectedMainTab == 0;
    final bool isAllUserTab = _selectedSubTab == 0;

    final subTabTitles = isUserTab
        ? [l.adminSubUserList, l.adminSubReportedUser]
        : [l.adminSubMessage, l.adminSubReportedMessage];

    final currentList = isUserTab ? (isAllUserTab ? filteredUsers : filteredReported) : filteredMessages;
    final buttonText = isUserTab ? l.adminUserDetailBtn : l.adminMessageDetailBtn;

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
                onFilterTap: () {
                  print("Filter Tapped");
                },
                hintText: l.adminSearchHint,
                filterText: l.adminFilter,
                textColor: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                hintColor: isDark ? ThemeProvider.textDark.withOpacity(0.7) : ThemeProvider.textDark.withOpacity(0.7),
                fieldBgColor: isDark ? ThemeProvider.fieldDark : null,
                borderColor: isDark ? ThemeProvider.borderDark : ThemeProvider.borderLight,
                filterBgColor: isDark ? ThemeProvider.buttonDark : ThemeProvider.buttonLight,
                filterTextColor: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
              ),
              const SizedBox(height: 20),

              buildTabItem(
                tabs: [l.adminTabUser, l.adminTabMessage],
                selectedIndex: _selectedMainTab,
                isMainTab: true,
                selectedColor: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                unselectedColor: isDark ? ThemeProvider.textDark.withOpacity(0.7) : ThemeProvider.textDark.withOpacity(0.7),
                underlineColor: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                onTabSelected: (index) {
                  setState(() {
                    _selectedMainTab = index;
                    _selectedSubTab = 0;
                  });
                },
              ),

              const SizedBox(height: 20),

              buildTabItem(
                tabs: subTabTitles,
                selectedIndex: _selectedSubTab,
                selectedColor: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                unselectedColor: isDark ? ThemeProvider.textDark.withOpacity(0.7) : ThemeProvider.textDark.withOpacity(0.7),
                underlineColor: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                onTabSelected: (index) => setState(() => _selectedSubTab = index),
              ),

              Expanded(
                child: ListView.separated(
                  itemCount: currentList.length,
                  separatorBuilder: (ctx, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    final item = currentList[index];

                    return buildDashboardListItem(
                      title: isUserTab 
                          ? (item as UserModel).username 
                          : item as String,
                      buttonText: buttonText,
                      titleColor: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                      buttonBgColor: isDark ? ThemeProvider.buttonDark : ThemeProvider.buttonLight,
                      buttonTextColor: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                      onPressed: () {
                        if (isUserTab) {
                          final selectedUser =
                              isAllUserTab ? _users[index] : _reportedUser[index];
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Text(selectedUser.username),
                                ],
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SelectableText(
                                      "${l.adminUid}: ${selectedUser.uid}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? ThemeProvider.textDark.withOpacity(0.7) : ThemeProvider.textLight.withOpacity(0.7),
                                      ),
                                    ),
                                    const Divider(),
                                    Text("${l.adminEmail}: ${selectedUser.email}"),
                                    Text("${l.adminRole}: ${selectedUser.role.toUpperCase()}"),
                                    Text("${l.adminLevel}: ${selectedUser.level}"),
                                    Text("${l.adminLanguage}: ${selectedUser.language.toUpperCase()}"),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${l.adminCreated}: ${selectedUser.createdAt.toString().split('.')[0]}",
                                    ),
                                    Text(
                                      "${l.adminLastActive}: ${selectedUser.lastActive.toString().split('.')[0]}",
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: selectedUser.reportCount > 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                selectedUser.reportCount > 0 ? Icons.warning : Icons.check_circle,
                                                color: selectedUser.reportCount > 0 ? Colors.red : Colors.green,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                selectedUser.reportCount > 0 ? l.adminReportedAccount : l.adminCleanRecord,
                                                style: TextStyle(
                                                  color: selectedUser.reportCount > 0 ? Colors.red : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (selectedUser.reportCount > 0)
                                            Text(
                                              "${l.adminReportedCountPrefix}${selectedUser.reportCount}${l.adminReportedCountSuffix}",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
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
        ),
      ),
    );
  }
}