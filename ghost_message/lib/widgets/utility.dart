import 'package:flutter/material.dart';

Widget _buildToggleButton({
  required String label,
  required bool isSelected,
  required VoidCallback onTap
  }) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected 
          ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] 
          : [],
      ),
      child: Text(
        label, 
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.black : Colors.grey.shade600,
        )
      ),
    ),
  );
}