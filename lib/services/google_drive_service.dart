import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/http_service.dart';

class GoogleDriveService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/drive';
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
      final datos = await this
          ._http
          .uploadImage(_img, _endpoint + "/$fileName/jpg/$rootDrive");
      return datos;
    } else {
      print('No se asigno imagen');
    }
  }

  grabarImagenPedido(String fileName, String driveFolderId, XFile image) async {
    if (imgsPedido != null) {
    final idFolder = driveFolderId;
      final datos = await this
          ._http
          .uploadImage(image, _endpoint + "/$fileName/jpg/$idFolder");
      final autorizar = await setPermisosToFile(datos);

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

  setPermisosToFile(String fileId) async {
    final datos = await this._http.post('$_endpoint/setPermisos/$fileId', {});
    // final response = MyResponse.fromJson(datos['response']);
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
    final datos = await this._http.get('$_endpoint/inFolder/$usuarioId/$folderId');
    final response = MyResponse.fromJson(datos['response']);

    return response;
  }

  imagenValida() {
    return this._img != null;
  }

  crearCarpeta(nombre, driveId) async {
    final body = {
      "nombre": nombre,
      "driveId": driveId,
    };
    final data = await this._http.post('$_endpoint/folder', body);
    final response = MyResponse.fromJson(data['response']);
    notifyListeners();
    return response;
  }
}
