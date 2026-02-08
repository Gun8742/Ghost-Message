import 'package:flutter/material.dart';
import 'package:ghost_message/providers/navigation_provider.dart';
import 'package:ghost_message/providers/language_provider.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/screens/main_wrapper.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),

        ProxyProvider<LanguageProvider, L>(
          update: (context, langProvider, previous) {
            return L(langProvider.lang);
          },
        ),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghost Message',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MainWrapper()
    );
  }
}
