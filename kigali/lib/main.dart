import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'localisation/app_localizations.dart';
import 'main_navigation.dart';
import 'screens/sign_in.dart';
import 'providers/settings_provider.dart';
import 'providers/listings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  final listingsProvider = ListingsProvider();

  // Request FCM permission (non-critical — only saves token if user is
  // already signed in from a previous session).
  try {
    final messaging = FirebaseMessaging.instance;
    final notifSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (notifSettings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      if (token != null && FirebaseAuth.instance.currentUser != null) {
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
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    // Start or stop the Firestore listener based on auth state.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listingsProvider.startListening();
      } else {
        _listingsProvider.stopListening();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
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
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: FirebaseAuth.instance.currentUser != null
                  ? const MainNavigation()
                  : const SignInScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
