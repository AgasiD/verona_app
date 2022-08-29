import 'dart:convert';
import 'package:verona_app/models/tarea.dart';

Etapa etapaFromJson(String str) => Etapa.fromJson(json.decode(str));

String etapaToJson(Etapa data) => json.encode(data.toJson());

class Etapa {
  Etapa({
    required this.descripcion,
    required this.id,
    required this.isDefault,
    required this.orden,
    required this.tareas,
  });

  int get cantTareas => tareas.length;
  int get cantTareasTerminadas =>
      tareas.where((element) => element.realizado).length;
  double get porcentajeRealizado => double.parse(
      (cantTareasTerminadas / tareas.length * 100).toStringAsFixed(2));

  String descripcion;
  String id;
  bool isDefault;
  int orden;
  List<Tarea> tareas;

  factory Etapa.fromJson(Map<String, dynamic> json) => Etapa(
        descripcion: json["descripcion"],
        id: json["id"],
        isDefault: json["isDefault"],
        orden: json["orden"],
        tareas: json['tareas'] != null
            ? List<Tarea>.from(json["tareas"].map((x) => Tarea.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "descripcion": descripcion,
        "id": id,
        "isDefault": isDefault,
        "orden": orden,
        "tareas": List<dynamic>.from(tareas.map((x) => x.toJson())),
      };
}
