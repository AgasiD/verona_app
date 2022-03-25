import 'package:flutter/widgets.dart';
import 'package:verona_app/pages/Form.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/notificaciones.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/pages/obras.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  ChatPage.routeName: (_) => ChatPage(),
  LoginPage.routeName: (_) => LoginPage(),
  ObrasPage.routeName: (_) => ObrasPage(),
  ObraPage.routeName: (_) => ObraPage(),
  FormPage.routeName: (_) => FormPage(),
  NotificacionesPage.routeName: (_) => NotificacionesPage(),
  AgregarPropietariosPage.routeName: (_) => AgregarPropietariosPage(),
};
