import 'package:flutter/material.dart';

enum AppLang { th, en }

class LanguageProvider extends ChangeNotifier {
  AppLang _lang = AppLang.th;

  AppLang get lang {
    return _lang;
  }

  bool get isThai {
    return _lang == AppLang.th;
  }

  int get languageIndex {
    return _lang == AppLang.th ? 0 : 1;
  }

  void setLang(AppLang value) {
    _lang = value;
    notifyListeners();
  }

  void setLangIndex(int index) {
    _lang = index == 0 ? AppLang.th : AppLang.en;
    notifyListeners();
  }
}
