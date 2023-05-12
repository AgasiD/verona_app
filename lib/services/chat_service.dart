import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/chat.dart';
import 'package:verona_app/services/http_service.dart';

class ChatService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/chat';
  late Chat chat;
  String chatId = '';
  bool tieneMensaje = false;

  Future<MyResponse> loadChat(
      {String chatId = '',
      int offset = 0,
      int limit = 20,
      int fromTS = 0}) async {
    this.chatId = chatId;
    final datos =
        await this._http.get('$_endpoint/$chatId/$offset/$limit/$fromTS');
    final data = MyResponse.fromJson(datos['response']);

    chat = Chat.fromMap(data.data);
    return data;
  }

  Future<MyResponse> crearChat(String idFrom, String to) async {
    final body = {
      "idFrom": idFrom,
      "idTo": to,
    };
    final data = await this._http.post('$_endpoint', body);
    final response = MyResponse.fromJson(data['response']);

    notifyListeners();
    return response;
  }

  Future<MyResponse> obtenerChats(String usuarioId) async {
    final body = {"usuarioId": usuarioId};
    final data = await this._http.post('$_endpoint/chatsUsuario', body);
    final response = MyResponse.fromJson(data['response']);
    return response;
  }

  Future<MyResponse> buscarMensajes(String chatId, String text) async {
    final body = {"text": text};
    final data =
        await this._http.post('$_endpoint/buscarMensajes/$chatId', body);
    final response = MyResponse.fromJson(data['response']);
    return response;
  }

  Future<MyResponse> enviarMensajeChatGroup(String obraId, String id, String text) async {
    final body = {"obraId": obraId, "idFrom": id, "mensaje": text};
    final data =
        await this._http.post('$_endpoint/messageToGroup/$chatId', body);
    final response = MyResponse.fromJson(data['response']);
    return response;
  }
}
