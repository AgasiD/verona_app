import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/inactividades.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/routes/routes.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/notifications_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/services/usuario_service.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //espera que los widtes se inicialiicen para seguir

  // inicializa servicio notificaciones

  final pref = new Preferences();
  await pref.initPrefs();
  runApp(AppState());
}

class AppState extends StatefulWidget {
  @override
  State<AppState> createState() => _AppStateState();
}

class _AppStateState extends State<AppState> {
  // Para inyectar services http
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ObraService(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => GoogleDriveService(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationService(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => ChatService(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => SocketService(),
        ),

        ChangeNotifierProvider(
          create: (_) => UsuarioService(),
          lazy: false,
        ), //lazy es para que se cree cuando se necesite. con el false se crea cuando se instancia.
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      new GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final _pref = new Preferences();

    // Future initializeApp() async {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    // }

    //SOLO SE DISPARA CUANDO ESTA LA APP ABIERTA
    // print('-----------NUEVA NOTIFICACION-----------');
    // final type = notif.data["type"];
    // if (notif.data["navega"] ?? false) {
    //   switch (type) {
    //     case 'message':
    //       navigatorKey.currentState!.pushNamed(ChatPage.routeName, arguments: {
    //         "chatId": notif.data["chatId"],
    //         "chatName": notif.data["chatName"]
    //       });
    //       break;
    //     case 'new-obra':
    //       //Si es una nueva obra
    //       if (notif.data["type"] == 'new-obra') {
    //         final _obraService =
    //             Provider.of<ObraService>(context, listen: false);
    //         print('notifly listener 1');
    //         _obraService.notifyListeners();
    //       }
    //       navigatorKey.currentState!.pushNamed(ObraPage.routeName,
    //           arguments: {"obraId": notif.data["obraId"]});
    //       break;
    //   }
    // } else {
    //   Navigator.of(navigatorKey.currentContext!).popUntil((route) {
    //     final snackBar = SnackBar(
    //       content: Text(notif.notification!.title ?? 'Sin titulo'),
    //     );
    //     if (!route.settings.name!.contains('chat')) {
    //       messengerKey.currentState?.showSnackBar(snackBar);
    //     } else {
    //       Map<String, dynamic> args =
    //           route.settings.arguments as Map<String, dynamic>;
    //       final chatId = args["chatId"];
    //       final data = notif.data;
    //       if (data['chatId'] != chatId) {
    //         messengerKey.currentState?.showSnackBar(snackBar);
    //       }
    //     }
    //     return true;
    //   });
    // }
  }

  Future onSelectNotification(String? payload) async {
    print(payload);
    final type_value = payload!.split(':');
    print(type_value[1]);
    switch (type_value[0]) {
      case 'inactivity':
        final _obraService = Provider.of<ObraService>(context, listen: false);
        final _usuarioService =
            Provider.of<UsuarioService>(context, listen: false);
        _obraService.notifyListeners();
        _usuarioService.notifyListeners();
        this.navigatorKey.currentState?.pushNamed(InactividadesPage.routeName,
            arguments: {"obraId": type_value[1]});

        break;
      case 'new-obra':
        final _obraService = Provider.of<ObraService>(context, listen: false);
        final _usuarioService =
            Provider.of<UsuarioService>(context, listen: false);
        _obraService.notifyListeners();
        _usuarioService.notifyListeners();
        navigatorKey.currentState!.pushNamed(ObraPage.routeName,
            arguments: {"obraId": type_value[1]});
        break;
      case 'message':
        // navigatorKey.currentState!.pushNamed(ChatPage.routeName, arguments: {
        //     "chatId": notif.data["chatId"],
        //     "chatName": notif.data["chatName"]
        //   });
        break;
    }
  }

  void onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? 'title'),
        content: Text(body ?? 'body'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              print('onDidReceiveLocalNotification');
            },
          )
        ],
      ),
    );
  }

  bool _isInForeground = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Para detectar si la app vuelve a primer plano
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;

    if (_isInForeground) {
      final _notService =
          Provider.of<NotificationService>(context, listen: false);
      _notService.resetNotificationBadge();
    }
    if (AppLifecycleState.inactive.name == 'inactive') {
      final _notService =
          Provider.of<NotificationService>(context, listen: false);
      _notService.resetNotificationBadge();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _pref = new Preferences();
    late String initalRoute;
    initalRoute = !_pref.logged ? LoginPage.routeName : ObrasPage.routeName;

    final _socket = Provider.of<SocketService>(context, listen: false);

    if (_pref.logged) {
      _socket.connect(_pref.id);

      final _notificationService =
          Provider.of<NotificationService>(context, listen: false);
      _socket.socket.on('notification', (data) {
        Navigator.of(navigatorKey.currentContext!).popUntil((route) {
          if (!route.settings.name!.contains('chat')) {
            // si NO se encuentra actualmente en un chat

            final notificationText = data.toString().split(';');
            _notificationService.showNotificationWithSound(
                flutterLocalNotificationsPlugin,
                notificationText[0],
                notificationText[1],
                notificationText[2]);
            _notificationService.sumNotificationBadge();
          }
          return true;
        });
      });

      _socket.socket.on('message', (data) {
        final _usuarioService =
            Provider.of<UsuarioService>(context, listen: false);
        _usuarioService.notifyListeners();
      });

      _socket.socket.on('new-obra', (data) {});
      _socket.socket.on('inactivity', (data) {});
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verona App',
      initialRoute: initalRoute,
      navigatorKey: navigatorKey, // Navegar
      scaffoldMessengerKey: messengerKey, // Snacks
      routes: appRoutes,
    );
  }
}
