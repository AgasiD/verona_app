import 'package:flutter/material.dart';

import 'package:verona_app/services/http_service.dart';

class InactividadService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/inactividades';

  Future obtenerInactividades() async {
    final response = await this._http.get('$_endpoint');
    ;
    return response;
  }

  Future grabar(Map<String, dynamic> data) async {
    final response = await this._http.post('$_endpoint', data);
    ;
    return response;
  }

  Future borrar(String id) async {
    final response = await this._http.delete('$_endpoint/${id}');
    ;
    return response;
  }
}
