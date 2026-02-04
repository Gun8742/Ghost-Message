import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex {
    return _currentIndex;
  }

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}