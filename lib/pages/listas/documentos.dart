import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/forms/documento.dart';
import 'package:verona_app/pages/visor_imagen.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class DocumentosPage extends StatelessWidget {
  const DocumentosPage({Key? key}) : super(key: key);
  static const String routeName = 'documentos-list';

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String driveId = arguments['driveId'] ?? '';
    return Scaffold(
      body: Container(
          color: Helper.brandColors[1],
          child: SafeArea(child: _DocumentosList())),
      floatingActionButton: CustomNavigatorButton(
        accion: () => Navigator.pushNamed(context, DocumentoForm.routeName,
            arguments: {"driveId": driveId}),
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
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String driveId = arguments['driveId'] ?? '';
    final _pref = new Preferences();

    return FutureBuilder(
        future: _driveService.obtenerDocumentos(_pref.id, driveId),
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
    late Function()? actionOnTap;
    // sort data by name

    widget.data.sort((a, b) {
      return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    });
    return Container(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
            itemCount: widget.data.length,
            itemBuilder: (_, i) {
              final iconAvatar = getIcon(widget.data[i]['mimeType']);
              bool esPar = false;

              i % 2 == 0 ? esPar = true : esPar = false;
              if (getType(widget.data[i]['mimeType']) == 'jpg') {
                actionOnTap = () => Navigator.pushNamed(
                    (context), ImagenViewer.routeName,
                    arguments: {'imagenId': widget.data[i]['id']});
              } else if (getType(widget.data[i]['mimeType']).toLowerCase() ==
                      'Carpeta'.toLowerCase()) {
                actionOnTap = () => Navigator.pushNamed(
                    (context), DocumentosPage.routeName,
                    arguments: {'driveId': widget.data[i]['id']});

                  }else if (widget.data[i]['mimeType'].toString().contains('shortcut')){
                    actionOnTap = () => Navigator.pushNamed(
                    (context), DocumentosPage.routeName,
                    arguments: {'driveId': widget.data[i]['shortcutDetails']['targetId']});

              } else {
                actionOnTap = () async {
                  final Uri _url = Uri.parse(
                      'https://drive.google.com/file/d/${widget.data[i]['id']}/view?usp=sharing');
                  if (await canLaunchUrl(_url))
                    await launchUrl(_url, mode: LaunchMode.externalApplication);
                  else
                    openAlertDialog(
                        context, 'No se puede visualizar el documento');
                };
              }
              return _CustomListTile(
                iconAvatar: iconAvatar,
                esPar: esPar,
                title: widget.data[i]['name'],
                subtitle: getType(widget.data[i]['mimeType']).toUpperCase(),
                actionOnTap: actionOnTap,
                fontSize: 15,
              );
            }));
  }

  String getType(type) {
    String extension = '';
    switch (type) {
      case 'application/pdf':
        extension = 'pdf';
        break;

      case 'image/jpeg':
        extension = 'jpg';
        break;

      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        extension = 'docx';
        break;

      case 'application/vnd.ms-excel':
        extension = 'Excel';
        break;
      case 'application/vnd.google-apps.folder':
        extension = 'Carpeta';
        break;
    }
    return extension;
  }

  IconData getIcon(type) {
    IconData icon = Icons.picture_as_pdf_outlined;
    switch (type) {
      case 'application/pdf':
        icon = Icons.picture_as_pdf_rounded;
        break;

      case 'image/jpeg':
        icon = Icons.image_outlined;
        break;

      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        icon = Icons.file_copy;
        break;

      case 'application/vnd.ms-excel':
        icon = Icons.calculate_outlined;
        break;

      case 'application/vnd.google-apps.folder':
        icon = Icons.folder_open;
        break;
      case 'application/vnd.google-apps.shortcut':
        icon = Icons.drive_folder_upload;
        break;
      default:
        icon = Icons.file_copy_outlined;
        break;
    }
    return icon;
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
                  child: Icon(iconAvatar, color: Helper.brandColors[8]),
                ),
              ),
              title: Text(title.toUpperCase(),
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Helper.brandColors[5],
                      fontSize: fontSize)),
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

/*

- Mensaje no leido
- Tarea checklist terminada
- Foto o video cargado
- Cambio de estado de pedido (solo integrantes del equipo)
- Nueva inactividad
-

*/
