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
  late XFile _imgPedido;
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

  grabarImagenPedido(String fileName, String driveFolderId) async {
    if (_imgPedido != null) {
      //obtener drive id de carpeta imagenes -> pedido/evidencia
      final response = await this.obtenerDocumentos(driveFolderId);
      var imageFolder = (response.data['files'] as List<dynamic>)
          .firstWhere((file) => file['name'] == '06- Imagenes');

      final responseAux = await this.obtenerDocumentos(imageFolder['id']);
      var imageFolderEvidencia = (responseAux.data['files'] as List<dynamic>)
          .firstWhere(
              (file) => file['name'].toString().contains('01- Pedidos'));

      final idFolder = imageFolderEvidencia['id'];

      final datos = await this
          ._http
          .uploadImage(_imgPedido, _endpoint + "/$fileName/jpg/$idFolder");
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
    print('3');
    return ids;
  }

  obtenerCantidadImgSeleccionada() {
    return this._imgs.length;
  }

  guardarImagenPedido(XFile img) {
    this._imgPedido = img;
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
