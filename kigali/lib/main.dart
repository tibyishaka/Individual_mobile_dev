import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'main_navigation.dart';
import 'providers/settings_provider.dart';
import 'providers/listings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialise settings (loads persisted prefs) before runApp.
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  // Request FCM permission and save token.
  final listingsProvider = ListingsProvider();
  await listingsProvider.ensureAuthenticated();
  listingsProvider.startListening();

  try {
    final messaging = FirebaseMessaging.instance;
    final notifSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (notifSettings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      if (token != null) {
        await listingsProvider.saveFCMToken(token);
      }
    }
  } catch (_) {
    // FCM is non-critical; continue if it fails.
  }

  runApp(
    MyApp(
      settingsProvider: settingsProvider,
      listingsProvider: listingsProvider,
    ),
  );
}

class MyApp extends StatefulWidget {
  final SettingsProvider settingsProvider;
  final ListingsProvider listingsProvider;
  const MyApp({
    super.key,
    required this.settingsProvider,
    required this.listingsProvider,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SettingsProvider _settingsProvider = widget.settingsProvider;
  late final ListingsProvider _listingsProvider = widget.listingsProvider;

  @override
  void dispose() {
    _settingsProvider.dispose();
    _listingsProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      provider: _settingsProvider,
      child: ListingsScope(
        provider: _listingsProvider,
        child: AnimatedBuilder(
          animation: _settingsProvider,
          builder: (context, _) {
            return MaterialApp(
              title: 'Kigali',
              themeMode: _settingsProvider.themeMode,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              locale: _settingsProvider.locale,
              home: const MainNavigation(),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
