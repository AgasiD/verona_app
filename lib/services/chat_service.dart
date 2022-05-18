import 'package:flutter/material.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/http_service.dart';

import '../models/message.dart';

class ChatService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/chat';

  Future<MyResponse> loadChat(
      {String chatId = '', int offset = 0, int limit = 20}) async {
    final datos = await this._http.get('$_endpoint/$chatId/$offset/$limit');
    final data = MyResponse.fromJson(datos['response']);
    return data;
  }

  Future<MyResponse> crearChat(String idFrom, String to) async {
    final body = {
      "idFrom": idFrom,
      "idTo": to,
    };
    final data = await this._http.post('$_endpoint', body);
    final response = MyResponse.fromJson(data['response']);
    print('notifly listener 5');
    notifyListeners();
    return response;
  }
}
