import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/pedido.dart';
import 'package:verona_app/services/http_service.dart';

class ObraService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/obras';
  Obra obra = Obra(nombre: '', barrio: '', diasEstimados: 0, lote: '');

  obtenerObras() async {
    final response = await this._http.get(_endpoint);
    final lista = response["obras"];
    final listObras =
        (lista as List<dynamic>).map((json) => Obra.fromMap(json)).toList();
    return listObras;
  }

  Future<dynamic> obtenerObrasByUser(String userId) async {
    final uri = '$_endpoint/byuser/$userId';
    final response = await this._http.get(uri);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    return data;
  }

  Future<dynamic> obtenerPedidosCerrados(String obraId) async {
    final uri = '$_endpoint/pedidosCerrados/$obraId';
    final response = await this._http.get(uri);
    final data = json.decode(response.body);
    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    return data;
  }

  Future<Obra> obtenerObra(String obraId) async {
    final body = {"propietario": new Preferences().role == 3};
    final response =
        await this._http.post('$_endpoint/obtenerObra/$obraId', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    this.obra = data;
    notifyListeners();
    return data;
  }

  Future<Obra> obtenerEquipo(String obraId) async {
    final response = await this._http.post('$_endpoint/$obraId', {});
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    this.obra = Obra.fromMap(data);
    notifyListeners();
    return data;
  }

  Future addEnabledFiles(List<String> ids, String obraId) async {
    final body = {"ids": ids};
    final response =
        await this._http.put('$_endpoint/enabledFiles/$obraId', body);

    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  grabarObra(Obra obra, bool crearDrive) async {
    var body = obra.toMap();
    body.addAll({"crearDrive": crearDrive});
    final response = await this._http.post(_endpoint, body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    notifyListeners();
    //this.obra = obra;
    return data;
  }

  actualizarObra(dynamic obra) async {
    final response = await this._http.put(_endpoint, obra);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();
    return data;
  }

  Future<dynamic> agregarUsuario(obraId, String id) async {
    final response =
        await this._http.put('$_endpoint/agregarUsuario/$obraId/$id', {});
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();
    return data;
  }

  Future<dynamic> quitarUsuario(obraId, String id) async {
    final response =
        await this._http.put('$_endpoint/quitarUsuario/$obraId/$id', {});
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();
    return data;
  }

  Future<dynamic> nuevaInactividad(
      String obraId, Inactividad inactividad) async {
    final response = await this
        ._http
        .post('$_endpoint/inactividad/$obraId', inactividad.toMap());
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();
    return data;
  }

  Future<dynamic> editInactividad(
      String obraId, Inactividad inactividad) async {
    final response = await this
        ._http
        .put('$_endpoint/inactividad/$obraId', inactividad.toMap());
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    notifyListeners();
    return data;
  }

  Future<dynamic> obtenerPedidos(String obraId) async {
    final response = await this._http.get('$_endpoint/pedidos/$obraId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }

  Future<dynamic> obtenerControlObra(String obraId) async {
    final response = await this._http.get('$_endpoint/controlObra/$obraId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    List<Etapa> etapas =
        (data as List<dynamic>).map((etapa) => Etapa.fromJson(etapa)).toList();
    return etapas;
  }

  Future<dynamic> obtenerPedidosAsignadosDelivery(
      String obraId, String deliveryId) async {
    final response = await this._http.post(
        '$_endpoint/obtenerPedidosByDelivery',
        {'obraId': obraId, 'deliveryId': deliveryId});
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    return data;
  }

  Future<dynamic> obtenerPedidosById(String obraId, String usuarioId) async {
    final response = await this._http.post('$_endpoint/obtenerPedidosById',
        {'obraId': obraId, 'usuarioId': usuarioId});
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    return data;
  }

  Future<dynamic> obtenerPedido(String pedidoId) async {
    final response = await this._http.get('$_endpoint/obtenerPedido/$pedidoId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    return data;
  }

  Future<dynamic> nuevoPedido(Pedido pedido) async {
    final response =
        await this._http.post('api/pedidos/agregarPedido', pedido.toJson());
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();
    return data;
  }

  Future<dynamic> editPedido(Pedido pedido) async {
    final response =
        await this._http.put('api/pedidos/actualizarPedido/', pedido.toJson());
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();
    return data;
  }

  Future<dynamic> eliminarObra(String obraId) async {
    final response = await this._http.delete('$_endpoint/$obraId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    // notifyListeners();
    return data;
  }

  Future<dynamic> actualizarTarea(
    String obraId,
    String etapaId,
    String subetapaId,
    String tareaId,
    bool iniciada,
    bool realizada,
    String usuarioId,
    int tsRealizado,
    int tsIniciado,
  ) async {
    final body = {
      "etapaId": etapaId,
      "subetapaId": subetapaId,
      "tareaId": tareaId,
      "iniciado": iniciada,
      "tsIniciado": tsIniciado,
      "realizado": realizada,
      "tsRealizado": tsRealizado,
      "usuarioId": usuarioId,
    };
    final cadena = '$_endpoint/actualizaTarea/$obraId';
    final response = await this._http.put(cadena, body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    return data;
  }

  Future<dynamic> asignarTarea(
      String etapaId, String subetapaId, String tareaId, String obraId) async {
    final body = {
      "tareaId": tareaId,
      "subetapaId": subetapaId,
      "etapaId": etapaId,
      "obraId": obraId
    };
    final response = await this._http.put('$_endpoint/asignarTarea', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();

    return data;
  }

  Future<dynamic> quitarTarea(
      String etapaId, String subetapa, String tareaId, String obraId) async {
    final body = {
      "subetapaId": subetapa,
      "tareaId": tareaId,
      "etapaId": etapaId,
      "obraId": obraId
    };
    final response = await this._http.put('$_endpoint/quitarTarea', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();

    return data;
  }

  Future<dynamic> asignarEtapa(String etapaId, String obraId) async {
    final body = {"etapaId": etapaId, "obraId": obraId};
    final response = await this._http.put('$_endpoint/asignarEtapa', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();

    return data;
  }

  Future<dynamic> quitarEtapa(String etapaId, String obraId) async {
    final body = {"etapaId": etapaId, "obraId": obraId};
    final response = await this._http.put('$_endpoint/quitarEtapa', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();

    return data;
  }

  Future<dynamic> eliminarEtapa(obraId, etapaId) async {
    final body = {"etapaId": etapaId, "obraId": obraId};
    final response =
        await this._http.put('$_endpoint/eliminarEtapaFromObra', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();

    return data;
  }

  quitarSubetapa(etapaId, subetapaId, obraId) async {
    final body = {
      "etapaId": etapaId,
      "subetapaId": subetapaId,
      "obraId": obraId
    };
    final response = await this._http.put('$_endpoint/quitarSubetapa', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();

    return data;
  }

  asignarSubEtapa(String etapaId, String subetapaId, String obraId) async {
    final body = {
      "etapaId": etapaId,
      "subetapaId": subetapaId,
      "obraId": obraId
    };
    final response = await this._http.put('$_endpoint/asignarSubetapa', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();

    return data;
  }

  Future<dynamic> actualizarOrdenTareas(
      obraId, etapaId, subetapaId, tareas) async {
    final body = {
      "etapaId": etapaId,
      "subetapaId": subetapaId,
      "tareas": tareas,
    };
    final response = await this
        ._http
        .put('$_endpoint/actualizarOrdenTareas/${obraId}', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    // notifyListeners();
    return data;
  }

  eliminarSubetapa(subetapaId) {}

  Future<dynamic> actualizarIdDrive(String text) async {
    final body = {"idDrive": text, "obraId": obra.id};
    final response = await this._http.put('$_endpoint/actualizarIdDrive', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();

    return data;
  }

  Future<dynamic> obtenerPedidosPorObra(String userId) async {
    final response =
        await this._http.get('$_endpoint/obtenerPedidosObras/$userId');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    // notifyListeners();

    return data;
  }

  Future<dynamic> obtenerControlesObra() async {
    final response = await this._http.get('$_endpoint/obtenerControlObra');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    // notifyListeners();

    return data;
  }

  Future<dynamic> obtenerControlInactividades() async {
    final response =
        await this._http.get('$_endpoint/obtenerInactividadesPorObras');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    // notifyListeners();

    return data;
  }

  Future<dynamic> grabarInactividades(List<String> idsObras, Map map) async {
    final body = {
      "ids": idsObras,
      "inactividad": map,
    };
    final response =
        await this._http.post('$_endpoint/inactividadMasiva', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();

    return data;
  }

  Future<dynamic> eliminarInactividad(String obraId, String id) async {
    final response = await this._http.delete(
          '$_endpoint/inactividad/$obraId/$id',
        );
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    notifyListeners();
    return data;
  }

  Future<dynamic> obtenerObraArticuloFile(String obraId) async {
    final response = await this._http.get(
          '$_endpoint/articuloobra/$obraId',
        );
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    // notifyListeners();
    return data;
  }

  Future<dynamic> enviarReportes(List<String> ids) async {
    final body = {"ids": ids};
    final response = await this._http.post('$_endpoint/envioreporte', body);
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }

    // notifyListeners();
    return data;
  }
}
