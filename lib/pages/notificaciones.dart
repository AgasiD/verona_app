import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({Key? key}) : super(key: key);
  static const String routeName = 'notificaciones';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: 'Notificaciones',
          muestraBackButton: true,
        ),
        body: _NotificationsList());
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({Key? key}) : super(key: key);
  final List<Map<String, IconData>> iconos = const [
    {'mensaje': Icons.mark_email_unread_outlined},
    {'check': Icons.check_box_outlined},
    {'media': Icons.photo_size_select_actual_rounded},
    {'doc': Icons.document_scanner_outlined},
    {'pedido': Icons.list_alt_rounded},
    {'inactivity': Icons.work_off_outlined},
    {'obra': Icons.house}
  ];
  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context);
    final _pref = new Preferences();
    return FutureBuilder(
        future: _usuarioService.obtenerNotificaciones(_pref.id),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Loading(mensaje: 'Recuperando notificaciones');
          } else {
            final response = snapshot.data as MyResponse;
            if (response.fallo) {
              openAlertDialog(context, response.error);
              return Container();
            } else {
              final notificaciones = response.data;
              if (notificaciones.length > 0) {
                _usuarioService.leerNotificaciones(_pref.id).then((value) {
                  //_usuarioService.notifyListeners();
                });
                return Container(
                  margin: EdgeInsets.only(top: 15),
                  child: ListView.builder(
                      itemCount: notificaciones.length,
                      itemBuilder: (BuildContext context, int i) {
                        final iconName = notificaciones[i]['type'];
                        String route = '';
                        Map<String, dynamic> arg = {};
                        switch (notificaciones[i]['type']) {
                          case 'obra':
                            route = ObraPage.routeName;
                            arg = {'obraId': notificaciones[i]['route']};
                            break;
                        }

                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.pushNamed(context, route,
                                    arguments: arg);
                              },
                              title: Text(notificaciones[i]['title']),
                              subtitle: Text(
                                notificaciones[i]['subtitle'],
                                style: TextStyle(fontSize: 14),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: !notificaciones[i]['leido']
                                    ? Color.fromARGB(255, 101, 171, 180)
                                    : Colors.white,
                                foregroundColor: notificaciones[i]['leido']
                                    ? Colors.blue
                                    : Colors.white,
                                child: Icon(iconos
                                    .where((element) =>
                                        element.containsKey(iconName))
                                    .first[iconName]),
                              ),
                              trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.arrow_forward_ios_rounded),
                                    Text(
                                      Helper.getFechaHoraFromTS(
                                          notificaciones[i]['ts']),
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  ]),
                            ),
                            Divider(
                              height: 25,
                            ),
                          ],
                        );
                      }),
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

/*

- Mensaje no leido
- Tarea checklist terminada
- Foto o video cargado
- Cambio de estado de pedido (solo integrantes del equipo)
- Nueva inactividad
-

*/
