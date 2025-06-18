import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/services/http_service.dart';

class SubetapaService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/controles/subetapas';

  Future<dynamic> obtenerEtapasExtras() async {
    final response = await this._http.get('$_endpoint/extras');

    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> grabar(Map<String, dynamic> subetapa) async {
    final response =
        await this._http.post('$_endpoint/nuevaSubetapa', subetapa);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    notifyListeners();
    return data;
  }

  Future<dynamic> obtenerExtras(etapaId, obraId) async {
    final response = await this._http.get('$_endpoint/extras/$etapaId/$obraId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> eliminarSubetapa(subetapaId) async {
    final response =
        await this._http.delete('$_endpoint/eliminarSubetapa/$subetapaId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> actualizarSubetapa(Subetapa subetapa) async {
    final response = await this._http.put('$_endpoint', subetapa.toJson());
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }
}
