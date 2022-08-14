import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/chat.dart';
import 'package:verona_app/services/http_service.dart';

class ChatService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/chat';
  late Chat chat;
  String chatId = '';

  Future<MyResponse> loadChat(
      {String chatId = '', int offset = 0, int limit = 20}) async {
    this.chatId = chatId;

    final datos = await this._http.get('$_endpoint/$chatId/$offset/$limit');
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

  Future<MyResponse> obtenerChats(List<String> chatsUsuario) async {
    final body = {"chatsUsuarios": chatsUsuario};
    final data = await this._http.post('$_endpoint/chatsUsuario', body);
    final response = MyResponse.fromJson(data['response']);
    return response;
  }
}
