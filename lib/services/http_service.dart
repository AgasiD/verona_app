import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpService extends ChangeNotifier {
  //bool loading = false;
  final _baseUrl = 'localhost:8008';
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
    final response = await http.put(url, body: json.encode(body));
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  }
}
