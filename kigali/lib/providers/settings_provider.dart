import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Load persisted settings from SharedPreferences on app start.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode =
        ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index];
    _locale = Locale(prefs.getString('locale') ?? 'en');
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _useLocation = prefs.getBool('useLocation') ?? false;
    _locationNotifications = prefs.getBool('locationNotifications') ?? false;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  void setUseLocation(bool value) async {
    _useLocation = value;
    if (!value) _locationNotifications = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useLocation', value);
    await prefs.setBool('locationNotifications', _locationNotifications);
  }

  void setLocationNotifications(bool value) async {
    _locationNotifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('locationNotifications', value);
  }

  void setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    if (!value) _locationNotifications = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    await prefs.setBool('locationNotifications', _locationNotifications);
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
