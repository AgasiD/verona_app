import 'package:flutter/foundation.dart';

class Inactividad {
  String nombre;
  String fecha;
  String fileName;
  String usuarioId;
  String fileId;
  bool privado;
  Inactividad({
    required this.nombre,
    required this.fecha,
    required this.fileName,
    this.fileId = '',
    required this.usuarioId,
    required this.privado,
  }) {
    this.nombre = nombre;
    this.fecha = fecha;
    this.fileName = fileName;
    this.usuarioId = usuarioId;
    this.privado = privado;
  }

  factory Inactividad.fromMap(Map<String, dynamic> json) => Inactividad(
        nombre: json.containsKey('nombre') ? json['nombre'] : 'Sin nombre',
        fecha: json["fecha"],
        fileName: json["fileName"],
        fileId: json["fileId"],
        usuarioId: json["usuarioId"],
        privado: json.containsKey('privado') ? json["privado"] : 1,
      );

  toMap() => {
        'nombre': this.nombre,
        'fecha': this.fecha,
        'fileName': this.fileName,
        'fileId': this.fileId,
        'usuarioId': this.usuarioId,
        'privado': this.privado,
      };
}
