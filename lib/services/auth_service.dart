import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:verona_app/services/http_service.dart';

class AuthService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/auth';

  Future validarToken(String token) async {
    final body = {'token': token};

    final response = await this._http.post('$_endpoint/checkToken', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }
}
