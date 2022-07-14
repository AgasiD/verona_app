import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagenViewer extends StatelessWidget {
  const ImagenViewer({Key? key}) : super(key: key);
  static final routeName = 'imagen_viewer';
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final imagenId = arguments['imagenId'];

    final token =
        'ya29.A0ARrdaM_6GO94psBfX0G8FhqeJLZ2ItNjaOOVYcYBwRmNssneRoaF82hENqCcrQrVfMKrJEjtyEdVPO7nxiJUU3xZiKkYLTWrTm8-PSJV-kiuxErcHwX_2Vd31vi6VfS8XDw9IRwnalhvtTqzE2H2RP7z40NRNg';
    return Container(
        child: PhotoView(
      imageProvider: NetworkImage(
          'https://drive.google.com/uc?export=view&id=$imagenId',
          headers: {"Authorization": "Bearer $token"}),
    ));
  }
}