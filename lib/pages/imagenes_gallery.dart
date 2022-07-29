import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/forms/imagen-doc.dart';
import 'package:verona_app/pages/visor_imagen.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ImgGalleryPage extends StatelessWidget {
  const ImgGalleryPage({Key? key}) : super(key: key);
  static final routeName = 'imageGallery';

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
        accion: () => Navigator.pushNamed(context, ImagenesForm.routeName,
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
                      final files = response.data['files'] as List<dynamic>;
                      if (files.isEmpty) {
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                'Aún no hay imagenes subidas',
                                style: TextStyle(
                                    fontSize: 20, color: Helper.brandColors[4]),
                              ),
                            ));
                      } else {
                        final imagenes = files
                            .map(
                              (e) => GestureDetector(
                                onTap: () {
                                  if (e['mimeType'] ==
                                      'application/vnd.google-apps.folder') {
                                    Navigator.pushNamed(
                                        context, ImgGalleryPage.routeName,
                                        arguments: {"driveId": e['id']});
                                  } else {
                                    Navigator.pushNamed(
                                        context, ImagenViewer.routeName,
                                        arguments: {"imagenId": e['id']});
                                  }
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
                                            height: 170,
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
                                                'https://drive.google.com/uc?export=view&id=${e['id']}')),
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
}
