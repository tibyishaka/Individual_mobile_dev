import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _useLocation = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get useLocation => _useLocation;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setUseLocation(bool value) {
    _useLocation = value;
    notifyListeners();
  }
}

/// InheritedWidget to propagate SettingsProvider down the tree.
class SettingsScope extends InheritedNotifier<SettingsProvider> {
  const SettingsScope({
    super.key,
    required SettingsProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static SettingsProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SettingsScope>()!
        .notifier!;
  }
}
