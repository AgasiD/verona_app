import 'package:flutter/material.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/services/http_service.dart';

class ObraService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/obra';
  Obra obra = Obra(nombre: '', barrio: '', diasEstimados: 0, lote: 0);

  obtenerObras() async {
    final datos = await this._http.get(_endpoint);
    final lista = datos["obras"];
    final listObras =
        (lista as List<dynamic>).map((json) => Obra.fromMap(json)).toList();
    return listObras;
  }

  obtenerObrasByUser(String userId) async {
    print('obtenerByUser');
    final datos = await this._http.get('$_endpoint/byuser/$userId');
    final lista = datos["obras"];
    final listObras =
        (lista as List<dynamic>).map((json) => Obra.fromMap(json)).toList();
    return listObras;
  }

  Future<Obra> obtenerObra(String obraId) async {
    final datos = await this._http.get('$_endpoint/$obraId');
    final json = datos["obra"];
    final data = Obra.fromMap(json);
    this.obra = data;
    return data;
  }

  grabarObra(Obra obra) async {
    final response = await this._http.post(_endpoint, obra.toMap());
    // notifyListeners();
    //this.obra = obra;
    return response;
  }

  Future<dynamic> agregarUsuario(obraId, String dni) async {
    final response = await this._http.put('$_endpoint/$obraId/$dni', {});
    // notifyListeners();
    return response;
  }

  Future<dynamic> quitarUsuario(obraId, String dni) async {
    final response =
        await this._http.put('$_endpoint/quitarUsuario/$obraId/$dni', {});
    // notifyListeners();
    return response;
  }
}
