import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/etapa.dart';
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

  Future<MyResponse> grabar(Map<String, dynamic> data) async {
    final datos = await this._http.post('$_endpoint/nuevaEtapa', data);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();

    return resp;
  }

  Future<MyResponse> eliminarEtapa(etapaId) async {
    final datos = await this._http.delete('$_endpoint/eliminarEtapa/$etapaId');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    // notifyListeners();
    return resp;
  }

  Future<MyResponse> actualizarEtapa(Etapa etapa) async{
      final datos = await this._http.put('$_endpoint', etapa.toJson());
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }
}
