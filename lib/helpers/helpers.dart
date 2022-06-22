import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helper {
  static Color? primaryColor = Color(0x1E1E22); //Color(0xff222222);
  static Color? primaryColorOpacity =
      Color.fromARGB(255, 212, 212, 212); //Color(0xff222222);
  static Color? secondaryColor = Color(0xffFFD100);
  static List<Color> brandColors = [
    Color(0xff141418),
    Color(0xff1E1E22),
    Color(0xff2D2D31),
    Color(0xffB9B9B9),
    Color(0xffCDCDCD),
    Color(0xffF2F2F7),
    Color(0xff8C6E5A),
    Color(0xffAA826E),
    Color(0xffB1770B),
    Color(0xffF8DE31),
  ];
  static String nombre = 'Verona';
  static int limit = 25;
  //static double maxWidth = MediaQuery.of(context).size.wi dth
  //static AssetImage splashImage = AssetImage('assets/icon/do-splash.png');
  static String version = '1.4.0';

  static String pushToken =
      'emHBj34PRTiMMMMea7q0B5:APA91bEIFvKKPYJYRcBW62_qqCV5_n_9WouqWVGbhjDTGbEjO54Lj_hSxQ1jWfaOQ_7m8veFU1srFUd4ElLxIZBWRexqdUs5gWyVsNQiU6r52lSdEMbolrtPWlAx6edW1l-DSa0EEAFx';

  static getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static Shader getGradient(List<Color> colores) {
    final Shader linearGradient = LinearGradient(colors: colores)
        .createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
    return linearGradient;
  }
  // static String getHash(String nombre, String pass) {
  //   var key = utf8.encode(nombre);
  //   var bytes = utf8.encode(pass);
  //   var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
  //   return hmacSha256.convert(bytes).toString();
  // }

  static void showSnackBar(
      BuildContext context, String txt, TextStyle? style, Duration? duracion) {
    if (duracion == null) {
      duracion = Duration(seconds: 2);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: duracion,
      content: Text(
        txt,
        textAlign: TextAlign.center,
        style: style,
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

  static String diaSemana(int dia) {
    String diaSemana = '';
    switch (dia) {
      case 1:
        diaSemana = 'Lunes';
        break;
      case 2:
        diaSemana = 'Martes';
        break;
      case 3:
        diaSemana = 'Miercoles';
        break;

      case 4:
        diaSemana = 'Jueves';
        break;
      case 5:
        diaSemana = 'Viernes';
        break;
      case 6:
        diaSemana = 'Sabado';
        break;
      case 7:
        diaSemana = 'Domingo';
        break;
    }
    return diaSemana;
  }

  static String getProfesion(int role) {
    switch (role) {
      case 2:
        return 'Arquitecto';
      case 3:
        return 'Propietario';
      case 4:
        return 'Obrero';
      case 5:
        return 'Encargado de compras';
      case 6:
        return 'Delivery';
      case 7:
        return 'PM';
    }
    return 'Admin';
  }

  static String getFechaHoraFromTS(int ts) {
    final tiempoMensaje = DateTime.fromMillisecondsSinceEpoch(ts);

    var fecha = DateFormat('dd/MM/yy').format(tiempoMensaje);
    final hora = tiempoMensaje.hour.toString();
    final minutos = tiempoMensaje.minute < 10
        ? '0${tiempoMensaje.minute}'
        : tiempoMensaje.minute.toString();
    final fechaMensaje;
    if (ts < DateTime.now().millisecondsSinceEpoch - 24 * 3600000 * 7) {
      //mostrar fecha
      fechaMensaje = '$fecha  ${hora}:${minutos}';
    } else if (ts < DateTime.now().millisecondsSinceEpoch - 24 * 3600000) {
      //mostrar dia
      fechaMensaje =
          '${Helper.diaSemana(tiempoMensaje.weekday).substring(0, 3)} ${hora}:${minutos}';
    } else {
      //no mostrar fecha ni dia
      fechaMensaje = '${hora}:${minutos}';
    }
    return fechaMensaje;
  }

  static toCustomTile(text1, text2, text3) {
    return {"title": text1, "subtitle": text2, "avatar": text3};
  }
}
