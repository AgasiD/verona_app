import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Enviroment.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/routes/routes.dart';
import 'package:verona_app/services/auth_service.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/etapa_service.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/image_service.dart';
import 'package:verona_app/services/notifications_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/services/tarea_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:vibration/vibration.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //espera que los widtes se inicialiicen para seguir

  // inicializa servicio notificaciones
  final pref = new Preferences();
  await pref.initPrefs();
  await NotificationService.initializeApp();
  final RemoteMessage? _message =
      await NotificationService.messaging.getInitialMessage();
  NotificationService.initMessage = _message;

  await dotenv.load(fileName: Environment.fileName);

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
          create: (_) => TareaService(),
          lazy: false,
        ),

        ChangeNotifierProvider(
          create: (_) => EtapaService(),
          lazy: false,
        ),

        ChangeNotifierProvider(
          create: (_) => GoogleDriveService(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => ImageService(),
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
          create: (_) => AuthService(),
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
  // static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final _pref = new Preferences();

    NotificationService.messagesStream.listen((notif) async {
      /* SE EJECUTA CUANDO SE RECIBE UNA NOTIFICACION PUSH */
      await NotificationService.manageNotification(
          notif, navigatorKey, messengerKey, context);
    });
  }

  bool _isInForeground = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    _isInForeground = state == AppLifecycleState.resumed;

    if (_isInForeground) {
      final _socketService = Provider.of<SocketService>(context, listen: false);
      final _authService = Provider.of<AuthService>(context, listen: false);
      final _pref = new Preferences();
      if (_pref.id != null || _pref.id != '') {
        _socketService.connect(_pref.id);
      }
      final _notService =
          Provider.of<NotificationService>(context, listen: false);
      _notService.resetNotificationBadge();

      //renovar token

      // print(_pref.token == null);
      // print(_pref.token == '');
      // if (_pref.token != null && _pref.token != '') {
      //   final response = await _authService.validarToken(_pref.token);
      //   if (!response.fallo) {
      //     _pref.token = response.data.toString();
      //   }
      // }
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
    ObraService _obrasService =
        Provider.of<ObraService>(context, listen: false);

    final _pref = new Preferences();
    late String initalRoute;
    initalRoute = !_pref.logged ? LoginPage.routeName : ObrasPage.routeName;
    final _chatService = Provider.of<ChatService>(context, listen: false);
    final _socket = Provider.of<SocketService>(context, listen: false);

    if (_pref.logged) {
      _socket.connect(_pref.id);

      final _notificationService =
          Provider.of<NotificationService>(context, listen: false);
      _socket.socket.on('notification', (data) {
        Navigator.of(navigatorKey.currentContext!).popUntil((route) {
          if (!route.settings.name!.contains('chat')) {
            // si NO se encuentra actualmente en un chat
            if (data != null) {
              final notificationText = data.toString().split(';');
              _notificationService.sumNotificationBadge();
            }
          }
          return true;
        });
      });

      _socket.socket.on('nuevo-mensaje', (data) {
        //Escucha mensajes del servidor
        Vibration.vibrate(duration: 5, amplitude: 10);
        // final snackBar = _initSnackMessage(data, navigatorKey);

        Navigator.of(navigatorKey.currentContext!).popUntil((route) {
          if (!route.settings.name!.contains('chat')) {
            // messengerKey.currentState?.showSnackBar(snackBar);
            _chatService.tieneMensaje = true;
            _chatService.notifyListeners();
          }
          return true;
        });
        _chatService.notifyListeners();
      });

      _socket.socket.on('message', (data) {
        final _usuarioService =
            Provider.of<UsuarioService>(context, listen: false);
        _usuarioService.notifyListeners();
      });

      _socket.socket.on('new-obra', (data) {
        _obrasService.notifyListeners();
      });
      _socket.socket.on('inactivity', (data) {});
    }

    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('es', ''),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Verona App',
      initialRoute: initalRoute,

      navigatorKey: navigatorKey, // Navegar
      scaffoldMessengerKey: messengerKey, // Snacks
      routes: appRoutes,
      themeMode: ThemeMode.dark,
    );
  }
}

SnackBar _initSnackMessage(data, navigatorKey) {
  return SnackBar(
    duration: Duration(seconds: 3),
    action: SnackBarAction(
        label: 'Ver',
        onPressed: () => navigatorKey.currentState!.pushNamed(
            ChatPage.routeName,
            arguments: {'chatId': data['chatId'], 'chatName': data['name']})),
    content: Text(
      'Nuevo mensaje de ${data['name']}',
      // textAlign: TextAlign.center,
      // style: style,
    ),
  );
}
