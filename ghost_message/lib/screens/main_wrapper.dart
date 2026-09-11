import 'package:flutter/material.dart';
import 'package:ghost_message/providers/navigation_provider.dart';
import 'package:ghost_message/screens/home_screen.dart';
import 'package:ghost_message/screens/profile_screen.dart';
import 'package:ghost_message/screens/setting_screen.dart';
import 'package:ghost_message/widgets/navbar_build.dart';
import 'package:provider/provider.dart';

class MainWrapper extends StatelessWidget {
  final List<Widget> _screens = [
    ProfileScreen(),
    HomeScreen(),
    SettingScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: navigationProvider.currentIndex,
            children: _screens,
          ),
          Positioned(
            bottom: 25,
            left: 20,
            right: 20,
            child: BuildNavbar(context, navigationProvider)
          )
        ]
      )
    );
  }
}