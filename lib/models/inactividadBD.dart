import 'package:flutter/foundation.dart';

class InactividadBD {
  String id;
  String nombre;
  String fecha;
  int diasInactivos;
  InactividadBD({
    this.id = '',
    required this.nombre,
    this.fecha = '',
    required this.diasInactivos,
  }) {
    this.nombre = nombre;
    this.fecha = fecha;
    this.diasInactivos = diasInactivos;
  }

  factory InactividadBD.fromMap(Map<String, dynamic> json) => InactividadBD(
        id: json["id"],
        nombre: json.containsKey('nombre') ? json['nombre'] : 'Sin nombre',
        diasInactivos: json["diasInactivos"] ?? 1
      );

  toMap() => {
        'id': this.id,
        'nombre': this.nombre,
        'fecha': this.fecha,
        'diasInactivos': this.diasInactivos ?? 1,
      };
}
