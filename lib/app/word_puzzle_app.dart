import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import 'theme.dart';

class WordPuzzleApp extends StatelessWidget {
  const WordPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ethereal Lexicon',
      theme: buildAppTheme(),
      home: const LoginScreen(),
    );
  }
}
