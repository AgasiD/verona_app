import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/forms/documento.dart';
import 'package:verona_app/pages/visor_imagen.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ImgGalleryPage extends StatelessWidget {
  ImgGalleryPage({Key? key}) : super(key: key);
  static final routeName = 'imageGallery';
  final _pref = new Preferences();

  @override
  Widget build(BuildContext context) {
    final _driveService = Provider.of<GoogleDriveService>(context);
    final _obraService = Provider.of<ObraService>(context);
    String _driveId = _obraService.obra.imgFolderId;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _driveId = arguments['driveId'];
    }

    return Scaffold(
      bottomNavigationBar: CustomNavigatorFooter(),
      floatingActionButton: CustomNavigatorButton(
        accion: () => Navigator.pushNamed(context, DocumentoForm.routeName,
            arguments: {'driveId': _driveId}),
        icono: Icons.add,
        showNotif: false,
      ),
      body: Container(
          color: Helper.brandColors[1],
          child: _driveId == ''
              ? Center(
                  child: Text(
                    'Error al buscar carpeta de Google Drive',
                    style:
                        TextStyle(fontSize: 20, color: Helper.brandColors[4]),
                  ),
                )
              : FutureBuilder(
                  future: _driveService.obtenerDocumentos(_driveId),
                  builder: ((context, snapshot) {
                    if (snapshot.data == null) {
                      return Loading(mensaje: 'Recuperando imagenes');
                    } else {
                      final response = snapshot.data as MyResponse;
                      var files = response.data['files'] as List<dynamic>;

                      // Filtro por habilitados para cliente
                      if (_pref.role == 3) {
                        files = files
                            .where((file) => _obraService.obra.enabledFiles
                                .contains(file['id']))
                            .toList();
                      }

                      if (files.isEmpty) {
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                'Aún no hay documentos disponibles ',
                                style: TextStyle(
                                    fontSize: 20, color: Helper.brandColors[4]),
                              ),
                            ));
                      } else {
                        final imagenes = files
                            .map(
                              (e) => GestureDetector(
                                onTap: () async {
                                  // if (e['mimeType'] ==
                                  //     'application/vnd.google-apps.folder') {
                                  //   Navigator.pushNamed(
                                  //       context, ImgGalleryPage.routeName,
                                  //       arguments: {"driveId": e['id']});
                                  // } else {
                                  //   Navigator.pushNamed(
                                  //       context, ImagenViewer.routeName,
                                  //       arguments: {"imagenId": e['id']});
                                  // }

                                  // if (getType(e['mimeType']) == 'jpg') {
                                  //   Navigator.pushNamed(
                                  //       (context), ImagenViewer.routeName,
                                  //       arguments: {'imagenId': e['id']});
                                  // } else
                                  if (getType(e['mimeType']).toLowerCase() ==
                                      'Carpeta'.toLowerCase()) {
                                    Navigator.pushNamed(
                                        (context), ImgGalleryPage.routeName,
                                        arguments: {'driveId': e['id']});
                                  } else {
                                    final Uri _url = Uri.parse(
                                        'https://drive.google.com/file/d/${e['id']}');

                                    // var isAppInstalledResult =
                                    //     await LaunchApp.isAppInstalled(
                                    //   androidPackageName:
                                    //       'net.pulsesecure.pulsesecure',
                                    //   iosUrlScheme: 'pulsesecure://',
                                    //   // openStore: false
                                    // );
                                    // var openAppResult = await LaunchApp.openApp(
                                    //     androidPackageName:
                                    //         'net.pulsesecure.pulsesecure',
                                    //     iosUrlScheme: 'pulsesecure://',
                                    //     appStoreLink:
                                    //         'itms-apps://apps.apple.com/ar/app/google-drive-almacenamiento/id507874739'
                                    //     // openStore: false
                                    //     );

                                    if (await canLaunchUrl(_url))
                                      await launchUrl(_url,
                                          mode: LaunchMode.externalApplication);
                                    else
                                      openAlertDialog(context,
                                          'No se puede visualizar el documento');
                                  }
                                  ;
                                },
                                child: Column(
                                  children: [
                                    e['mimeType'] ==
                                            'application/vnd.google-apps.folder'
                                        ? Icon(
                                            Icons.folder,
                                            size: 130,
                                            color: Helper.brandColors[3],
                                          )
                                        : FadeInImage(
                                            height: 150,
                                            imageErrorBuilder: (_, obj, st) {
                                              return Container(
                                                  child: Image(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .47,
                                                      image: AssetImage(
                                                          'assets/image.png')));
                                            },
                                            fadeInDuration:
                                                Duration(milliseconds: 500),
                                            placeholder:
                                                AssetImage('assets/image.png'),
                                            image: Helper.imageNetwork(
                                                e['thumbnailLink'] ??
                                                    'https://www.iconpacks.net/icons/2/free-file-icon-1453-thumb.png'
                                                // 'https://drive.google.com/uc?export=view&id=${e['id']}'
                                                )),
                                    Text(
                                      e['name'],
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Helper.brandColors[3]),
                                    )
                                  ],
                                ),
                              ),
                            )
                            .toList();
                        return GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 15,
                          children: imagenes,
                        );
                      }
                    }
                  }),
                )),
    );
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
}
