import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/pedido.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/services/http_service.dart';

class TareaService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/tarea';

  Future<MyResponse> obtenerTareasExtras(subetapaId) async {
    final datos = await this._http.get('$_endpoint/extras/$subetapaId');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> grabar(Map<String, dynamic> data) async {
    final datos = await this._http.post('$_endpoint/nuevaTarea', data);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> actualizarTarea(Tarea tarea) async {
    final datos = await this._http.put('$_endpoint', tarea.toJson());
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }
}
