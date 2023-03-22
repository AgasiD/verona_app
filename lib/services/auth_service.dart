import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/http_service.dart';

class AuthService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/auth';

  Future<MyResponse> validarToken(String token) async {
    final body = {'token': token};

    final datos = await this._http.post('$_endpoint/checkToken', body);
    final data = MyResponse.fromJson(datos['response']);

    return data;
  }
}
