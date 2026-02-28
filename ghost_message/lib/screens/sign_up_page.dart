import 'package:flutter/material.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/services/achievement_firestore_service.dart';
import 'package:ghost_message/services/auth_service.dart';
import 'package:ghost_message/services/user_firestore_service.dart';
import 'package:ghost_message/widgets/utility.dart';
import 'package:provider/provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  final _userFireStoreService = UserFirestoreService();
  final _achievementService = AchievementFirestoreService();

  bool _isLoading = false;

  void _registerValidation() async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }
    else if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password doesn't match")));
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim()
      );
      if (user != null) {
        await _userFireStoreService.setupInitialUser(
          uid: user.uid,
          username: _usernameController.text.trim(),
          email: user.email!
        );
        print("wait for setup achievement");
        await _achievementService.setupInitialAchievement(user.uid);
        print("done setup achievement");
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, "/main-wrapper", (route) => false);
        }
      }
    }
    catch(e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
    finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final l = Provider.of<L>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
              l.signUp,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36
                )
              ),
              const SizedBox(height: 30),
              buildTextField(ctrl: _usernameController, label: l.username, icon: Icons.person),
              const SizedBox(height: 30),
              buildTextField(ctrl: _emailController, label: l.email, icon: Icons.email),
              const SizedBox(height: 30),
              buildTextField(ctrl: _passwordController, label: l.password, icon: Icons.lock, isPassword: true),
              const SizedBox(height: 30),
              buildTextField(ctrl: _confirmPasswordController, label: l.confirmPassword, icon: Icons.lock, isPassword: true),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerValidation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? ThemeProvider.buttonDark : ThemeProvider.buttonLight
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(l.signUp, style: TextStyle(color: isDark ? ThemeProvider.textDark : ThemeProvider.textLight, fontSize: 18)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/sign-in");
                },
                child: Text(l.haveAccount, style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        )
      )
    );
  }
}