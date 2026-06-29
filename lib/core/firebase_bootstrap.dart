import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import '../screens/auth/auth_gate.dart';
import '../screens/setup/firebase_setup_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool initialized = false;
  static String? initError;

  static Future<void> initialize() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      initError = 'Firebase chưa được cấu hình. Chạy flutterfire configure.';
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      initialized = true;
      initError = null;
    } catch (e) {
      initError = e.toString();
      initialized = false;
    }
  }

  static Widget buildRoot({
    required AuthService authService,
    required FirestoreService firestoreService,
    required StorageService storageService,
  }) {
    if (!initialized) {
      return FirebaseSetupScreen(error: initError);
    }

    return AuthGate(
      authService: authService,
      firestoreService: firestoreService,
    );
  }
}
