import 'package:flutter/foundation.dart';

class Inactividad {
  String id;
  String nombre;
  String fecha;
  String fileName;
  String usuarioId;
  String fileId;
  bool privado;
  Inactividad({
    this.id = '',
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
        id: json["id"],
        nombre: json.containsKey('nombre') ? json['nombre'] : 'Sin nombre',
        fecha: json["fecha"],
        fileName: json["fileName"],
        fileId: json.containsKey('fileId') ? json["fileId"] : '',
        usuarioId:
            json.containsKey('usuarioId') ? json["usuarioId"] : json["usuario"],
        privado: json.containsKey('privado') ? json["privado"] : 1,
      );

  toMap() => {
        'id': this.id,
        'nombre': this.nombre,
        'fecha': this.fecha,
        'fileName': this.fileName,
        'fileId': this.fileId,
        'usuarioId': this.usuarioId,
        'privado': this.privado,
      };
}
