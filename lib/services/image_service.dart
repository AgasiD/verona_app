import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verona_app/helpers/Enviroment.dart';
import 'package:verona_app/services/http_service.dart';

class ImageService extends ChangeNotifier {
  HttpService _http = new HttpService();
  late XFile _img;
  late List<XFile> _imgs;
  String _apiKey = Environment.IMGBB_KEY;

  Future grabarImagen(String fileName, {String? driveId, XFile? imagen}) async {
    if (imagen != null) {
      _img = imagen;
    }
    if (_img != null) {
      final response = await this._http.cargarImagen(_img, "api.imgbb.com",
          "/1/upload", {"key": _apiKey, "name": fileName}); //name=${fileName}&
      final data = json.decode(response);
      return data;
    } else {
      print('No se asigno imagen');
    }
  }

  guardarImagen(XFile img) {
    this._img = img;
  }

  guardarImagenes(List<XFile> imgs) {
    this._imgs = imgs;
  }

  Future grabarImagenes(String driveId, String? nombre) async {
    int index = 1;
    List<String> ids = [];
    for (var img in _imgs) {
      this._img = img;
      final ts = DateTime.now().millisecondsSinceEpoch;
      String fileName = nombre ?? 'fromApp-$ts';
      if (nombre != null) {
        fileName = _imgs.length == 1 ? nombre : '$nombre ($index)';
      }
      final response =
          await grabarImagen(fileName, driveId: driveId, imagen: img);
      index = index + 1;
      ids.add(response);
    }
    ;
    notifyListeners();
    print('3');
    return ids;
  }

  obtenerCantidadImgSeleccionada() {
    return this._imgs.length;
  }

  imagenValida() {
    return this._img != null;
  }
}
