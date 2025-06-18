import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/services/http_service.dart';

class TareaService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/tarea';

  Future<dynamic> obtenerTareasExtras(etapaId, subetapaId, obraId) async {
    final response =
        await this._http.get('$_endpoint/extras/$etapaId/$subetapaId/$obraId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> grabar(Map<String, dynamic> tarea) async {
    final response = await this._http.post('$_endpoint/nuevaTarea', tarea);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> actualizarTarea(Tarea tarea) async {
    final response = await this._http.put('$_endpoint', tarea.toJson());
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }
}
