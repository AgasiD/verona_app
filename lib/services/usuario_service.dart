import 'package:flutter/material.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/services/http_service.dart';

class UsuarioService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/usuario';
  obtenerPropietarios() async {
    final datos = await this._http.get('$_endpoint/propietario');
    final lista = datos["usuarios"];
    final list = (lista as List<dynamic>)
        .map((json) => Propietario.fromJson(json))
        .toList();
    return list;
  }

  grabarUsuario(Propietario usuario) async {
    final response = await this._http.post(_endpoint, usuario.toJson());
    notifyListeners();
    return response;
  }
}