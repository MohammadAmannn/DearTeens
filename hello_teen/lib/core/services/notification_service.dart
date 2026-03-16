import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles all push notification logic for DearTeens.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;

  // ── Initialise ─────────────────────────────────────────────────────────────
  Future<void> init() async {
    // Request permission (iOS / web)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _saveToken();
    }

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Background tap-open handler
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapped);

    // App was launched from a terminated-state notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onNotificationTapped(initial);

    // Subscribe to global topic
    await _messaging.subscribeToTopic('all_teens');
  }

  // ── Save FCM Token to Firestore ───────────────────────────────────────────
  Future<void> _saveToken() async {
    try {
      final token = await _messaging.getToken();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (token != null && uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Refresh token listener
      _messaging.onTokenRefresh.listen((newToken) async {
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        if (currentUid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUid)
              .update({'fcmToken': newToken});
        }
      });
    } catch (_) {}
  }

  // ── Foreground Message Handler ────────────────────────────────────────────
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Foreground notification: ${message.notification?.title}');
    // In a real app, show a local overlay/snackbar here
  }

  // ── Tap Handler ───────────────────────────────────────────────────────────
  void _onNotificationTapped(RemoteMessage message) {
    debugPrint('👆 Notification tapped: ${message.data}');
    // Navigate based on message.data['route'] if needed
  }

  // ── Schedule Wellness Reminders (daily tips) ─────────────────────────────
  // These are triggered server-side via Cloud Functions; this client helper
  // just lets the user toggle the topic subscription.
  Future<void> setDailyTipsEnabled(bool enabled) async {
    if (enabled) {
      await _messaging.subscribeToTopic('daily_tips');
    } else {
      await _messaging.unsubscribeFromTopic('daily_tips');
    }
  }

  Future<void> setChallengeRemindersEnabled(bool enabled) async {
    if (enabled) {
      await _messaging.subscribeToTopic('challenges');
    } else {
      await _messaging.unsubscribeFromTopic('challenges');
    }
  }
}
