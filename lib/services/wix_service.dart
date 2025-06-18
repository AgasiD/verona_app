import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../models/MyResponse.dart';
import 'http_service.dart';

class WixService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/wix';

  Future<MyResponse> obtenerPosts() async {
    final response = await this._http.get('$_endpoint');
    final data = json.decode(response.body);

    if (response.statusCode >= 300) {
      throw new Exception('Error ${data['message']} ${response.statusCode}');
    }
    return data;
  }
}
