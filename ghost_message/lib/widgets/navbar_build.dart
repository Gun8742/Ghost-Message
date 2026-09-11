import 'package:flutter/material.dart';
import 'package:ghost_message/providers/navigation_provider.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:provider/provider.dart';

Widget BuildNavbar(BuildContext context, NavigationProvider navigationProvider) {
  final l = Provider.of<L>(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final bg = isDark ? ThemeProvider.buttonDark : ThemeProvider.bgLight;
  final selected = isDark ? ThemeProvider.textDark : ThemeProvider.textLight;
  final unselected = isDark ? Colors.grey.shade500 : Colors.blueGrey;

  return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: Container(
      decoration: BoxDecoration(color: bg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(context, 0, Icons.person_outline, l.navProfile, navigationProvider, selected, unselected),
          _navItemHome(context, 1, navigationProvider, selected, bg),
          _navItem(context, 2, Icons.settings_outlined, l.navSetting, navigationProvider, selected, unselected),
        ],
      ),
    ),
  );
}

Widget _navItem(
  BuildContext context,
  int index,
  IconData icon,
  String label,
  NavigationProvider navigationProvider,
  Color selected,
  Color unselected,
) {
  bool isSelected = navigationProvider.currentIndex == index;

  return GestureDetector(
    onTap: () => navigationProvider.setIndex(index),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? selected : unselected),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? selected : unselected,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _navItemHome(
  BuildContext context,
  int index,
  NavigationProvider navProvider,
  Color selected,
  Color bg,
) {
  bool isSelected = navProvider.currentIndex == index;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final homeBg = isSelected ? (isDark ? ThemeProvider.fieldDark : ThemeProvider.buttonDark) : bg;

  final iconColor = isSelected ? (isDark ? ThemeProvider.textDark : Colors.white) : (isDark ? Colors.grey.shade500 : Colors.grey);

  return GestureDetector(
    onTap: () => navProvider.setIndex(index),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: homeBg,
      ),
      child: Icon(Icons.home, color: iconColor, size: 30),
    ),
  );
}