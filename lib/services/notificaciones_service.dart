import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:verona_app/services/http_service.dart';

class NotificacionesService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/notificaciones';

  Future<dynamic> obtenerNotificaciones(String idAdmin, bool autorizada) async {
    final response = await this._http.get('$_endpoint/$idAdmin/$autorizada');
    ;
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> enviarNotificacion(String idUsuario, String title, String msg,
      List<String> ids, String idAuth, String type) async {
    final body = {
      'idUsuario': idUsuario,
      "title": title,
      "msg": msg,
      "destinos": ids,
      "idAuth": idAuth,
      "type": type,
    };
    final response = await this._http.post('$_endpoint', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> obtenerNotificacionData(notifId) async {
    final response = await this._http.get('$_endpoint/$notifId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  autorizarNotificacion(String id, String title, String msg, idNotif) async {
    final body = {
      'idNotif': idNotif,
      "titulo": title,
      "mensaje": msg,
    };
    final response = await this._http.put('$_endpoint/autorizar', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    notifyListeners();
    return data;
  }

  Future<dynamic> eliminarNotificacion(notifId) async {
    final response = await this._http.delete('$_endpoint/$notifId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    notifyListeners();

    return data;
  }
}
