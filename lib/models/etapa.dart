import 'dart:convert';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/models/tarea.dart';

Etapa etapaFromJson(String str) => Etapa.fromJson(json.decode(str));

String etapaToJson(Etapa data) => json.encode(data.toJson());

class Etapa {
  Etapa({
    required this.descripcion,
    required this.id,
    required this.isDefault,
    required this.orden,
    required this.subetapas,
  });

  int get cantSubEtapas => subetapas.length;
  int get cantSubtareasTerminadas {
    int terminadas = 0;

    subetapas.forEach((sub) {
      terminadas += sub.cantTareasTerminadas;
    });
    return terminadas;
  }

  int get totalTareas {
    int total = 0;
    subetapas.forEach((sub) {
      total += sub.cantTareas;
    });
    return total;
  }

  double get porcentajeRealizado => double.parse(
      (cantSubtareasTerminadas / totalTareas * 100).toStringAsFixed(2));

  String descripcion;
  String id;
  bool isDefault;
  int orden;
  List<Subetapa> subetapas;

  factory Etapa.fromJson(Map<String, dynamic> json) => Etapa(
        descripcion: json["descripcion"],
        id: json["id"],
        isDefault: json["isDefault"],
        orden: json["orden"],
        subetapas: json['subetapas'] != null
            ? List<Subetapa>.from(
                json["subetapas"].map((x) => Subetapa.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "descripcion": descripcion,
        "id": id,
        "isDefault": isDefault,
        "orden": orden,
        "subetapas": List<dynamic>.from(subetapas.map((x) => x.toJson())),
      };
}
