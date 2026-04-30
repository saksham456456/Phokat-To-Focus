import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/planner/providers/planner_provider.dart';
import 'features/focus/providers/focus_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'main_navigation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Attempt to initialize Firebase.
    // If the user hasn't added google-services.json yet, it will fail gracefully and the app will rely on local storage.
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: \$e. App will run in offline/local mode.');
  }

  runApp(const PhokatToFocusApp());
}

class PhokatToFocusApp extends StatelessWidget {
  const PhokatToFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ChangeNotifierProvider(create: (_) => FocusProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Phokat-to-Focus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (auth.isAuthenticated) {
              return const MainNavigation(); // Will show Dashboard correctly
            }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
