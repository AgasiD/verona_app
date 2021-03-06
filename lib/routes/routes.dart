import 'package:flutter/widgets.dart';
import 'package:verona_app/pages/Form.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/asignar_equipo.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/contactos.dart';
import 'package:verona_app/pages/forms/documento.dart';
import 'package:verona_app/pages/forms/imagen-doc.dart';
import 'package:verona_app/pages/forms/inactividad.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/imagenes_gallery.dart';
import 'package:verona_app/pages/inactividades.dart';
import 'package:verona_app/pages/listas/chats.dart';
import 'package:verona_app/pages/listas/documentos.dart';
import 'package:verona_app/pages/listas/equipo.dart';
import 'package:verona_app/pages/listas/pedidos_obra.dart';
import 'package:verona_app/pages/listas/propietarios.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/notificaciones.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/pages/password.dart';
import 'package:verona_app/pages/pedidos.dart';
import 'package:verona_app/pages/prueba.dart';
import 'package:verona_app/pages/visor_imagen.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  AgregarPropietariosPage.routeName: (_) => AgregarPropietariosPage(),
  AsignarEquipoPage.routeName: (_) => AsignarEquipoPage(),
  ChatPage.routeName: (_) => ChatPage(),
  ChatList.routeName: (_) => ChatList(),
  ContactsPage.routeName: (_) => ContactsPage(),
  DocumentoForm.routeName: (_) => DocumentoForm(),
  DocumentosPage.routeName: (_) => DocumentosPage(),
  EquipoList.routeName: (_) => EquipoList(),
  FormPage.routeName: (_) => FormPage(),
  ImagenViewer.routeName: (_) => ImagenViewer(),
  ImgGalleryPage.routeName: (_) => ImgGalleryPage(),
  ImagenesForm.routeName: (_) => ImagenesForm(),
  InactividadesPage.routeName: (_) => InactividadesPage(),
  InactividadesForm.routeName: (_) => InactividadesForm(),
  LoginPage.routeName: (_) => LoginPage(),
  MiembroForm.routeName: (_) => MiembroForm(),
  NotificacionesPage.routeName: (_) => NotificacionesPage(),
  ObraForm.routeName: (_) => ObraForm(),
  ObraPage.routeName: (_) => ObraPage(),
  ObrasPage.routeName: (_) => ObrasPage(),
  PasswordPage.routeName: (_) => PasswordPage(),
  PedidoForm.routeName: (_) => PedidoForm(),
  PedidoList.routeName: (_) => PedidoList(),
  PedidosPage.routeName: (_) => PedidosPage(),
  PropietarioForm.routeName: (_) => PropietarioForm(),
  PropietariosList.routeName: (_) => PropietariosList(),
  Prueba.routeName: (_) => Prueba(),
};
