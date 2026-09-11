import 'package:flutter/material.dart';

Widget buildSearchTextField({
  required TextEditingController searchController,

  String hintText = "Search",
  String filterText = "Filter",

  Color? textColor,
  Color? hintColor,
  Color? fieldBgColor,
  Color? borderColor,
  Color? filterBgColor,
  Color? filterTextColor,
}) {
  return Row(
    children: [
      Expanded(
        child: TextField(
          controller: searchController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: fieldBgColor != null,
            fillColor: fieldBgColor,
            hintStyle: TextStyle(color: hintColor),
            prefixIcon: Icon(Icons.search, color: hintColor),
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: borderColor ?? Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
    ],
  );
}

Widget buildTabItem({
  required List<String> tabs,
  required int selectedIndex,
  required ValueChanged<int> onTabSelected,
  bool isMainTab = false,

  Color selectedColor = Colors.black,
  Color unselectedColor = Colors.grey,
  Color underlineColor = Colors.black,
}) {
  return Row(
    children: List.generate(tabs.length, (index) {
      final isSelected = selectedIndex == index;
      return GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(bottom: BorderSide(color: underlineColor, width: 2))
                : null,
          ),
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            tabs[index],
            style: TextStyle(
              fontSize: isMainTab ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
        ),
      );
    }),
  );
}

Widget buildDashboardListItem({
  required String title,
  required String buttonText,
  required VoidCallback onPressed,

  Color titleColor = Colors.black,
  Color avatarTextColor = Colors.deepPurple,
  Color buttonBgColor = const Color(0xFF333333),
  Color buttonTextColor = Colors.white,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text(
            "A",
            style: TextStyle(
              color: avatarTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
        ),
        
        const SizedBox(width: 10),
        
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            buttonText,
            style: TextStyle(color: buttonTextColor, fontSize: 14),
          ),
        )
      ],
    ),
  );
}