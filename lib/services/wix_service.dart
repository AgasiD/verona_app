
import 'package:flutter/cupertino.dart';

import '../models/MyResponse.dart';
import 'http_service.dart';

class WixService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/wix';

  Future<MyResponse> obtenerPosts() async {
    final datos = await this._http.get('$_endpoint');
    final resp = MyResponse.fromJson(datos);

    return resp;
  }
}
