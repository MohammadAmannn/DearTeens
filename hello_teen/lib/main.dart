import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dear_teens/firebase_options.dart';
import 'app.dart';
import 'core/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  // print("GEMINI KEY -> ${dotenv.env['GEMINI_API_KEY']}");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Push Notifications
  final pushService = PushNotificationService();
  await pushService.initialize();

  runApp(
    const ProviderScope(
      child: HelloTeenApp(),
    ),
  );
}
