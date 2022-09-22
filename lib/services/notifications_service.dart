import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:verona_app/helpers/Preferences.dart';

class NotificationService extends ChangeNotifier {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static StreamController<RemoteMessage> _messageStream =
      new StreamController.broadcast();
  static Stream<RemoteMessage> get messagesStream => _messageStream.stream;
  static String? token;
  Preferences _pref = new Preferences();
  int _notificationsCount = new Preferences().badgeNotifications;

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
      badge: true,
      sound: true,
      carPlay: false,
      announcement: false,
      criticalAlert: false,
      provisional: false,
    );

    token = await FirebaseMessaging.instance.getToken();
  }

  static Future _onForeground(RemoteMessage message) async {
    // when the app is in use or open
    if (message.notification != null) {}
    message.data.remove("navega");

    _messageStream.add(message);
  }

  static Future _onBackground(RemoteMessage message) async {
    // when the app is in second plane
    // bool _support = await FlutterAppBadger.isAppBadgeSupported();
    print('_onBackground');
    _messageStream.add(message);
  }

  static Future _onTerminated(RemoteMessage message) async {
    print('_onTerminated');
    message.data["navega"] = true;
    _messageStream.add(message);
  }

  static closeStreams() {
    _messageStream.close();
  }

  sumNotificationBadge() {
    this._notificationsCount++;
    _pref.badgeNotifications = this._notificationsCount;
    _actualizarBadge(this._notificationsCount);
  }

  resetNotificationBadge() {
    this._notificationsCount = 0;
    _pref.badgeNotifications = this._notificationsCount;
    _actualizarBadge(this._notificationsCount);
  }

  readNotification() {
    this._notificationsCount--;
    _pref.badgeNotifications = this._notificationsCount;
    _actualizarBadge(this._notificationsCount);
  }

  _actualizarBadge(int cant) async {
    if (cant < 0) {
      cant = 0;
    }
    await FlutterAppBadger.isAppBadgeSupported()
        ? FlutterAppBadger.updateBadgeCount(cant)
        : false;
  }
}
