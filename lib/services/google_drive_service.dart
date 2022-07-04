import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/http_service.dart';

class GoogleDriveService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/drive';
  late XFile _img;
  grabarImagen(String fileName) async {
    if (_img != null) {
      final datos = await this._http.upload(_img, _endpoint + "/$fileName");
      print('imagen grabada');
      return datos;
    } else {
      print('No se asigno imagen');
    }
  }

  guardarImagen(XFile img) {
    this._img = img;
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
