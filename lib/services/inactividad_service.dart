import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/http_service.dart';

class InactividadService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/inactividad';

  Future<MyResponse> obtenerInactividades() async {
    final datos = await this._http.get('$_endpoint');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> grabar(Map<String, dynamic> data) async {
    final datos = await this._http.post('$_endpoint', data);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> borrar(String id) async {
    final datos = await this._http.delete('$_endpoint/${id}');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }
}
