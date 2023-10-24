import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/error.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({Key? key}) : super(key: key);
  static const String routeName = 'notificaciones';

  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketService>(context);
    final _pref = new Preferences();
    _socketService.connect(_pref.id);
    return Scaffold(
      body: Container(
          color: Helper.brandColors[1],
          child: SafeArea(child: _NotificationsList())),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context);

    final _pref = new Preferences();
    return FutureBuilder(
        future: _usuarioService.obtenerNotificaciones(_pref.id),
        builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
            return Loading(mensaje: 'Recuperando notificaciones');
         } else if(snapshot.hasError){
                return ErrorPage(errorMsg: snapshot.error.toString(), page: false);
              }
          else {
            final response = snapshot.data as MyResponse;
            if (response.fallo) {
              openAlertDialog(context, response.error);
              return Container();
            } else {
              final notificaciones = response.data;
              if (notificaciones.length > 0) {
                // dividir por por fechas entre hoy y el resto
                return FutureBuilder(
                  future: _usuarioService.leerNotificaciones(_pref.id),
                  builder: (context, snapshot) 
                  {
                    // final _socketService = Provider.of<SocketService>(context, listen: false);
                    // _socketService.notifyListeners();
                    return Container(
                      margin: EdgeInsets.only(top: 15),
                      child: _CustomListView(
                        data: notificaciones,
                      ));},
                );
              } else {
                return Container(
                  child: Center(
                    child: Text(
                      'Aún no tiene notificaciones',
                      style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                    ),
                  ),
                );
              }
            }
          }
        });
  }
}

class _CustomListView extends StatefulWidget {
  _CustomListView({
    Key? key,
    required this.data,
  }) : super(key: key);
  List<dynamic> data;

  @override
  State<_CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends State<_CustomListView> {
  final List<Map<String, IconData>> iconos = const [
    {'mensaje': Icons.mark_email_unread_outlined},
    {'check': Icons.check_box_outlined},
    {'media': Icons.photo_size_select_actual_rounded},
    {'doc': Icons.document_scanner_outlined},
    {'pedido': Icons.request_page_outlined},
    {'inactivity': Icons.work_off_outlined},
    {'obra': Icons.house},
    {'notification': Icons.notifications_active},
    {'update_app': Icons.download},

  ];
  @override
  Widget build(BuildContext context) {
    late dynamic iconAvatar;
    late Function()? actionOnTap;
    final notificaciones = ordenarNotificaciones(widget.data);

    return Container(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
            itemCount: notificaciones.length,
            itemBuilder: (_, i) {
              if (notificaciones[i] is Container) {
                return notificaciones[i];
              } else {
                bool esPar = false;
                if (i % 2 == 0) {
                  esPar = true;
                }
                final notificacion = notificaciones[i];
                iconAvatar = iconos
                    .where(
                        (element) => element.containsKey(notificacion['type']??'notification'))
                    .first[notificacion['type']??'notification'];

                String route = '';
                Map<String, dynamic> arg = {};
                switch (notificacion['type']) {
                  case 'obra':
                    if (notificacion['route'] != '') {
                      route = ObraPage.routeName;
                      arg = {'obraId': notificacion['route']};
                    } else {
                      route = '';
                      arg = {};
                    }
                    break;
                  case 'pedido':
                    if (notificacion['route'] != '') {
                      route = PedidoForm.routeName;
                      arg = {'pedidoId': notificacion['route']};
                    } else {
                      route = '';
                      arg = {};
                    }
                    break;
                  case 'update_app':
                  route = 'update';
                  actionOnTap = () async {
                    print('tap');
                    await Helper.launchWeb(Helper.getURLByPlatform(), context);
                    };
                }
                if (route == '' && notificacion['type'] != 'update_app') {
                  actionOnTap = null;
                } else if(route != '' && notificacion['type'] != 'update_app') {
                  actionOnTap = () =>
                      Navigator.pushNamed((context), route, arguments: arg);
                }

                return _CustomListTile(
                  iconAvatar: iconAvatar,
                  esPar: esPar,
                  title: notificacion['title'],
                  subtitle: notificacion['subtitle'],
                  ts: notificacion['ts'],
                  actionOnTap: actionOnTap,
                );
              }
            }));
  }

  ordenarNotificaciones(List data) {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final tsToday = today.millisecondsSinceEpoch;
    final tsAyer = today.subtract(Duration(days: 1)).millisecondsSinceEpoch;
    List notificaciones = [];

// Notificaciones HOY
    final notificacionesNoLeidas =
        widget.data.where((notif) => !notif['leido']);

    if (notificacionesNoLeidas.length > 0) {
      notificaciones.add(Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'No leídas',
            style: TextStyle(
                fontSize: 15,
                color: Helper.brandColors[8],
                fontWeight: FontWeight.bold),
          )));
      notificaciones.addAll(notificacionesNoLeidas);
    }

    // Notificaciones HOY
    final notificacionesHoy =
        widget.data.where((notif) => tsToday < notif['ts'] && notif['leido']);

    if (notificacionesHoy.length > 0) {
      notificaciones.add(Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'Hoy',
            style: TextStyle(
                fontSize: 15,
                color: Helper.brandColors[8],
                fontWeight: FontWeight.bold),
          )));
      notificaciones.addAll(notificacionesHoy);
    }

    final notificacionesAyer = widget.data.where((notif) =>
        tsAyer < notif['ts'] && tsToday > notif['ts'] && notif['leido']);

    if (notificacionesAyer.length > 0) {
      notificaciones.add(
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'Ayer',
            style: TextStyle(
                fontSize: 15,
                color: Helper.brandColors[8],
                fontWeight: FontWeight.bold),
          ),
        ),
      );
      notificaciones.addAll(notificacionesAyer);
    }
    notificaciones.add(
      Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'Previas',
            style: TextStyle(
                fontSize: 15,
                color: Helper.brandColors[8],
                fontWeight: FontWeight.bold),
          )),
    );
    notificaciones.addAll(
        widget.data.where((notif) => tsAyer >= notif['ts'] && notif['leido']));

    final notificacionesAnteriores =
        widget.data.where((notif) => tsAyer >= notif['ts']);
    return notificaciones;
  }
}

class _CustomListTile extends StatelessWidget {
  bool esPar;
  String title;
  String subtitle;
  double padding;
  double fontSize;
  int ts;
  dynamic iconAvatar;
  Function()? actionOnTap;
  _CustomListTile(
      {Key? key,
      required this.esPar,
      required this.title,
      required this.subtitle,
      this.iconAvatar = Icons.abc,
      this.padding = 5,
      this.fontSize = 17,
      this.ts = 0,
      this.actionOnTap = null})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = esPar ? Helper.brandColors[2] : Helper.brandColors[1];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: this.padding),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: _color, borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                    color:
                        !esPar ? Helper.brandColors[8].withOpacity(.8) : null,
                    borderRadius: BorderRadius.circular(100)),
                child: CircleAvatar(
                  backgroundColor: Helper.brandColors[0],
                  child: Icon(iconAvatar),
                ),
              ),
              title: Text(title,
                  style: TextStyle(
                      color: Helper.brandColors[5], fontSize: fontSize)),
              subtitle: this.subtitle != ''
                  ? Row(
                      children: [
                        Container(
                          // color: Colors.green,
                          width: MediaQuery.of(context).size.width - 170,
                          child: Text(
                            subtitle,
                            style: TextStyle(
                                color: Helper.brandColors[8].withOpacity(.8)),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.bottomRight,
                            // color: Colors.red,
                            width: 70,
                            child: Text(
                              Helper.getFechaHoraFromTS(this.ts,
                                  fechaSinHora: true),
                              style: TextStyle(color: Helper.brandColors[3]),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      alignment: Alignment.bottomRight,
                      // color: Colors.red,
                      width: 70,
                      child: Text(
                        Helper.getFechaHoraFromTS(this.ts, fechaSinHora: true),
                        style: TextStyle(color: Helper.brandColors[3]),
                      ),
                    ),
              onTap: actionOnTap,

              // trailing: actionOnTap == null
              //     ? null
              //     : Icon(
              //         Icons.arrow_forward_ios_rounded,
              //         color: Helper.brandColors[3],
              //       ),
            ),
          ),
        ],
      ),
    );
    ;
  }
}



// ListView.builder(
//                       itemCount: notificaciones.length,
//                       itemBuilder: (BuildContext context, int i) {
//                         final iconName = notificaciones[i]['type'];
//                         String route = '';
//                         Map<String, dynamic> arg = {};
//                         switch (notificaciones[i]['type']) {
//                           case 'obra':
//                             route = ObraPage.routeName;
//                             arg = {'obraId': notificaciones[i]['route']};
//                             break;
//                         }

//                         return Column(
//                           children: [
//                             ListTile(
//                               onTap: () {
//                                 Navigator.pushNamed(context, route,
//                                     arguments: arg);
//                               },
//                               title: Text(notificaciones[i]['title']),
//                               subtitle: Text(
//                                 notificaciones[i]['subtitle'],
//                                 style: TextStyle(fontSize: 14),
//                               ),
//                               leading: CircleAvatar(
//                                 backgroundColor: !notificaciones[i]['leido']
//                                     ? Color.fromARGB(255, 101, 171, 180)
//                                     : Colors.white,
//                                 foregroundColor: notificaciones[i]['leido']
//                                     ? Colors.blue
//                                     : Colors.white,
//                                 child: Icon(iconos
//                                     .where((element) =>
//                                         element.containsKey(iconName))
//                                     .first[iconName]),
//                               ),
//                               trailing: Column(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Icon(Icons.arrow_forward_ios_rounded),
//                                     Text(
//                                       Helper.getFechaHoraFromTS(
//                                           notificaciones[i]['ts']),
//                                       style: TextStyle(color: Colors.grey),
//                                     )
//                                   ]),
//                             ),
//                             Divider(
//                               height: 25,
//                             ),
//                           ],
//                         );
//                       }),

/*

- Mensaje no leido
- Tarea checklist terminada
- Foto o video cargado
- Cambio de estado de pedido (solo integrantes del equipo)
- Nueva inactividad
-

*/
