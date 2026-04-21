import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quiz_content.dart';
import '../models/word_mode.dart';

class QuizRepository {
  const QuizRepository();

  static const QuizRepository instance = QuizRepository();

  Future<QuizDifficultyPack> loadForMode(WordMode mode) async {
    final raw = await rootBundle.loadString(_assetPathForMode(mode));
    return QuizDifficultyPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  String _assetPathForMode(WordMode mode) {
    return switch (mode) {
      WordMode.dailyChallenge => 'json/daily_challenge.json',
      WordMode.wordSwipe => 'json/word_swipe.json',
      WordMode.crossword => 'json/crossword.json',
      WordMode.wordSearch => 'json/word_search.json',
      WordMode.wordConnect => 'json/word_connect.json',
      WordMode.synonymMatch => 'json/synonym_match.json',
      WordMode.antonymMatch => 'json/antonym_match.json',
      WordMode.spellingChallenge => 'json/spelling_challenge.json',
      WordMode.completeWord => 'json/complete_word.json',
    };
  }
}
