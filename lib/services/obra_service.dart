import 'package:flutter/material.dart';
import 'package:verona_app/helpers/Preferences.dart';
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

  Future<MyResponse> obtenerObrasByUser(String userId) async {
    final datos = await this._http.get('$_endpoint/byuser/$userId');
    final response = MyResponse.fromJson(datos['response']);

    return response;
  }

  Future<Obra> obtenerObra(String obraId) async {
    final body = {"propietario": new Preferences().role == 3};
    final datos = await this._http.post('$_endpoint/obtenerObra/$obraId', body);
    final data = Obra.fromMap(datos["obra"]);
    this.obra = data;
    notifyListeners();
    return data;
  }

  Future<Obra> obtenerEquipo(String obraId) async {
    final datos = await this._http.post('$_endpoint/$obraId', {});
    final json = datos["obra"];
    final data = Obra.fromMap(json);
    this.obra = data;
    notifyListeners();
    return data;
  }

  Future addEnabledFiles(List<String> ids, String obraId) async {
    final body = {"ids": ids};
    final datos = await this._http.put('$_endpoint/enabledFiles/$obraId', body);

    final response = MyResponse.fromJson(datos["response"]);
    return response;
  }

  grabarObra(Obra obra, bool crearDrive) async {
    var body = obra.toMap();
    body.addAll({"crearDrive": crearDrive});
    final response = await this._http.post(_endpoint, body);
        final data = MyResponse.fromJson(response["response"]);

    notifyListeners();
    //this.obra = obra;
    return data;
  }

  actualizarObra(Obra obra) async {
    final response = await this._http.put(_endpoint, obra.toMap());
    notifyListeners();
    return response;
  }

  Future<MyResponse> agregarUsuario(obraId, String dni) async {
    final data =
        await this._http.put('$_endpoint/agregarUsuario/$obraId/$dni', {});
    final response = MyResponse.fromJson(data['response']);

    notifyListeners();
    return response;
  }

  Future<MyResponse> quitarUsuario(obraId, String dni) async {
    final data =
        await this._http.put('$_endpoint/quitarUsuario/$obraId/$dni', {});

    final response = MyResponse.fromJson(data['response']);

    notifyListeners();
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

  Future<MyResponse> obtenerPedidosById(
      String obraId, String usuarioId) async {
    final datos = await this._http.post('$_endpoint/obtenerPedidosById',
        {'obraId': obraId, 'usuarioId': usuarioId});
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

  Future<MyResponse> eliminarObra(String obraId) async {
    final datos = await this._http.delete('$_endpoint/$obraId');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    // notifyListeners();
    return resp;
  }

  Future<MyResponse> actualizarTarea(
      String obraId,
      String etapaId,
      String subetapaId,
      String tareaId,
      bool realizada,
      String usuarioId,
      int ts) async {
    final body = {
      "etapaId": etapaId,
      "subetapaId": subetapaId,
      "tareaId": tareaId,
      "valor": realizada,
      "usuarioId": usuarioId,
      "ts": ts
    };
    final cadena = '$_endpoint/actualizaTarea/$obraId';
    final datos = await this._http.put(cadena, body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    return resp;
  }

  Future<MyResponse> asignarTarea(
      String etapaId, String subetapaId, String tareaId, String obraId) async {
    final body = {
      "tareaId": tareaId,
      "subetapaId": subetapaId,
      "etapaId": etapaId,
      "obraId": obraId
    };
    final datos = await this._http.put('$_endpoint/asignarTarea', body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();

    return resp;
  }

  Future<MyResponse> quitarTarea(
      String etapaId, String subetapa, String tareaId, String obraId) async {
    final body = {
      "subetapaId": subetapa,
      "tareaId": tareaId,
      "etapaId": etapaId,
      "obraId": obraId
    };
    final datos = await this._http.put('$_endpoint/quitarTarea', body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();

    return resp;
  }

  Future<MyResponse> asignarEtapa(String etapaId, String obraId) async {
    final body = {"etapaId": etapaId, "obraId": obraId};
    final datos = await this._http.put('$_endpoint/asignarEtapa', body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();

    return resp;
  }

  Future<MyResponse> quitarEtapa(String etapaId, String obraId) async {
    final body = {"etapaId": etapaId, "obraId": obraId};
    final datos = await this._http.put('$_endpoint/quitarEtapa', body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();

    return resp;
  }

  Future<MyResponse> eliminarEtapa(obraId, etapaId) async {
    final body = {"etapaId": etapaId, "obraId": obraId};
    final datos =
        await this._http.put('$_endpoint/eliminarEtapaFromObra', body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();

    return resp;
  }

  quitarSubetapa(etapaId, subetapaId, obraId) async {
    final body = {
      "etapaId": etapaId,
      "subetapaId": subetapaId,
      "obraId": obraId
    };
    final datos = await this._http.put('$_endpoint/quitarSubetapa', body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();

    return resp;
  }

  asignarSubEtapa(String etapaId, String subetapaId, String obraId) async {
    final body = {
      "etapaId": etapaId,
      "subetapaId": subetapaId,
      "obraId": obraId
    };
    final datos = await this._http.put('$_endpoint/asignarSubetapa', body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();

    return resp;
  }

  Future<MyResponse> actualizarOrdenTareas(
      obraId, etapaId, subetapaId, tareas) async {
    final body = {
      "etapaId": etapaId,
      "subetapaId": subetapaId,
      "tareas": tareas,
    };
    final datos = await this
        ._http
        .put('$_endpoint/actualizarOrdenTareas/${obraId}', body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    // notifyListeners();
    return resp;
  }

  eliminarSubetapa(subetapaId) {}

  Future<MyResponse> actualizarIdDrive(String text) async {
      final body = {
      "idDrive": text,
      "obraId": obra.id
    };
    final datos = await this._http.put('$_endpoint/actualizarIdDrive', body);
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    notifyListeners();

    return resp;
  }

 Future<MyResponse> obtenerPedidosPorObra(String id) async{
       
    final datos = await this._http.get('$_endpoint/obtenerPedidosObras/$id');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    // notifyListeners();

    return resp;
  }

  
 Future<MyResponse> obtenerControlObra() async{
       
    final datos = await this._http.get('$_endpoint/obtenerControlObra');
    final response = datos["response"];
    final resp = MyResponse.fromJson(response);
    // notifyListeners();

    return resp;
  }
}
