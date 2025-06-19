import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:verona_app/models/anotacion.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/services/http_service.dart';

class UsuarioService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/usuarios';
  late Miembro usuario;
  // late List<Map<String, dynamic>> novedades;
  obtenerPropietarios() async {
    final response = await this._http.get('$_endpoint/propietario');
    final lista = response["data"];
    final list = (lista as List<dynamic>)
        .map((json) => Propietario.fromJson(json))
        .toList();
    return list;
  }

  obtenerPropietariosAdmin() async {
    final response = await this._http.get('$_endpoint/propadmin');

    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  obtenerPropietariosMiembro() async {
    final response = await this._http.get('$_endpoint/propietarios');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    final list =
        (data as List<dynamic>).map((json) => Miembro.fromJson(json)).toList();
    return list;
  }

    obtenerPersonal({roles = null}) async {
    final body = {'roles': roles};
    final response = await this._http.post('$_endpoint/profesionales', body);
    final data = json.decode(response.body);
    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    final lista = data;
    final list =
        (lista as List<dynamic>).map((json) => Miembro.fromJson(json)).toList();
    return list;
  }

  Future<List<Miembro>> obtenerTodosUsuarios() async {
    final response = await this._http.get('$_endpoint/usuariosAll');
    final data = json.decode(response.body);

    if (response.statusCode >= 300)
      throw new Exception('Error ${data['message']} ${response.statusCode}');

    final list =
        (data as List<dynamic>).map((json) => Miembro.fromJson(json)).toList();
    return list;
  }

  Future<dynamic> obtenerUsuario(id) async {
    final response = await this._http.get('$_endpoint/usuario/$id');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  obtenerNotificaciones(usuarioId) async {
    final response =
        await this._http.get('$_endpoint/getNotifications/$usuarioId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> leerNotificaciones(usuarioId) async {
    final response =
        await this._http.put('$_endpoint/leerNotificaciones/$usuarioId', {});
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  grabarUsuario(dynamic usuario) async {
    final response = await this._http.post(_endpoint, usuario.toJson());
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    notifyListeners();
    return data;
  }

  modificarUsuario(dynamic usuario) async {
    final response = await this
        ._http
        .put('$_endpoint/update/${usuario.id}', usuario.toJson());
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    notifyListeners();
    return data;
  }

  changePassword(Map<String, String?> usuario) async {
    final response = await this._http.put('$_endpoint/password', usuario);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  validarUsuario(String usuario, String password) async {
    try {
      final body = {"username": usuario, "password": password};
      final response = await this._http.post('$_endpoint/autenticar', body);
      final data = json.decode(response.body);

      if (response.statusCode >= 300) {
        throw new Exception('Error ${data['message']} ${response.statusCode}');
      }
      return data;
    } catch (err) {
    }
  }

  setTokenDevice(String usuarioId, String tokenDevice) async {
    final body = {"usuarioId": usuarioId, "tokenDevice": tokenDevice};
    final response = await this._http.post('$_endpoint/tokenDevice', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> deleteDevice(String usuarioId, String tokenDevice) async {
    final body = {"usuarioId": usuarioId, "tokenDevice": tokenDevice};
    final response = await this._http.put('$_endpoint/deleteDevice', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> deleteAllDevice(String usuarioId) async {
    final response = await this
        ._http
        .delete('$_endpoint/deleteAllDeviceByUsuario/$usuarioId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> ultimoMensajeLeido(String id, String chatId, int ts) async {
    final body = {"chatId": chatId, "mensajeTs": ts};
    final response =
        await this._http.put('$_endpoint/ultimoMensajeLeido/$id', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> deleteUsuario(String id) async {
    final response =
        await this._http.delete('$_endpoint/desactivarUsuario/$id');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    notifyListeners();
    return data;
  }

  Future<dynamic> eliminarAnotacion(String id, String anotacionId) async {
    final body = {"id": anotacionId};
    final response =
        await this._http.post('$_endpoint/eliminarAnotacion/$id', body);
    // notifyListeners();
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> modificarAnotacion(
      String usuarioId, Anotacion anotacion) async {
    final body = anotacion.toJson();
    final response =
        await this._http.put('$_endpoint/modificarAnotacion/$usuarioId', body);
    notifyListeners();
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> agregarAnotacion(String id, Anotacion anotacion) async {
    final body = anotacion.toJson();
    final response =
        await this._http.post('$_endpoint/agregarAnotacion/$id', body);
    notifyListeners();
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    return data;
  }

  Future<dynamic> obtenerAnotacionesByObra(String id) async {
    final response = await this._http.get('$_endpoint/anotacionByObra/$id');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
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
    // return MyResponse.fromJson(response);

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
