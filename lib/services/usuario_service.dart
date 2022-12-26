import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/anotacion.dart';
import 'package:verona_app/models/form%20copy.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/services/http_service.dart';

class UsuarioService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/usuario';
  late Miembro usuario;
  // late List<Map<String, dynamic>> novedades;
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
    notifyListeners();
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

  Future<MyResponse> eliminarAnotacion(String id, String anotacionId) async {
    final body = {"id": anotacionId};
    final response =
        await this._http.post('$_endpoint/eliminarAnotacion/$id', body);
    notifyListeners();
    return MyResponse.fromJson(response['response']);
  }

  Future<MyResponse> modificarAnotacion(
      String usuarioId, Anotacion anotacion) async {
    final body = anotacion.toJson();
    final response =
        await this._http.put('$_endpoint/modificarAnotacion/$usuarioId', body);
    notifyListeners();
    return MyResponse.fromJson(response['response']);
  }

  Future<MyResponse> agregarAnotacion(String id, Anotacion anotacion) async {
    final body = anotacion.toJson();
    final response =
        await this._http.post('$_endpoint/agregarAnotacion/$id', body);
    notifyListeners();
    return MyResponse.fromJson(response['response']);
  }

  Future<void> obtenerNovedades(String usuarioId) async {
/*
tipos
  - 1: obras
    * 1: Propietario
      > idUsuario
    * 2: Equipo
      > idUsuario
    * 3: Documento
      > idDrive o nombre
    * 4: Imagen
      > idDrive o nombre
    * 5: Etapa
      > idEtapa - idTarea
    * 6: Pedido
      > idPedido


  - 2: mensajes
  - 3: notificaciones;

 */

    // final response =
    //     await this._http.get('$_endpoint/obtenerNovedades/$usuarioId');
    // final data = MyResponse.fromJson(response);
    // novedades = data.data;
    // notifyListeners();
    // return MyResponse.fromJson(response['response']);

    // novedades = [
    //   {
    //     "tipo": 1,
    //     "obraId": '-N91Kgcok2qAMS5A8uTD',
    //     "menu": 6,
    //     "pedidoId": '-N91STHD79eeV28zlj0D',
    //   },
    //   {
    //     "tipo": 1,
    //     "obraId": '-N91Kgcok2qAMS5A8uTD',
    //     "menu": 6,
    //     "pedidoId": '-N98U7MTCFdI8v31alTZ',
    //   },
    //   {
    //     "tipo": 1,
    //     "obraId": '-N91PBV-99_lE1XbSXKW',
    //     "menu": 2,
    //     "pedidoId": '-N1JKOJUQ1eVOnTQpKMn',
    //   },
    //   {
    //     "tipo": 1,
    //     "obraId": '-N91PBV-99_lE1XbSXKW',
    //     "menu": 2,
    //     "pedidoId": '-N1JMEh_SsLdl11I2cTg',
    //   },
    // ];
  }
}
