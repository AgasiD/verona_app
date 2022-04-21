import 'package:flutter/widgets.dart';
import 'package:verona_app/pages/Form.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/asignar_equipo.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/chats.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/notificaciones.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/pages/password.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  AgregarPropietariosPage.routeName: (_) => AgregarPropietariosPage(),
  AsignarEquipoPage.routeName: (_) => AsignarEquipoPage(),
  ChatPage.routeName: (_) => ChatPage(),
  FormPage.routeName: (_) => FormPage(),
  LoginPage.routeName: (_) => LoginPage(),
  MiembroForm.routeName: (_) => MiembroForm(),
  NotificacionesPage.routeName: (_) => NotificacionesPage(),
  ObraForm.routeName: (_) => ObraForm(),
  ObraPage.routeName: (_) => ObraPage(),
  ObrasPage.routeName: (_) => ObrasPage(),
  PasswordPage.routeName: (_) => PasswordPage(),
  PropietarioForm.routeName: (_) => PropietarioForm(),
  ChatsPage.routeName: (_) => ChatsPage(),
};
