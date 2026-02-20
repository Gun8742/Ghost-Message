import 'package:flutter/material.dart';
import 'package:ghost_message/models/user_model.dart';
import 'package:ghost_message/providers/user_provider.dart';
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
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final List<UserModel> _users = userProvider.allUser;
    final List<UserModel> _reportedUser = userProvider.allReportedUser;
    final List<String> _messages = List.generate(
      10,
      (index) => "lalaaldlawdadw",
    );
    final isUserTab = _selectedMainTab == 0;
    final bool isAllUserTab = _selectedSubTab == 0;
    final subTabTitles =
        isUserTab
            ? ["Userlist", "Reported_User"]
            : ["Message", "Reported_Message"];
    final currentList = isUserTab ? (isAllUserTab ? _users : _reportedUser) : _messages;
    final buttonText = isUserTab ? "User Detail" : "Message Detail";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
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
              ),
              const SizedBox(height: 20),
              buildTabItem(
                tabs: const ["User", "Message"],
                selectedIndex: _selectedMainTab,
                isMainTab: true,
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
                onTabSelected:
                    (index) => setState(() => _selectedSubTab = index),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: currentList.length,
                  separatorBuilder: (ctx, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    return buildDashboardListItem(
                      title:
                          isUserTab
                              ? (isAllUserTab ? _users[index].username : (_reportedUser.length > 0 ? _reportedUser[index].username : ""))
                              : _messages[index],
                      buttonText: buttonText,
                      onPressed: () {
                        if (isUserTab) {
                          final selectedUser = isAllUserTab ? _users[index] : _reportedUser[index];
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
                                    "UID: ${selectedUser.uid}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const Divider(),
                                  Text("Email: ${selectedUser.email}"),
                                  Text("Role: ${selectedUser.role.toUpperCase()}"),
                                  Text("Level: ${selectedUser.level}"),
                                  Text("Language: ${selectedUser.language.toUpperCase()}"),
                                  const SizedBox(height: 10),
                                  
                                  Text("Created: ${selectedUser.createdAt.toString().split('.')[0]}"),
                                  Text("Last Active: ${selectedUser.lastActive.toString().split('.')[0]}"),
                                  const SizedBox(height: 15),
                                  
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: selectedUser.reportCount > 0
                                          ? Colors.red.withOpacity(0.1) 
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column (
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              selectedUser.reportCount > 0 ? Icons.warning : Icons.check_circle,
                                              color: selectedUser.reportCount > 0 ? Colors.red : Colors.green,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              selectedUser.reportCount > 0 
                                                  ? "Reported Account" 
                                                  : "Clean Record",
                                              style: TextStyle(
                                                color: selectedUser.reportCount > 0 ? Colors.red : Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (selectedUser.reportCount > 0)
                                          Text(
                                            selectedUser.reportCount > 0 
                                                ? "${selectedUser.reportCount} users reported this user" 
                                                : "",
                                            style: TextStyle(
                                              color: selectedUser.reportCount > 0 ? Colors.red : Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ]
                                    ),
                                  )
                                ]
                              )
                            )
                          ));
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

