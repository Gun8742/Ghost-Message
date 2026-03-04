import 'package:flutter/material.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/providers/l_provider.dart';
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
    final l = Provider.of<L>(context, listen: false);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.fulfillTheBox)));
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
        if (!_userProvider.currentUser!.isSuspended) {
          if (context.mounted) {
            _themeProvider.updateTheme(_userProvider.currentUser!.isDarkMode);
            Navigator.pushNamedAndRemoveUntil(context, "/main-wrapper", (route) => false);
          }
        }
        else {
          await _authService.signOut();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.accountSuspended)));
        }
      }
      else {
         if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.signInFailed))
            );
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
              l.signIn,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36
                )
              ),
              const SizedBox(height: 30),
              buildTextField(ctrl: _emailController, label: l.email, icon: Icons.email),
              const SizedBox(height: 30),
              buildTextField(ctrl: _passwordController, label: l.password, icon: Icons.lock, isPassword: true),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginValidation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  isDark ? ThemeProvider.buttonDark : ThemeProvider.buttonLight,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(l.signIn, style: TextStyle(color: isDark ? ThemeProvider.textDark : ThemeProvider.textLight, fontSize: 18)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/sign-up");
                },
                child: Text(l.noHaveAccount, style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        )
      )
    );
  }
}