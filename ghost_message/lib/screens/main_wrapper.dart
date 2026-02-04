import 'package:flutter/material.dart';
import 'package:ghost_message/providers/navigation_provider.dart';
import 'package:ghost_message/screens/home_screen.dart';
import 'package:ghost_message/screens/profile_screen.dart';
import 'package:ghost_message/screens/setting_screen.dart';
import 'package:provider/provider.dart';

class MainWrapper extends StatelessWidget {
  final List<Widget> _screens = [
    HomeScreen(),
    ProfileScreen(),
    SettingScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    return Scaffold(
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: _screens,
      )
    );
  }
}