import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/http_service.dart';

class InactividadService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/inactividades';

  Future<MyResponse> obtenerInactividades() async {
    final response = await this._http.get('$_endpoint');
    ;
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> grabar(Map<String, dynamic> data) async {
    final response = await this._http.post('$_endpoint', data);
    ;
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> borrar(String id) async {
    final response = await this._http.delete('$_endpoint/${id}');
    ;
    final resp = MyResponse.fromJson(response);
    return resp;
  }
}
