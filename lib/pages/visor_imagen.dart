import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:verona_app/helpers/helpers.dart';

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ImagenViewer extends StatelessWidget {
  ImagenViewer({Key? key}) : super(key: key);
  static final routeName = 'imagen_viewer';
  late String url;
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final imagenId = arguments['imagenId'];
    url = 'https://drive.google.com/uc?export=view&id=$imagenId';
    final token =
        'ya29.A0ARrdaM_6GO94psBfX0G8FhqeJLZ2ItNjaOOVYcYBwRmNssneRoaF82hENqCcrQrVfMKrJEjtyEdVPO7nxiJUU3xZiKkYLTWrTm8-PSJV-kiuxErcHwX_2Vd31vi6VfS8XDw9IRwnalhvtTqzE2H2RP7z40NRNg';

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton(
                onPressed: () async {
                  openLoadingDialog(context, mensaje: 'Descargando imagen...');
                  final success = await guardarArchivo();
                  closeLoadingDialog(context);
                  if (success) {
                    openAlertDialog(context, 'Imagen descargada');
                  } else {
                    openAlertDialog(context, 'No se pudo descargar la imagen');
                  }
                },
                icon: Icon(Icons.download))
          ],
        ),
        body: PhotoView(
          imageProvider: Helper.imageNetwork(
            url,
            //url,
          ),
        ));
  }

  guardarArchivo() async {
    print(url);
    try {
      var response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
      );
      return true;
    } on dynamic catch (err) {
      print(err);
      return false;
    }
  }
}
