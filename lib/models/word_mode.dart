import 'package:flutter/material.dart';

enum WordMode {
  dailyChallenge,
  wordSwipe,
  crossword,
  wordSearch,
  wordConnect,
  synonymMatch,
  antonymMatch,
  spellingChallenge,
  completeWord,
}

extension WordModeX on WordMode {
  String get title => switch (this) {
    WordMode.dailyChallenge => 'Daily Challenge',
    WordMode.wordSwipe => 'Word Swipe',
    WordMode.crossword => 'Crossword',
    WordMode.wordSearch => 'Word Search',
    WordMode.wordConnect => 'Word Connect',
    WordMode.synonymMatch => 'Synonym Match',
    WordMode.antonymMatch => 'Antonym Match',
    WordMode.spellingChallenge => 'Spelling Challenge',
    WordMode.completeWord => 'Complete the Word',
  };

  String get subtitle => switch (this) {
    WordMode.dailyChallenge => 'Master the challenge of the day',
    WordMode.wordSwipe => 'Build words with a flowing path',
    WordMode.crossword => 'Fill the grid with the right clues',
    WordMode.wordSearch => 'Find hidden words in the puzzle',
    WordMode.wordConnect => 'Connect letters into valid words',
    WordMode.synonymMatch => 'Match the words with similar meaning',
    WordMode.antonymMatch => 'Pick the opposite word',
    WordMode.spellingChallenge => 'Spell the shown word correctly',
    WordMode.completeWord => 'Choose the missing letters',
  };

  IconData get icon => switch (this) {
    WordMode.dailyChallenge => Icons.stars_rounded,
    WordMode.wordSwipe => Icons.swipe_rounded,
    WordMode.crossword => Icons.grid_on_rounded,
    WordMode.wordSearch => Icons.search_rounded,
    WordMode.wordConnect => Icons.join_inner_rounded,
    WordMode.synonymMatch => Icons.sync_alt_rounded,
    WordMode.antonymMatch => Icons.compare_arrows_rounded,
    WordMode.spellingChallenge => Icons.spellcheck_rounded,
    WordMode.completeWord => Icons.text_fields_rounded,
  };

  Color get accent => switch (this) {
    WordMode.dailyChallenge => const Color(0xFFB00D6A),
    WordMode.wordSwipe => const Color(0xFF6A37D4),
    WordMode.crossword => const Color(0xFF0057BD),
    WordMode.wordSearch => const Color(0xFF00897B),
    WordMode.wordConnect => const Color(0xFF7C4DFF),
    WordMode.synonymMatch => const Color(0xFFEF6C00),
    WordMode.antonymMatch => const Color(0xFFE53935),
    WordMode.spellingChallenge => const Color(0xFF7B1FA2),
    WordMode.completeWord => const Color(0xFF009688),
  };
}
