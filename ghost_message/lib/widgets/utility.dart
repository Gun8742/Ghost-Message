import 'package:flutter/material.dart';

Widget buildTextField({
  required TextEditingController ctrl,
  required String label,
  required IconData icon,
  bool isPassword = false,
}) {
  return TextField(
    controller: ctrl,
    obscureText: isPassword,
    style: const TextStyle(color: Colors.black),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[900]),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
