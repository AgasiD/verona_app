import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';

import 'package:verona_app/services/http_service.dart';

class ConfigService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/config';

  Future<dynamic> obtener_config() async {
    final response = await this._http.get('$_endpoint');
    ;
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> actualizar(Map<String, dynamic> config) async {
    final body = {"config": config};
    final response = await this._http.put('$_endpoint', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }
}
