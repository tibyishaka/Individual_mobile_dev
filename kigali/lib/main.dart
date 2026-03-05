import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'main_navigation.dart';
import 'providers/settings_provider.dart';
import 'providers/listings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _settingsProvider = SettingsProvider();
  final _listingsProvider = ListingsProvider();

  @override
  void initState() {
    super.initState();
    _listingsProvider.ensureAuthenticated().then((_) {
      _listingsProvider.startListening();
    });
  }

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
