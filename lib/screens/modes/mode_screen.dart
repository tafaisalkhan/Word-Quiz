import 'package:flutter/material.dart';

import '../../models/word_mode.dart';
import '../../widgets/shared_widgets.dart';

abstract class ModeScreen extends StatelessWidget {
  const ModeScreen({super.key, required this.mode, required this.body});

  final WordMode mode;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDF3FF), Color(0xFFF3E2FF), Color(0xFFECDBFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              ModeAppBar(mode: mode),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
