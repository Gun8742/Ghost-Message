import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: 
      ListView(
        padding: EdgeInsets.all(12),
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration (
                color: Colors.black,
                shape: BoxShape.circle
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey
                ),
              )
            )
          )
        ],
      )
    );
  }
}