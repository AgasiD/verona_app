import 'package:carousel_slider/carousel_slider.dart';
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
  late List imageIds;
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
   imageIds = arguments['imageIds'];
    // url = 'https://drive.google.com/uc?export=view&id=$imagenId';
    final token =
        'ya29.A0ARrdaM_6GO94psBfX0G8FhqeJLZ2ItNjaOOVYcYBwRmNssneRoaF82hENqCcrQrVfMKrJEjtyEdVPO7nxiJUU3xZiKkYLTWrTm8-PSJV-kiuxErcHwX_2Vd31vi6VfS8XDw9IRwnalhvtTqzE2H2RP7z40NRNg';

    return Scaffold(
      backgroundColor: Colors.black,
      
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton(
                onPressed: () async {
                  openLoadingDialog(context, mensaje: 'Descargando imagenes...');
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
        body: _CustomCarousel(imageIds: imageIds)
            
        );
  }



  guardarArchivo() async {
    try {
      for (var img in imageIds) {
          String url = 'https://drive.google.com/uc?export=view&id=$img'; 
      var response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
      );
           }
      return true;
    } on dynamic catch (err) {
      print(err);
      return false;
    }
  }
}

class _CustomCarousel extends StatelessWidget {
   _CustomCarousel({Key? key, required this.imageIds}) : super(key: key);

  List imageIds;
  String url = 'https://drive.google.com/uc?export=view&id=';

  @override
  Widget build(BuildContext context) {
    final images = this.imageIds.map((e) => PhotoView(
          imageProvider: Helper.imageNetwork(
            'https://drive.google.com/uc?export=view&id=$e',
          ),
        ),).toList();

        return CarouselSlider(
  options: CarouselOptions(height: MediaQuery.of(context).size.height * .8),
  items: imageIds.map((i) {
    return Builder(
      builder: (BuildContext context) {
        return Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: Colors.amber
            ),
            child: PhotoView(imageProvider:Helper.imageNetwork(
              'https://drive.google.com/uc?export=view&id=$i',))),
        );
        
      },
    );
  }).toList(),
);
  }}

