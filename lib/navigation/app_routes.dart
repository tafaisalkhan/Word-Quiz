import 'package:flutter/material.dart';

import '../models/word_mode.dart';
import '../screens/modes/antonym_match_screen.dart';
import '../screens/modes/complete_word_screen.dart';
import '../screens/modes/crossword_screen.dart';
import '../screens/modes/daily_challenge_screen.dart';
import '../screens/modes/spelling_challenge_screen.dart';
import '../screens/modes/synonym_match_screen.dart';
import '../screens/modes/word_connect_screen.dart';
import '../screens/modes/word_search_screen.dart';
import '../screens/modes/word_swipe_screen.dart';

Widget screenForMode(WordMode mode) => switch (mode) {
  WordMode.dailyChallenge => DailyChallengeScreen(),
  WordMode.wordSwipe => WordSwipeScreen(),
  WordMode.crossword => CrosswordScreen(),
  WordMode.wordSearch => WordSearchScreen(),
  WordMode.wordConnect => WordConnectScreen(),
  WordMode.synonymMatch => SynonymMatchScreen(),
  WordMode.antonymMatch => AntonymMatchScreen(),
  WordMode.spellingChallenge => SpellingChallengeScreen(),
  WordMode.completeWord => CompleteWordScreen(),
};

void pushMode(BuildContext context, WordMode mode) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screenForMode(mode)));
}
