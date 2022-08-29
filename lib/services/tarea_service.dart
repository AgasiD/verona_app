import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/pedido.dart';
import 'package:verona_app/services/http_service.dart';

class TareaService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/tarea';

  Future<MyResponse> obtenerTareasExtras(etapaId) async {
    final datos = await this._http.get('$_endpoint/extras/$etapaId');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }
}
