import 'package:flutter/widgets.dart';
import 'package:verona_app/pages/ABMs/ControlObra.dart';
import 'package:verona_app/pages/ABMs/InactividadesABM.dart';
import 'package:verona_app/pages/ABMs/PedidosPanelControl.dart';
import 'package:verona_app/pages/Form.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/anotaciones.dart';
import 'package:verona_app/pages/asignar_equipo.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/forms/etapa.dart';
import 'package:verona_app/pages/forms/inactividades_masiva.dart';
import 'package:verona_app/pages/forms/subetapa.dart';
import 'package:verona_app/pages/forms/Etapa_Sub_Tarea.dart';
import 'package:verona_app/pages/listas/asigna_etapas_extras.dart';
import 'package:verona_app/pages/listas/asigna_subetapas_extras.dart';
import 'package:verona_app/pages/listas/asigna_tareas_extras.dart';
import 'package:verona_app/pages/listas/contactos.dart';
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
import 'package:verona_app/pages/listas/etapas.dart';
import 'package:verona_app/pages/listas/pedidos_obra.dart';
import 'package:verona_app/pages/listas/pedidos_obra_archivados.dart';
import 'package:verona_app/pages/listas/personal_adm.dart';
import 'package:verona_app/pages/listas/propietarios.dart';
import 'package:verona_app/pages/listas/propietarios_adm.dart';
import 'package:verona_app/pages/listas/subetapas.dart';
import 'package:verona_app/pages/listas/tareas.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/notificaciones.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/pages/password.dart';
import 'package:verona_app/pages/listas/pedidos.dart';
import 'package:verona_app/pages/perfil.dart';
import 'package:verona_app/pages/prueba.dart';
import 'package:verona_app/pages/search_message.dart';
import 'package:verona_app/pages/visor_imagen.dart';
import 'package:verona_app/widgets/map_coordinates.dart';

import '../pages/forms/inactividadesBD.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'prueba': (_) => ReorderableApp(),
  AgregarPropietariosPage.routeName: (_) => AgregarPropietariosPage(),
  AnotacionesPage.routeName: (_) => AnotacionesPage(),
  AsignarEquipoPage.routeName: (_) => AsignarEquipoPage(),
  ChatList.routeName: (_) => ChatList(),
  ChatPage.routeName: (_) => ChatPage(),
  ContactsPage.routeName: (_) => ContactsPage(),
  ControlObraABM.routeName: (_) =>ControlObraABM(),
  DocumentoForm.routeName: (_) => DocumentoForm(),
  DocumentosPage.routeName: (_) => DocumentosPage(),
  EquipoList.routeName: (_) => EquipoList(),
  Etapa_Form.routeName: (_) => Etapa_Form(),
  Etapa_Sub_Tarea_Form.routeName: (_) => Etapa_Sub_Tarea_Form(),
  EtapasExtrasPage.routeName: (_) => EtapasExtrasPage(),
  EtapasObra.routeName: (_) => EtapasObra(),
  FormPage.routeName: (_) => FormPage(),
  ImagenesForm.routeName: (_) => ImagenesForm(),
  ImagenViewer.routeName: (_) => ImagenViewer(),
  ImgGalleryPage.routeName: (_) => ImgGalleryPage(),
  InactividadesABM.routeName: (_) =>InactividadesABM(),
  InactividadesForm.routeName: (_) => InactividadesForm(),
  InactividadesBDForm.routeName: (_) => InactividadesBDForm(),
  InactividadesPage.routeName: (_) => InactividadesPage(),
  InactividadesMasivaForm.routeName : (_) => InactividadesMasivaForm(),
  LoginPage.routeName: (_) => LoginPage(),
  MapCoordenates .routeName: (_) =>MapCoordenates(),
  MiembroForm.routeName: (_) => MiembroForm(),
  NotificacionesPage.routeName: (_) => NotificacionesPage(),
  ObraForm.routeName: (_) => ObraForm(),
  ObraPage.routeName: (_) => ObraPage(),
  ObrasPage.routeName: (_) => ObrasPage(),
  PasswordPage.routeName: (_) => PasswordPage(),
  PedidoForm.routeName: (_) => PedidoForm(),
  PedidoList.routeName: (_) => PedidoList(),
  PedidosArchivadosList.routeName: (_) => PedidosArchivadosList(),
  PedidosPage.routeName: (_) => PedidosPage(),
  PedidosPanelControl.routeName: (_) =>PedidosPanelControl(),
  PerfilPage.routeName: (_) => PerfilPage(),
  PersonalADM.routeName: (_) => PersonalADM(),
  PropietarioForm.routeName: (_) => PropietarioForm(),
  PropietariosADM.routeName: (_) => PropietariosADM(),
  PropietariosList.routeName: (_) => PropietariosList(),
  Search_Message_Screen.routeName: (_) => Search_Message_Screen(),
  Subetapa_Form.routeName: (_) => Subetapa_Form(),
  SubetapasExtrasPage.routeName: (_) => SubetapasExtrasPage(),
  SubEtapasObra.routeName: (_) => SubEtapasObra(),
  TareasCheckList.routeName: (_) => TareasCheckList(),
  TareasExtrasPage.routeName: (_) => TareasExtrasPage(),
  };
