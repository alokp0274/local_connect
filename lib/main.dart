// /main.dart
//
// Application entry point. Initializes MaterialApp with premium dark theme and routing.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050B2D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LocalConnectApp());
}

/// Root widget for the LocalConnect application.
class LocalConnectApp extends StatelessWidget {
  const LocalConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
