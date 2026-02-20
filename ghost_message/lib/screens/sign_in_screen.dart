import 'package:flutter/material.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/services/auth_service.dart';
import 'package:ghost_message/widgets/utility.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;

  void _loginValidation() async {
    final _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final _userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim()
      );
      if (user != null) {
        if (context.mounted) {
          _themeProvider.updateTheme(_userProvider.currentUser!.isDarkMode);
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
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
             const Text(
              "Sign In",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36
                )
              ),
              const SizedBox(height: 30),
              buildTextField(ctrl: _emailController, label: "Email", icon: Icons.email),
              const SizedBox(height: 30),
              buildTextField(ctrl: _passwordController, label: "Password", icon: Icons.lock, isPassword: true),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginValidation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Sign In", style: TextStyle(color: Colors.black, fontSize: 18)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/sign-up");
                },
                child: const Text("Doesn't have an account? Sign Up", style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        )
      )
    );
  }
}