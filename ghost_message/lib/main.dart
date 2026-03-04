import 'package:flutter/material.dart';
import 'package:ghost_message/providers/admin_provider.dart';
import 'package:ghost_message/providers/navigation_provider.dart';
import 'package:ghost_message/providers/language_provider.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/report_provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/screens/admin/admin_dashboard.dart';
import 'package:ghost_message/screens/main_wrapper.dart';
import 'package:ghost_message/screens/sign_in_screen.dart';
import 'package:ghost_message/screens/sign_up_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()..initUser()),
        ChangeNotifierProxyProvider<UserProvider, LanguageProvider>(
          create: (context) => LanguageProvider(),
          update: (context, userProvider, languageProvider) {
            final String wLanguage = userProvider.currentUser?.language ?? "eng";
            return languageProvider!..setLanguage(wLanguage);
          },
        ),
        ChangeNotifierProxyProvider<UserProvider, ThemeProvider>(
          create: (context) => ThemeProvider(),
          update: (context, userProvider, themeProvider) {
            final bool isDarkMode = userProvider.currentUser?.isDarkMode ?? false;
            return themeProvider!..updateTheme(isDarkMode);
          },
        ),
        ProxyProvider<LanguageProvider, L>(
          update: (context, langProvider, previous) {
            return L(langProvider.lang);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Ghost Message',

      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,

      initialRoute: FirebaseAuth.instance.currentUser == null ? "/sign-in" : "/main-wrapper",
      routes: {
        "/sign-up": (context) => SignUpPage(),
        "/sign-in": (context) => SignInPage(),
        "/main-wrapper": (context) => MainWrapper(),
        "/admin-dashboard": (context) => AdminDashboard(),
      },
    );
  }
}