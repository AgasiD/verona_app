import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class DocumentosPage extends StatelessWidget {
  const DocumentosPage({Key? key}) : super(key: key);
  static const String routeName = 'documentos-list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Helper.brandColors[1],
          child: SafeArea(child: _DocumentosList())),
      floatingActionButton: CustomNavigatorButton(
        accion: () => Navigator.pushNamed(context, ChatPage.routeName),
        icono: Icons.add,
        showNotif: false,
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _DocumentosList extends StatelessWidget {
  const _DocumentosList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context, listen: false);
    final _driveService = Provider.of<GoogleDriveService>(context);
    return FutureBuilder(
        future:
            _driveService.obtenerDocumentos(_obraService.obra.driveFolderId!),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Loading(mensaje: 'Recuperando documentos');
          } else {
            final response = snapshot.data as MyResponse;
            if (response.fallo) {
              return Container(
                child: Center(
                  child: Text(
                    'Error al recuperar documentos',
                    style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                  ),
                ),
              );
            } else {
              final documentos = response.data['files'];
              if (documentos.length > 0) {
                return Container(
                    margin: EdgeInsets.only(top: 15),
                    child: _CustomListView(
                      data: documentos,
                    ));
              } else {
                return Container(
                  child: Center(
                    child: Text(
                      'Aún no existen documentos',
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
    {'pedido': Icons.list_alt_rounded},
    {'inactivity': Icons.work_off_outlined},
    {'obra': Icons.house}
  ];
  @override
  Widget build(BuildContext context) {
    late dynamic iconAvatar;
    late Function()? actionOnTap;
    return Container(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
            itemCount: widget.data.length,
            itemBuilder: (_, i) {
              bool esPar = false;
              if (i % 2 == 0) {
                esPar = true;
              }
              iconAvatar = Icons.picture_as_pdf_outlined;

              String route = '';
              Map<String, dynamic> arg = {};

              if (route == '') {
                actionOnTap = null;
              } else {
                actionOnTap =
                    () => Navigator.pushNamed((context), route, arguments: arg);
              }

              return _CustomListTile(
                iconAvatar: iconAvatar,
                esPar: esPar,
                title: widget.data[i]['name'],
                subtitle: 'PDF',
                actionOnTap: actionOnTap,
              );
            }));
  }
}

class _CustomListTile extends StatelessWidget {
  bool esPar;
  String title;
  String subtitle;
  double padding;
  double fontSize;
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
      this.actionOnTap = null})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = esPar ? Helper.brandColors[2] : Helper.brandColors[1];
    final texts = title.split('.');

    final titleAux = texts.first;
    subtitle = texts.last.toUpperCase();

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
              title: Text(titleAux,
                  style: TextStyle(
                      color: Helper.brandColors[5], fontSize: fontSize)),
              subtitle: this.subtitle != ''
                  ? Text(
                      subtitle,
                      style: TextStyle(
                          color: Helper.brandColors[8].withOpacity(.8)),
                    )
                  : null,
              trailing: actionOnTap == null
                  ? null
                  : Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Helper.brandColors[3],
                    ),
              onTap: actionOnTap,
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
