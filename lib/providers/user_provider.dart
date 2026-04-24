import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = 'Guest';
  String _quizDifficulty = 'Easy';
  int _points = 0;
  bool _isGuest = true;

  String get userName => _userName;
  String get quizDifficulty => _quizDifficulty;
  int get points => _points;
  bool get isGuest => _isGuest;

  void loginAsGuest() {
    _userName = 'Guest';
    _quizDifficulty = 'Easy';
    _points = 0;
    _isGuest = true;
    notifyListeners();
  }

  void loginWithProfile(String name, String difficulty) {
    _userName = name;
    _quizDifficulty = difficulty;
    _points = 0;
    _isGuest = false;
    notifyListeners();
  }

  void setQuizDifficulty(String difficulty) {
    _quizDifficulty = difficulty;
    notifyListeners();
  }

  void addPoints(int amount) {
    _points += amount;
    notifyListeners();
  }

  void deductPoints(int amount) {
    _points = (_points - amount).clamp(0, _points);
    notifyListeners();
  }
}
