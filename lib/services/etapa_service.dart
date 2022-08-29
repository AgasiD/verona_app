import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/http_service.dart';

class EtapaService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/etapa';

  Future<MyResponse> obtenerEtapasExtras() async {
    final datos = await this._http.get('$_endpoint/extras');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }
}
