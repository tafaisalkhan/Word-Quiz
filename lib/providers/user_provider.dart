import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = 'Guest';
  int _points = 0;
  bool _isGuest = true;

  String get userName => _userName;
  int get points => _points;
  bool get isGuest => _isGuest;

  void loginAsGuest() {
    _userName = 'Guest';
    _points = 0;
    _isGuest = true;
    notifyListeners();
  }

  void loginWithEmail(String email) {
    _userName = email.split('@').first;
    _points = 0;
    _isGuest = false;
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
