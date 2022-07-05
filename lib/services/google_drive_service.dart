import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/http_service.dart';

class GoogleDriveService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/drive';
  late XFile _img;
  late FilePickerResult _document;

  grabarImagen(String fileName) async {
    if (_img != null) {
      final datos =
          await this._http.uploadImage(_img, _endpoint + "/$fileName");
      print('imagen grabada');
      return datos;
    } else {
      print('No se asigno imagen');
    }
  }

  grabarDocumento(String fileName, String extension, String parent) async {
    try {
      if (_document != null) {
        final to = _endpoint + "/$fileName/$extension/$parent";

        final datos = await this._http.uploadDocument(_document, to);
        notifyListeners();
        return datos;
      } else {
        print('No ha asignado imagen');
      }
    } catch (err) {
      print('error');
    }
  }

  getExtension() {
    return _document.files.single.extension;
  }

  guardarImagen(XFile img) {
    this._img = img;
  }

  guardarDocumento(FilePickerResult document) {
    this._document = document;
  }

  obtenerDocumentos(String folderId) async {
    folderId = folderId == '' ? 'SinID' : folderId;
    final datos = await this._http.get('$_endpoint/inFolder/$folderId');
    final response = MyResponse.fromJson(datos['response']);

    return response;
  }

  imagenValida() {
    return this._img != null;
  }
}
