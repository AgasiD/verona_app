import 'dart:convert';
import 'package:verona_app/models/tarea.dart';

Subetapa subetapaFromJson(String str) => Subetapa.fromJson(json.decode(str));

String subetapaToJson(Subetapa data) => json.encode(data.toJson());

class Subetapa {
  Subetapa({
    this.etapa = '',
    required this.descripcion,
    required this.id,
    required this.isDefault,
    required this.orden,
    required this.tareas,
  });

  int get cantTareas => tareas.length;
  int get cantTareasTerminadas =>
      tareas.where((element) => element.realizado).length;
  int get cantTareasIniciadas => tareas.where((element) => element.iniciado && !element.realizado).length;
  bool get realizado => cantTareasTerminadas == cantTareas;
  double get porcentajeRealizado => tareas.length > 0
      ? double.parse(
          ((cantTareasTerminadas + (cantTareasIniciadas/2)) / tareas.length * 100).toStringAsFixed(2))
      : 0;

  String descripcion;
  String id;
  bool isDefault;
  int orden;
  List<Tarea> tareas;
  String etapa;

  factory Subetapa.fromJson(Map<String, dynamic> json) => Subetapa(
    etapa: json["etapa"] ?? '',
        descripcion: json["descripcion"],
        id: json["id"] ?? '',
        isDefault: json["isDefault"],
        orden: json["orden"],
        tareas: json['tareas'] != null
            ? List<Tarea>.from(json["tareas"].map((x) => Tarea.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
    "etapa": etapa,
        "descripcion": descripcion,
        "id": id,
        "isDefault": isDefault,
        "orden": orden,
        "tareas": List<dynamic>.from(tareas.map((x) => x.toJson())),
      };
}
