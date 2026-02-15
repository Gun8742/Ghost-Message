import 'package:flutter/material.dart';

enum AppLang { th, eng }

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

  void setLanguage(String language) {
    if (language == "th") {
      _lang = AppLang.th;
    }
    else if (language == "eng") {
      _lang = AppLang.eng;
    }
    notifyListeners();
  }
}
