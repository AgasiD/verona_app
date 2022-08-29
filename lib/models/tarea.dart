import 'dart:convert';

Tarea tareaFromJson(String str) => Tarea.fromJson(json.decode(str));

String tareaToJson(Tarea data) => json.encode(data.toJson());

class Tarea {
  Tarea({
    this.id = '',
    required this.descripcion,
    required this.etapa,
    required this.isDefault,
    this.realizado = false,
    this.tsRealizado = 0,
  });

  String descripcion;
  String etapa;
  String id;
  bool isDefault;
  bool realizado;
  int tsRealizado;

  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
        descripcion: json["descripcion"],
        etapa: json["etapa"],
        id: json["id"],
        isDefault: json["isDefault"],
        realizado: json["realizado"] ?? false,
        tsRealizado: json["tsRealizado"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "descripcion": descripcion,
        "etapa": etapa,
        "id": id,
        "isDefault": isDefault,
        "realizado": realizado,
        "tsRealizado": tsRealizado,
      };
}
