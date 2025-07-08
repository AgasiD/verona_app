import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:verona_app/services/http_service.dart';

class GoogleDriveService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/files';
  late XFile _img;
  late List<XFile> _imgs;
  late List<XFile?>? imgsPedido;
  String rootDrive = '1yT0HU9X49RQGy6jK0rTE0FX0RFJwBfkf';
  late FilePickerResult _document;

  Future grabarImagen(String fileName, {String? driveId, XFile? imagen}) async {
    if (driveId != null) {
      rootDrive = driveId;
    }
    if (imagen != null) {
      _img = imagen;
    }
    if (_img != null) {
      final response = await this
          ._http
          .uploadImage(_img, _endpoint + "/$fileName/jpg/$rootDrive");

      final data = json.decode(response.body);

      if (response.statusCode >= 300) {
        throw new Exception('Error ${data['message']} ${response.statusCode}');
      }

      return data;
    } else {
      print('No se asigno imagen');
    }
  }

  grabarImagenPedido(String fileName, String driveFolderId, XFile image) async {
    if(driveFolderId.isEmpty) throw new Exception('Carpeta de imágenes no asignada') ;
    if (imgsPedido != null) {
      final idFolder = driveFolderId;
      final responseBody = await this
          ._http
          .uploadImage(image, _endpoint + "/$fileName/jpg/$idFolder");
      Map<String, dynamic> data = jsonDecode(responseBody);
      final fileId = data['id'];
      return fileId;
    } else {
      throw new Exception('Imagen sin asignar');
    }
  }

  grabarDocumento(String fileName, String extension, String parent) async {
    if (_document != null) {
      final to = _endpoint + "/$fileName/$extension/$parent";
      final response = await this._http.uploadDocument(_document, to);
      final data = json.decode(response.body);

      if (response.statusCode >= 300) {
        throw new Exception('Error ${data['message']} ${response.statusCode}');
      }

      notifyListeners();
      return data;
    } else {
      print('No ha asignado imagen');
    }
  }

  getExtension() {
    return _document.files.single.extension;
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
    return ids;
  }

  obtenerCantidadImgSeleccionada() {
    return this._imgs.length;
  }

  guardarImagenPedido(List<XFile?>? img) {
    this.imgsPedido = img;
  }

  guardarDocumento(FilePickerResult document) {
    this._document = document;
  }

  obtenerDocumentos(String usuarioId, String folderId) async {
    folderId = folderId == '' ? 'SinID' : folderId;
    final response =
        await this._http.get('$_endpoint/documentos/$usuarioId/$folderId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    return data;
  }

  imagenValida() {
    return this._img != null;
  }

  crearCarpeta(nombre, driveId) async {
    final body = {
      "nombre": nombre,
      "driveId": driveId,
    };
    final response = await this._http.post('$_endpoint/folder', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    return data;
  }
}
