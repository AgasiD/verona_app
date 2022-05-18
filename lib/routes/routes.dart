import 'package:flutter/widgets.dart';
import 'package:verona_app/pages/Form.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/asignar_equipo.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/chats.dart';
import 'package:verona_app/pages/contactos.dart';
import 'package:verona_app/pages/forms/inactividad.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/inactividades.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/notificaciones.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/pages/password.dart';
import 'package:verona_app/pages/pedidos.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  AgregarPropietariosPage.routeName: (_) => AgregarPropietariosPage(),
  AsignarEquipoPage.routeName: (_) => AsignarEquipoPage(),
  ChatPage.routeName: (_) => ChatPage(),
  ChatsPage.routeName: (_) => ChatsPage(),
  ContactsPage.routeName: (_) => ContactsPage(),
  FormPage.routeName: (_) => FormPage(),
  InactividadesPage.routeName: (_) => InactividadesPage(),
  InactividadesForm.routeName: (_) => InactividadesForm(),
  LoginPage.routeName: (_) => LoginPage(),
  MiembroForm.routeName: (_) => MiembroForm(),
  NotificacionesPage.routeName: (_) => NotificacionesPage(),
  ObraForm.routeName: (_) => ObraForm(),
  ObraPage.routeName: (_) => ObraPage(),
  ObrasPage.routeName: (_) => ObrasPage(),
  PasswordPage.routeName: (_) => PasswordPage(),
  PedidosPage.routeName: (_) => PedidosPage(),
  PedidoForm.routeName: (_) => PedidoForm(),
  PropietarioForm.routeName: (_) => PropietarioForm(),
};
