import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_setup.dart';
import 'services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await initializeFirebase();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize RevenueCat
  try {
    await const PurchaseService().initialize();
  } catch (e) {
    debugPrint('RevenueCat initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: SeizaKoreApp(),
    ),
  );
}
