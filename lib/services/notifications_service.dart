import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:verona_app/helpers/Preferences.dart';

class NotificationService extends ChangeNotifier {
  Preferences _pref = new Preferences();
  int _notificationsCount = new Preferences().badgeNotifications;

  Future showNotificationWithSound(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      String title,
      String body,
      String payload) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: "pulse.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
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
