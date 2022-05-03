import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService extends ChangeNotifier {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static StreamController<String> _messageStream =
      new StreamController.broadcast();
  static Stream<String> get messagesStream => _messageStream.stream;
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

    print('User push notification status ${settings.authorizationStatus}');
    token = await FirebaseMessaging.instance.getToken();
  }

  static Future _onForeground(RemoteMessage message) async {
    // when the app is in use or open
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
    _messageStream.add(message.data['product'] ?? 'No data');
  }

  static Future _onBackground(RemoteMessage message) async {
    // when the app is in second plane

    print(message.data);
    print(message.notification?.title ?? 'titulo');
    _messageStream.add(message.data['product'] ?? 'No data');
  }

  static Future _onTerminated(RemoteMessage message) async {
    // when the app is close

    print(message.data);
    print(message.notification?.title ?? 'titulo');
    _messageStream.add(message.data['product'] ?? 'No data');
  }

  static closeStreams() {
    _messageStream.close();
  }
}
