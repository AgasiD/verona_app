import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class HttpService extends ChangeNotifier {
  //bool loading = false;
  final _baseUrl = 'localhost:8008'; //'veronaserver.herokuapp.com';
  final headers = {"Content-Type": "application/json"};
  HttpService() {}

  get(String endpoint) async {
    final url = Uri.http('$_baseUrl', endpoint);
    final response = await http.get(url);
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  }

  post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.http(_baseUrl, endpoint);
    final response =
        await http.post(url, body: json.encode(body), headers: headers);
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  }

  delete(String endpoint) async {
    final url = Uri.http('$_baseUrl', endpoint);
    final response = await http.delete(url);
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  }

  put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.http('$_baseUrl', endpoint);
    final response =
        await http.put(url, body: json.encode(body), headers: headers);
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  }

  upload(XFile imageFile, String url) async {
    String imgId = '';
    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();
    // string to uri
    final uri = Uri.http('$_baseUrl', url);

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = http.MultipartFile('image', stream, length,
        filename: basename('fileName'));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    final a = await request.send();
    // listen for response
    final b = a.stream.transform(utf8.decoder);
    final c = b.listen((value) {
      imgId = value;
    }).asFuture();

    await c;
    return imgId;
  }
}
