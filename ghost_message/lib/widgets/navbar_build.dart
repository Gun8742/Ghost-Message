import 'package:flutter/material.dart';
import 'package:ghost_message/providers/navigation_provider.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:provider/provider.dart';


Widget BuildNavbar(BuildContext context, NavigationProvider navigationProvider) {
  final l = Provider.of<L>(context);
  return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(context, 0, Icons.person_outline, l.navProfile, navigationProvider),
          _navItemHome(context, 1, navigationProvider),
          _navItem(context, 2, Icons.settings_outlined, l.navSetting, navigationProvider),
        ],
      )
    )
  );
}


Widget _navItem(BuildContext context, int index, IconData icon, String label, NavigationProvider navigationProvider) {
  bool isSelected = navigationProvider.currentIndex == index;
  return GestureDetector(
    onTap: () {
      navigationProvider.setIndex(index);
    },
    child: Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.black : Colors.blueGrey),
          Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.blueGrey, fontSize: 11)),
        ],
      )
    )
  );
}

Widget _navItemHome(BuildContext context, int index, NavigationProvider navProvider) {
  bool isSelected = navProvider.currentIndex == index;
  return GestureDetector(
    onTap: () => navProvider.setIndex(index),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.black : Colors.white,
      ),
      child: const Icon(Icons.home, color: Colors.grey, size: 30),
    ),
  );
}