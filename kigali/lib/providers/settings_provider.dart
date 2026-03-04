import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _useLocation = false;
  bool _locationNotifications = false;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get useLocation => _useLocation;
  bool get locationNotifications => _locationNotifications;
  bool get notificationsEnabled => _notificationsEnabled;

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
    if (!value) {
      _locationNotifications = false;
    }
    notifyListeners();
  }

  void setLocationNotifications(bool value) {
    _locationNotifications = value;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    if (!value) {
      _locationNotifications = false;
    }
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
