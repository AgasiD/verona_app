import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/services/http_service.dart';

class SubetapaService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/subetapa';

  Future<MyResponse> obtenerEtapasExtras() async {
    final datos = await this._http.get('$_endpoint/extras');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> grabar(Map<String, dynamic> data) async {
    final datos = await this._http.post('$_endpoint/nuevaSubetapa', data);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();
    return resp;
  }

  Future<MyResponse> obtenerExtras(etapaId, obraId) async {
    final datos =
        await this._http.get('$_endpoint/subetapasExtras/$etapaId/$obraId');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);

    return resp;
  }

  Future<MyResponse> eliminarSubetapa(subetapaId) async {
    final datos =
        await this._http.delete('$_endpoint/eliminarSubetapa/$subetapaId');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    // notifyListeners();
    return resp;
  }

   Future<MyResponse> actualizarSubetapa(Subetapa subetapa) async{
      final datos = await this._http.put('$_endpoint', subetapa.toJson());
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }
}
