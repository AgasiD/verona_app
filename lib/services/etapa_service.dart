import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/services/http_service.dart';

class EtapaService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/controles';

  Future<dynamic> obtenerEtapasExtras() async {
    final response = await this._http.get('$_endpoint/etapas/extras');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> grabar(Map<String, dynamic> etapa) async {
    final response = await this._http.post('api/obras/etapa/extra', etapa);
    ;
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    notifyListeners();

    return data;
  }

  Future<dynamic> eliminarEtapa(etapaId) async {
    final response =
        await this._http.delete('$_endpoint/eliminarEtapa/$etapaId');
    ;
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    } // notifyListeners();
    return data;
  }

  Future<dynamic> actualizarEtapa(Etapa etapa) async {
    final response = await this._http.put('$_endpoint', etapa.toJson());
    ;
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }
}
