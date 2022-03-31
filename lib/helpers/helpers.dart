import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class Helper {
  static Color? primaryColor = Colors.grey.shade500; //Color(0xff222222);
  static Color? secondaryColor = Color(0xffFFD100);
  static String nombre = 'Verona';
  //static double maxWidth = MediaQuery.of(context).size.width
  //static AssetImage splashImage = AssetImage('assets/icon/do-splash.png');
  static String version = '1.4.0';

  static String pushToken =
      'emHBj34PRTiMMMMea7q0B5:APA91bEIFvKKPYJYRcBW62_qqCV5_n_9WouqWVGbhjDTGbEjO54Lj_hSxQ1jWfaOQ_7m8veFU1srFUd4ElLxIZBWRexqdUs5gWyVsNQiU6r52lSdEMbolrtPWlAx6edW1l-DSa0EEAFx';

  static getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // static String getHash(String nombre, String pass) {
  //   var key = utf8.encode(nombre);
  //   var bytes = utf8.encode(pass);
  //   var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
  //   return hmacSha256.convert(bytes).toString();
  // }

  static void showSnackBar(BuildContext context, String txt) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        txt,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Helper.secondaryColor, fontWeight: FontWeight.bold),
      ),
    ));
  }

  static IconData IconsMap(String icono) {
    Map<String, IconData> iconos = {
      'Transferencia': Icons.transform_rounded,
      'Tarjeta de crédito': Icons.credit_card,
      'Efectivo': Icons.money,
      'Tarjeta de débito': Icons.card_giftcard
    };

    return iconos[icono]!;
  }

  static String? validNumeros(String? value) {
    if (value == '') {
      return null;
    }
    if (int.tryParse(value!) == null) {
      return 'Se debe ingresar unicamente números ';
    }
  }

  static String? validNombres(String? value) {}
  static String? campoObligatorio(String? value) {
    String? data;
    value == '' ? data = 'Este campo es obligatorio' : data = null;

    return data;
  }

  static String? validEmail(String? value) {
    final pattern =
        r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value ?? '')
        ? null
        : 'Ingrese un correo electrónico válido';
  }
}
