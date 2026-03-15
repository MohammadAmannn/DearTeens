import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';

class HelloTeenApp extends StatelessWidget {
  const HelloTeenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DearTeens',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.values.firstWhere((mode) => mode.name == 'light', orElse: () => ThemeMode.light), // Supports both light/dark based on system
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
