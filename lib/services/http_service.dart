import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:verona_app/helpers/Enviroment.dart';
import 'package:verona_app/helpers/Preferences.dart';

class HttpService extends ChangeNotifier {
  //bool loading = false;
  String _baseUrl = Environment.API_URL;
  final headers = {"Content-Type": "application/json"};
  late Uri url;
  HttpService() {}

  get(String endpoint) async {
    final _pref = new Preferences();
    Environment.isProduction
        ? url = Uri.https(_baseUrl, endpoint)
        : url = Uri.http(_baseUrl, endpoint);

    final response = await http.get(url, headers: {'x-token': _pref.token});
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  }

  post(String endpoint, Map<String, dynamic> body) async {
    final _pref = new Preferences();
    //headers.addAll({'x-token': _pref.token});
    Environment.isProduction
        ? url = Uri.https(_baseUrl, endpoint)
        : url = Uri.http(_baseUrl, endpoint);

    final response =
        await http.post(url, body: json.encode(body), headers: headers);
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  }

  delete(String endpoint) async {
    final _pref = new Preferences();
    Environment.isProduction
        ? url = Uri.https(_baseUrl, endpoint)
        : url = Uri.http(_baseUrl, endpoint);
    final response = await http.delete(url);
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  }

  put(String endpoint, Map<String, dynamic> body) async {
    final _pref = new Preferences();
    Environment.isProduction
        ? url = Uri.https(_baseUrl, endpoint)
        : url = Uri.http(_baseUrl, endpoint);
    final response =
        await http.put(url, body: json.encode(body), headers: headers);
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  }

  uploadImage(XFile imageFile, String endpoint) async {
    String imgId = '';
    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();
    // string to uri
    if (Environment.isProduction) {
      url = Uri.https(_baseUrl, endpoint);
    } else {
      url = Uri.http(_baseUrl, endpoint);
    }
    // create multipart request
    var request = new http.MultipartRequest("POST", url);

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

  uploadDocument(FilePickerResult file, String endpoint) async {
    String imgId = '';
    // open a bytestream
    var stream = new http.ByteStream(
        DelegatingStream.typed(file.files.single.readStream!));
    // get file length
    var length = await file.files.single.size;
    // string to uri
    if (Environment.isProduction) {
      url = Uri.https(_baseUrl, endpoint);
    } else {
      url = Uri.http(_baseUrl, endpoint);
    }
    // create multipart request
    var request = new http.MultipartRequest("POST", url);

    // multipart that takes file
    var multipartFile = http.MultipartFile('pdf', stream, length,
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

    /*
//create multipart request for POST or PATCH method
    if (isProduction) {
      url = Uri.https(_baseUrl, endpoint);
    } else {
      url = Uri.http(_baseUrl, endpoint);
    }
    var request = http.MultipartRequest("POST", url);
    //add text fields
    request.fields["text_field"] = 'NO SE QUE VA ACA';
    //create multipart using filepath, string or bytes
    var pic = await http.MultipartFile.fromPath(
        "file_field", file.files.single.path!);
    //add multipart to request
    request.files.add(pic);
    var response = await request.send();

    //Get the response from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);
*/

    // String imgId = '';
    // Uint8List fileBytes = file.files.first.bytes!;
    // // open a bytestream
    // var stream = new http.ByteStream(DelegatingStream.typed(file.files.single. .openRead()));
    // // get file length
    // var length = await file.files.single.size;
    // // string to uri
    // if (isProduction) {
    //   url = Uri.https(_baseUrl, endpoint);
    // } else {
    //   url = Uri.http(_baseUrl, endpoint);
    // }
    // // create multipart request
    // var request = new http.MultipartRequest("POST", url);

    // // multipart that takes file
    // var multipartFile = http.MultipartFile('image', stream, length,
    //     filename: basename('fileName'));

    // // add file to multipart
    // request.files.add(multipartFile);

    // // send
    // final a = await request.send();
    // // listen for response
    // final b = a.stream.transform(utf8.decoder);
    // final c = b.listen((value) {
    //   imgId = value;
    // }).asFuture();

    // await c;
    // return imgId;
  }
}
