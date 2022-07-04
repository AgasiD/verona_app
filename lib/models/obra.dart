import 'package:flutter/material.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/pedido.dart';
import 'package:verona_app/models/propietario.dart';

class Obra {
  String nombre;
  String placeHolderImage = 'https://via.placeholder.com/300x150';
  String id;
  String barrio;
  String chatE;
  String chatI;
  String descripcion;
  int diasEstimados;
  List<dynamic> diasInactivos;
  int diasTranscurridos;
  List<dynamic> docs;
  List<Miembro> equipo;
  List<dynamic> estadios;
  String imageId;
  String lote;
  List<Propietario> propietarios;
  String? ts;
  List<dynamic> pedidos;
  String? driveFolderId;
  Obra({
    required this.nombre,
    this.id = '',
    required this.barrio,
    this.chatE = '',
    this.chatI = '',
    required this.diasEstimados,
    this.diasInactivos = const [],
    this.diasTranscurridos = 0,
    this.docs = const [],
    this.equipo = const [],
    this.estadios = const [],
    this.imageId = '',
    required this.lote,
    this.propietarios = const [],
    this.descripcion = 'Sin descripción',
    this.pedidos = const [],
    this.driveFolderId = '',
    ts,
  }) {
    this.nombre = nombre;
    this.id = id;
    this.barrio = barrio;
    this.chatE = chatE;
    this.chatI = chatI;
    this.diasEstimados = diasEstimados;
    this.diasInactivos = diasInactivos;
    this.diasTranscurridos = diasTranscurridos;
    this.docs = docs;
    this.equipo = equipo;
    this.estadios = estadios;
    this.imageId = imageId;
    this.lote = lote;
    this.descripcion = descripcion;
    this.pedidos = pedidos;
    this.driveFolderId = driveFolderId;
    this.ts =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .toString();
  }

  factory Obra.fromMap(Map<String, dynamic> json) => Obra(
        nombre: json["nombre"],
        id: json["id"],
        barrio: json["barrio"],
        chatE: json["chatE"],
        chatI: json["chatI"],
        diasEstimados: json["diasEstimados"],
        diasInactivos: json["diasInactivos"],
        diasTranscurridos: json["diasTranscurridos"],
        docs: json["docs"],
        driveFolderId: json["driveFolderId"],
        descripcion: json['descripcion'] ?? 'Sin descripción',
        equipo: (json["equipo"] as List<dynamic>)
            .map((e) => Miembro.fromJson(e))
            .toList(),
        estadios: json["estadios"],
        imageId: json['imageId'] ?? '',
        lote: json["lote"],
        ts: json["ts"],
        propietarios: (json["propietarios"] as List<dynamic>)
            .map((e) => Propietario.fromJson(e))
            .toList(),
        pedidos: json["pedidos"] ?? [],
      );

  toMap() => {
        'nombre': this.nombre,
        'id': this.id,
        'barrio': this.barrio,
        'chatE': this.chatE,
        'chatI': this.chatI,
        'diasEstimados': this.diasEstimados,
        'diasInactivos': this.diasInactivos,
        'diasTranscurridos': this.diasTranscurridos,
        'docs': this.docs,
        'equipo': this.equipo,
        'estadios': this.estadios,
        'imageId': this.imageId,
        'lote': this.lote,
        'ts': this.ts,
        'propietarios': this.propietarios,
        'descripcion': this.descripcion,
        'pedidos': this.pedidos,
        'driveFolderId': this.driveFolderId
      };

  estaPropietario(usuarioId) {
    return propietarios.indexWhere((element) => element.dni == usuarioId) > -1;
  }

  sumarPropietario(Propietario prop) {
    !estaPropietario(prop.dni) ? this.propietarios.add(prop) : false;
  }

  quitarPropietario(Propietario prop) {
    if (estaPropietario(prop.dni)) {
      propietarios.removeWhere((element) => element.dni == prop.dni);
    }
  }

  estaPersonal(usuarioId) {
    return equipo.indexWhere((element) => element.dni == usuarioId) > -1;
  }

  sumarPersonal(Miembro miembro) {
    !estaPersonal(miembro.dni) ? this.equipo.add(miembro) : false;
  }

  quitarPersonal(Miembro miembro) {
    if (estaPersonal(miembro.dni)) {
      equipo.removeWhere((element) => element.dni == miembro.dni);
    }
  }
}
