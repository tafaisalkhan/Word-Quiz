import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../screens/login_screen.dart';
import 'theme.dart';

class WordPuzzleApp extends StatelessWidget {
  const WordPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Word Quizz',
        theme: buildAppTheme(),
        home: const LoginScreen(),
      ),
    );
  }
}
