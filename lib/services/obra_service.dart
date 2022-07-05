import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/pedido.dart';
import 'package:verona_app/services/http_service.dart';

class ObraService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/obra';
  Obra obra = Obra(nombre: '', barrio: '', diasEstimados: 0, lote: '');

  obtenerObras() async {
    final datos = await this._http.get(_endpoint);
    final lista = datos["obras"];
    final listObras =
        (lista as List<dynamic>).map((json) => Obra.fromMap(json)).toList();
    return listObras;
  }

  obtenerObrasByUser(String userId) async {
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
    notifyListeners();
    //this.obra = obra;
    return response;
  }

  actualizarObra(Obra obra) async {
    final response = await this._http.put(_endpoint, obra.toMap());
    notifyListeners();
    return response;
  }

  Future<dynamic> agregarUsuario(obraId, String dni) async {
    final response = await this._http.put('$_endpoint/$obraId/$dni', {});
    notifyListeners();
    return response;
  }

  Future<dynamic> quitarUsuario(obraId, String dni) async {
    final response =
        await this._http.put('$_endpoint/quitarUsuario/$obraId/$dni', {});
    // notifyListeners();
    return response;
  }

  Future<MyResponse> nuevaInactividad(
      String obraId, Inactividad inactividad) async {
    final datos = await this
        ._http
        .post('$_endpoint/inactividad/$obraId', inactividad.toMap());
    final response = datos["response"];
    final notificaciones = MyResponse.fromJson(response);

    notifyListeners();
    return notificaciones;
  }

  Future<MyResponse> editInactividad(
      String obraId, Inactividad inactividad) async {
    final datos = await this
        ._http
        .put('$_endpoint/inactividad/$obraId', inactividad.toMap());
    final response = datos["response"];
    final notificaciones = MyResponse.fromJson(response);
    notifyListeners();
    return notificaciones;
  }

  Future<MyResponse> obtenerPedidos(String obraId) async {
    final datos = await this._http.get('$_endpoint/obtenerPedidos/$obraId');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> obtenerPedidosAsignadosDelivery(
      String obraId, String deliveryId) async {
    final datos = await this._http.post('$_endpoint/obtenerPedidosByDelivery',
        {'obraId': obraId, 'deliveryId': deliveryId});
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> obtenerPedido(String pedidoId) async {
    final datos = await this._http.get('$_endpoint/obtenerPedido/$pedidoId');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> nuevoPedido(Pedido pedido) async {
    final datos =
        await this._http.post('$_endpoint/agregarPedido', pedido.toJson());
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();
    return resp;
  }

  Future<MyResponse> editPedido(Pedido pedido) async {
    final datos =
        await this._http.put('$_endpoint/actualizarPedido/', pedido.toJson());
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();
    return resp;
  }
}
