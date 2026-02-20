import 'package:flutter/material.dart';


Widget buildSearchTextField({
  required TextEditingController searchController,
  required VoidCallback onFilterTap,
  }) {
  return Row(
    children: [
      Expanded(
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: onFilterTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: const [
              Text(
                "Filter",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget buildTabItem({
  required List<String> tabs,
  required int selectedIndex,
  required ValueChanged<int> onTabSelected,
  bool isMainTab = false,
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
                ? const Border(bottom: BorderSide(color: Colors.black, width: 2))
                : null,
          ),
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            tabs[index],
            style: TextStyle(
              fontSize: isMainTab ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey.shade400,
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
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Text("A", style: TextStyle(color: Colors.deepPurple, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF333333),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 14)),
        )
      ],
    ),
  );
}