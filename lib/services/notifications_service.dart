import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/forms/notificaciones_edit.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/pages/listas/chats.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/usuario_service.dart';

class NotificationService extends ChangeNotifier {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static StreamController<RemoteMessage> _messageStream =
      new StreamController.broadcast();
  static Stream<RemoteMessage> get messagesStream => _messageStream.stream;
  static String? token;
  static Preferences _pref = new Preferences();
  int _notificationsCount = new Preferences().badgeNotifications;
  static RemoteMessage? initMessage;

  static Future initializeApp() async {
    // Push Notifications
    await Firebase.initializeApp();
    await requestPermission();

    FirebaseMessaging.onBackgroundMessage(_onBackground);
    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onTerminated);
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
/*
  flujo de entrada de FCM
    Android: 
      - App en segundo plano. Cuando llega la notificacion.
      - App en segundo plano. Cuando se abre la aplicacion
      - App terminada. Cuando llega la notificacion, no cuando se abre.

    iOS: */

    print('_onBackground');
    Preferences pref = new Preferences();
    pref.type = message.data['type'];

    pref.type = '_onBackgroud';
    message.data.addAll({"navega": true});

    _messageStream.add(message);
  }

  static Future _onTerminated(RemoteMessage message) async {
    Preferences pref = new Preferences();

    pref.type = 'onTerminated';
    message.data["navega"] = true;
    message.data.addAll({"navega": true});
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

  static Future<void> manageNotification(
      RemoteMessage notif,
      GlobalKey<NavigatorState> navigatorKey,
      GlobalKey<ScaffoldMessengerState> messengerKey,
      BuildContext context) async {
    print('-----------NUEVA NOTIFICACION-----------');
    final type = notif.data["type"];
    final navega = notif.data["navega"] ?? false;
    //notif.data["navega"] == "true" ? notif.data["navega"] = true : false;

    if (navega) {
      /* Si entra a la app por una notificacion */
      switch (type) {
        case 'message':
          navigatorKey.currentState!.pushNamed(ChatPage.routeName, arguments: {
            "chatId": notif.data["chatId"],
            "chatName": notif.data["chatName"]
          });

          break;
        case 'new-obra':
          //Si es una nueva obra
          if (notif.data["type"] == 'new-obra') {
            final _obraService =
                Provider.of<ObraService>(context, listen: false);
            _obraService.notifyListeners();
          }
          navigatorKey.currentState!.pushNamed(ObraPage.routeName,
              arguments: {"obraId": notif.data["obraId"]});
          break;

        case 'pedido':
          final _obraService = Provider.of<ObraService>(context, listen: false);
          if (_obraService.obra.id == '') {
            final obra = await _obraService.obtenerObra(notif.data['obraId']);
            _obraService.obra = obra;
          }
          navigatorKey.currentState!
              .pushNamed(PedidoForm.routeName, arguments: {
            'pedidoId': notif.data['pedidoId'],
            'obraId': notif.data['obraId'],
          });
          break;
        case 'authNotif':
          navigatorKey.currentState!
              .pushNamed(NotificacionesEditForm.routeName, arguments: {
            'idNotif': notif.data['idNotif'],
          });
          break;
        case 'update_app':
        await Helper.launchWeb(Helper.getURLByPlatform(), context);
      }
    } else {
      /* Si la notificacion llega estando dentro de la app  */
      Navigator.of(navigatorKey.currentContext!).popUntil((route) {
        var snackBar = null;

        final currentPage = route.settings.name ?? '';

        switch (currentPage) {
          case ChatPage.routeName:
            break;
          case ChatList.routeName:
            switch (type) {
              case "pedido":
                snackBar = SnackBar(
                  content: Text(notif.notification!.title ?? 'Sin titulo'),
                  action: SnackBarAction(
                      label: 'Ver',
                      onPressed: () => navigatorKey.currentState!
                              .pushNamed(PedidoForm.routeName, arguments: {
                            'pedidoId': notif.data['pedidoId'],
                            'obraId': notif.data['obraId']
                          })),
                );
                break;
            }
            break;

          default:
            switch (type) {
              case 'message':
                final detalleGrupo = notif.data['individual'] == 'false'
                    ? notif.data['externo'] == 'true'
                        ? ' (externo)'
                        : ' (interno)'
                    : '';
                snackBar = SnackBar(
                  duration: Duration(seconds: 3),
                  action: SnackBarAction(
                      label: 'Ver',
                      onPressed: () => navigatorKey.currentState!
                              .pushNamed(ChatPage.routeName, arguments: {
                            'chatId': notif.data['chatId'],
                            'chatName': notif.data['chatName']
                          })),
                  content: Text(
                    'Nuevo mensaje de ${notif.data['chatName']} $detalleGrupo',
                    // textAlign: TextAlign.center,
                    // style: style,
                  ),
                );
                break;
              case 'pedido':
                snackBar = SnackBar(
                  content: Text(notif.notification!.title ?? 'Sin titulo'),
                  action: SnackBarAction(
                      label: 'Ver',
                      onPressed: () => navigatorKey.currentState!
                              .pushNamed(PedidoForm.routeName, arguments: {
                            'pedidoId': notif.data['pedidoId'],
                            'obraId': notif.data['obraId']
                          })),
                );
                break;
              case 'authNotif':
                snackBar = SnackBar(
                  content: Text(notif.notification!.title ?? 'Sin titulo'),
                  action: SnackBarAction(
                      label: 'Ver',
                      onPressed: () => navigatorKey.currentState!.pushNamed(
                              NotificacionesEditForm.routeName,
                              arguments: {
                                'idNotif': notif.data['idNotif'],
                              })),
                );
                break;
                
            }

            break;
        }
        if (snackBar != null) messengerKey.currentState?.showSnackBar(snackBar);

        if (!currentPage.contains('chat')) {
          // Si no estoy en pantalla de chat
        } else {
          // if(route.settings.name == 'chat'){

          // // si estoy dentro de chat
          // Map<String, dynamic> args =
          //     route.settings.arguments as Map<String, dynamic>;
          // final chatId = args["chatId"];
          // final data = notif.data;

          // if (data['chatId'] != chatId) {
          //   messengerKey.currentState?.showSnackBar(snackBar);
          // }
          // }
        }
        return true;
      });

      //Si es un nuevo mensaje o cambios en obra
      final _usuarioService =
          Provider.of<UsuarioService>(context, listen: false);
      final _chatService = Provider.of<ChatService>(context, listen: false);
      if (type == 'message') {
        _usuarioService.notifyListeners();
        _chatService.notifyListeners();
      }
      //Si es una nueva obra
      if (type == 'new-obra') {
        final _obraService = Provider.of<ObraService>(context, listen: false);
        _obraService.notifyListeners();
        _usuarioService.notifyListeners();
      }
      if (type == 'inactivity') {
        final _obraService = Provider.of<ObraService>(context, listen: false);
        _obraService.notifyListeners();
        _usuarioService.notifyListeners();
      }
    }
  }
}
