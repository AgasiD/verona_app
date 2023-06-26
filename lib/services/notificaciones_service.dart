import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/http_service.dart';

class NotificacionesService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/notificacion';

  Future<MyResponse> obtenerNotificaciones(String idAdmin, bool autorizada) async {
    final datos = await this._http.get('$_endpoint/$idAdmin/$autorizada');
    final response = datos;
    return MyResponse.fromJson(response);
    
  }

  Future<MyResponse> enviarNotificacion(String idUsuario, String title, String msg, List<String> ids, String idAuth ) async {
    final body = {
      'idUsuario': idUsuario,
      "title":title,
      "msg":msg,
      "destinos":ids,
      "idAuth":idAuth,
    };
    final datos = await this._http.post('$_endpoint', body);
    final resp = MyResponse.fromJson(datos);
    return resp;
  }

  Future<MyResponse> obtenerNotificacionData(notifId) async{
    final datos = await this._http.get('$_endpoint/$notifId');
    final response = datos;
    return MyResponse.fromJson(response);
  }

  autorizarNotificacion(String id, String title, String msg, idNotif) async {
     final body = {
      'idNotif': idNotif,
      "titulo":title,
      "mensaje":msg,
      
    };
    final datos = await this._http.put('$_endpoint/autorizar', body);
    final resp = MyResponse.fromJson(datos);
    notifyListeners();
    return resp;
  }
}