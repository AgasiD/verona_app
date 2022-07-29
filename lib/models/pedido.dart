// To parse this JSON data, do
//
//     final pedido = pedidoFromJson(jsonString);

import 'dart:convert';

Pedido pedidoFromJson(String str) => Pedido.fromJson(json.decode(str));

String pedidoToJson(Pedido data) => json.encode(data.toJson());

class Pedido {
  Pedido(
      {this.id = '',
      required this.idUsuario,
      required this.idObra,
      required this.nota,
      required this.prioridad,
      this.usuarioAsignado = '',
      this.ts = 0,
      this.tsAsignado = 0,
      this.tsCerrado = 0,
      this.imagenId = '',
      this.fechaEstimada = '',
      this.fechaDeseada = '',
      this.indicaciones = '',
      this.estado = 0,
      this.nombreUsuario = ''});

  String id;
  String idUsuario;
  String idObra;
  String nota;
  int prioridad;
  int ts;
  int tsAsignado;
  int tsCerrado;
  String usuarioAsignado;
  String imagenId;
  String fechaEstimada;
  String fechaDeseada;
  String indicaciones;
  String nombreUsuario;
  int estado;

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
      id: json["id"],
      idUsuario: json["idUsuario"],
      idObra: json["idObra"] ?? '',
      nota: json["nota"],
      prioridad: json["prioridad"],
      usuarioAsignado: json["usuarioAsignado"] ?? '',
      ts: json["ts"],
      tsAsignado: json['tsAsignado'],
      tsCerrado: json['tsCerrado'],
      imagenId: json['imagenId'] ?? '',
      fechaEstimada: json['fechaEstimada'] ?? '',
      fechaDeseada: json['fechaDeseada'] ?? '',
      indicaciones: json['indicaciones'] ?? '',
      estado: json['estado'] ?? 0,
      nombreUsuario: json['nombreUsuario'] ?? '');

  Map<String, dynamic> toJson() => {
        "id": id,
        "idUsuario": idUsuario,
        "idObra": idObra,
        "nota": nota,
        "prioridad": prioridad,
        "usuarioAsignado": usuarioAsignado,
        "ts": ts,
        "tsAsignado": tsAsignado,
        "tsCerrado": tsCerrado,
        "imagenId": imagenId ?? '',
        "fechaEstimada": fechaEstimada,
        "fechaDeseada": fechaDeseada,
        "indicaciones": indicaciones,
        "estado": estado,
      };
}
