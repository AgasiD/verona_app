import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/form%20copy.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/services/http_service.dart';

class UsuarioService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/usuario';
  late Miembro usuario;
  obtenerPropietarios() async {
    final datos = await this._http.get('$_endpoint/propietario');
    final lista = datos["usuarios"];
    final list = (lista as List<dynamic>)
        .map((json) => Propietario.fromJson(json))
        .toList();
    return list;
  }

  obtenerPersonal() async {
    final datos = await this._http.get('$_endpoint/profesionales');
    final lista = datos["usuarios"];
    final list =
        (lista as List<dynamic>).map((json) => Miembro.fromJson(json)).toList();
    return list;
  }

  obtenerUsuario(id) async {
    final datos = await this._http.get('$_endpoint/obtenerUsuario/$id');
    final response = datos["response"];
    return response;
  }

  obtenerNotificaciones(usuarioId) async {
    final datos =
        await this._http.get('$_endpoint/getNotifications/$usuarioId');
    final response = datos["response"];
    final notificaciones = MyResponse.fromJson(response);
    return notificaciones;
  }

  Future<MyResponse> leerNotificaciones(usuarioId) async {
    final datos =
        await this._http.put('$_endpoint/leerNotificaciones/$usuarioId', {});
    final response = datos["response"];
    final notificaciones = MyResponse.fromJson(response);
    return notificaciones;
  }

  grabarUsuario(dynamic usuario) async {
    final data = await this._http.post(_endpoint, usuario.toJson());
    final response = MyResponse.fromJson(data['response']);
    // notifyListeners();
    return response;
  }

  modificarUsuario(dynamic usuario) async {
    final response =
        await this._http.put('$_endpoint/${usuario.id}', usuario.toJson());
    final data = MyResponse.fromJson(response['response']);
    notifyListeners();
    return data;
  }

  changePassword(Map<String, String?> usuario) async {
    final response = await this._http.put('$_endpoint/password', usuario);
    return response;
  }

  validarUsuario(String usuario, String password) async {
    final body = {"username": usuario, "password": password};
    final response = await this._http.post('$_endpoint/autenticar', body);
    return MyResponse.fromJson(response['response']);
  }

  setTokenDevice(String usuarioId, String tokenDevice) async {
    final body = {"usuarioId": usuarioId, "tokenDevice": tokenDevice};
    final response = await this._http.post('$_endpoint/tokenDevice', body);
    return MyResponse.fromJson(response['response']);
  }

  Future<MyResponse> deleteDevice(String usuarioId, String tokenDevice) async {
    final body = {"usuarioId": usuarioId, "tokenDevice": tokenDevice};
    final response = await this._http.put('$_endpoint/deleteDevice', body);
    return MyResponse.fromJson(response['response']);
  }

  Future<MyResponse> deleteAllDevice(String usuarioId) async {
    final response = await this
        ._http
        .delete('$_endpoint/deleteAllDeviceByUsuario/$usuarioId');
    return MyResponse.fromJson(response['response']);
  }

  Future<MyResponse> ultimoMensajeLeido(
      String id, String chatId, int ts) async {
    final body = {"chatId": chatId, "mensajeTs": ts};
    final response =
        await this._http.put('$_endpoint/ultimoMensajeLeido/$id', body);
    return MyResponse.fromJson(response['response']);
  }

  Future<MyResponse> deleteUsuario(String id) async {
    final response =
        await this._http.delete('$_endpoint/desactivarUsuario/$id');
    notifyListeners();
    return MyResponse.fromJson(response['response']);
  }
}
