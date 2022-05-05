import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService extends ChangeNotifier {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static StreamController<RemoteMessage> _messageStream =
      new StreamController.broadcast();
  static Stream<RemoteMessage> get messagesStream => _messageStream.stream;
  static String? token;

  static Future initializeApp() async {
    // Push Notifications
    await Firebase.initializeApp();
    await requestPermission();

    // Handlers
    FirebaseMessaging.onBackgroundMessage(_onBackground);
    // Foreground message
    FirebaseMessaging.onMessage.listen(_onForeground);

    FirebaseMessaging.onMessageOpenedApp.listen(_onTerminated);

    // Local Notifications
  }

  // Apple / Web
  static requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    token = await FirebaseMessaging.instance.getToken();
  }

  static Future _onForeground(RemoteMessage message) async {
    // when the app is in use or open

    if (message.notification != null) {}
    _messageStream.add(message);
  }

  static Future _onBackground(RemoteMessage message) async {
    // when the app is in second plane

    _messageStream.add(message.data['product'] ?? 'No data');
  }

  static Future _onTerminated(RemoteMessage message) async {
    // when the app is close
    _messageStream.add(message.data['product'] ?? 'No data');
  }

  static closeStreams() {
    _messageStream.close();
  }
}
