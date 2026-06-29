import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/firebase_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await FirebaseBootstrap.initialize();

  runApp(const CheckinGoApp());
}

class CheckinGoApp extends StatelessWidget {
  const CheckinGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final storageService = StorageService();

    return MaterialApp(
      title: 'CheckinGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
      routes: {
        '/home': (_) => FirebaseBootstrap.buildRoot(
              authService: authService,
              firestoreService: firestoreService,
              storageService: storageService,
            ),
      },
    );
  }
}
