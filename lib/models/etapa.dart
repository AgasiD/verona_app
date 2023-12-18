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
  int get cantTareasTerminadas {
    int terminadas = 0;
    if (subetapas.length > 0) {
      subetapas.forEach((sub) {
        terminadas += sub.cantTareasTerminadas;
      });
    }
    return terminadas;
  }

    int get cantSubtareasIniciadas {
  int iniciadas = 0;
    if (subetapas.length > 0) {
      subetapas.forEach((sub) {
        iniciadas += sub.cantTareasIniciadas;
      });
    }
    return iniciadas;
  }

  int get totalTareas {
    int total = 0;
    if (subetapas.length > 0) {
      subetapas.forEach((sub) {
        total += sub.cantTareas;
      });
      return total;
    } else {
      return 0;
    }
  }

  double get porcentajeRealizado => totalTareas > 0
      ? double.parse(
          ((cantTareasTerminadas + (cantSubtareasIniciadas / 2) ) / totalTareas * 100).toStringAsFixed(2))
      : 0;

  String descripcion;
  String id;
  bool isDefault;
  int orden;
  List<Subetapa> subetapas;

  factory Etapa.fromJson(Map<String, dynamic> json) => Etapa(
        descripcion: json["descripcion"],
        id: json["id"] ?? '',
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

  sumarSubetapa(Subetapa subetapa) {
    subetapas.add(subetapa);
  }

  quitarSubEtapa(String subetapa) {
    final indexSubetapa = subetapas.indexWhere((sube) => sube.id == subetapa);
    subetapas.removeAt(indexSubetapa);
  }
}
