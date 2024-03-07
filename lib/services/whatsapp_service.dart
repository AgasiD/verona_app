import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/chat.dart';
import 'package:verona_app/services/http_service.dart';

class WSService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/whatsapp';

  // Future<MyResponse> loadChat(
  //     {String chatId = '',
  //     int offset = 0,
  //     int limit = 20,
  //     int fromTS = 0}) async {
  //   this.chatId = chatId;
  //   final datos =
  //       await this._http.get('$_endpoint/$chatId/$offset/$limit/$fromTS');
  //   final data = MyResponse.fromJson(datos['response']);

  //   chat = Chat.fromMap(data.data);
  //   return data;

  // Future<MyResponse> crearChat(String idFrom, String to) async {
  //   final body = {
  //     "idFrom": idFrom,
  //     "idTo": to,
  //   };
  //   final data = await this._http.post('$_endpoint', body);
  //   final response = MyResponse.fromJson(data['response']);

  //   notifyListeners();
  //   return response;
  // }

  // Future<MyResponse> buscarMensajes(String chatId, String text) async {
  //   final body = {"text": text};
  //   final data =
  //       await this._http.post('$_endpoint/buscarMensajes/$chatId', body);
  //   final response = MyResponse.fromJson(data['response']);
  //   return response;
  // }

  // Future<MyResponse> enviarMensajeChatGroup(String obraId, String id, String text) async {
  //   final body = {"obraId": obraId, "idFrom": id, "mensaje": text};
  //   final data =
  //       await this._http.post('$_endpoint/messageToGroup', body);
  //   final response = MyResponse.fromJson(data['response']);
  //   return response;
  // }

  Future<MyResponse> enviarMensaje(String phone, String mensaje) async {
    final body = {"telefono": phone, "mensaje": mensaje};
    final data = await this._http.post('$_endpoint', body);
    final response = MyResponse.fromJson(data['response']);
    return response;
  }

  Future<MyResponse> enviarMensajeGrupo(String idGrupo, String mensaje) async {
    final body = {"idGrupo": idGrupo, "mensaje": mensaje};
    final data = await this._http.post('$_endpoint/grupo', body);
    final response = MyResponse.fromJson(data);
    return response;
  }

  Future<MyResponse> obtenerGrupos() async {
    final data = await this._http.get('$_endpoint/grupos');
    final response = MyResponse.fromJson(data);
    return response;
  }
}
