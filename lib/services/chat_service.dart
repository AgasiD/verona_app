import 'package:flutter/material.dart';
import 'package:verona_app/services/http_service.dart';

import '../models/message.dart';

class ChatService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/chat';

  Future<List<Message>> loadChat(
      {String chatId = '', int offset = 0, int limit = 20}) async {
    final datos = await this._http.get('$_endpoint/$chatId/$offset/$limit');
    final messages = datos["messages"] as List<dynamic>;
    final mensajes = messages.map((e) => Message.fromMap(e)).toList();
    print(mensajes.length);
    return mensajes;
  }
}
