// To parse this JSON data, do
//
//     final pedido = pedidoFromJson(jsonString);

import 'dart:convert';

Pedido pedidoFromJson(String str) => Pedido.fromJson(json.decode(str));

String pedidoToJson(Pedido data) => json.encode(data.toJson());

class Pedido {
  Pedido({
    this.id = '',
    required this.idUsuario,
    required this.idObra,
    required this.nota,
    required this.prioridad,
    this.asignado = false,
    this.usuarioAsignado = '',
    this.cerrado = false,
    this.ts = 0,
    this.tsAsignado = 0,
    this.tsCerrado = 0,
  });

  String id;
  String idUsuario;
  String idObra;
  String nota;
  int prioridad;
  int ts;
  int tsAsignado;
  int tsCerrado;
  bool asignado;
  String usuarioAsignado;
  bool cerrado;

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
      id: json["id"],
      idUsuario: json["idUsuario"],
      idObra: json["idObra"] ?? '',
      nota: json["nota"],
      prioridad: json["prioridad"],
      asignado: json["asignado"],
      usuarioAsignado: json["usuarioAsignado"],
      cerrado: json["cerrado"],
      ts: json["ts"],
      tsAsignado: json['tsAsignado'],
      tsCerrado: json['tsCerrado']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "idUsuario": idUsuario,
        "idObra": idObra,
        "nota": nota,
        "prioridad": prioridad,
        "asignado": asignado,
        "usuarioAsignado": usuarioAsignado,
        "cerrado": cerrado,
        "ts": ts,
        "tsAsignado": tsAsignado,
        "tsCerrado": tsCerrado
      };
}
