import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';

import 'package:verona_app/services/http_service.dart';

class ConfigService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/config';

  Future<MyResponse> obtener_config() async {
    final datos = await this._http.get('$_endpoint');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> actualizar(Map<String, dynamic> data) async {
    final body = {
      "config": data
    };
    final datos = await this._http.put('$_endpoint', body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }
}
