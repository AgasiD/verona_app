import 'dart:convert';

Tarea tareaFromJson(String str) => Tarea.fromJson(json.decode(str));

String tareaToJson(Tarea data) => json.encode(data.toJson());

class Tarea {
  Tarea({
    this.id = '',
    required this.descripcion,
    required this.subetapa,
    required this.isDefault,
    this.realizado = false,
    this.tsRealizado = 0,
    this.iniciado = false,
    this.tsIniciado = 0,
    this.orden = 0,
    this.idUsuario = '',
    this.nombreUsuario = '',
    this.nombreSubetapa = ''
  });

  String descripcion;
  String subetapa;
  String nombreSubetapa;
  String id;
  bool isDefault;
  bool realizado;
  bool iniciado;
  int tsIniciado;
  int tsRealizado;
  int orden;
  String idUsuario;
  String? nombreUsuario;


  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
        descripcion: json["descripcion"] ?? '',
        subetapa: json["subetapa"] ?? '' ,
        id: json["id"] ?? '',
        isDefault: json["isDefault"] ?? '',
        realizado: json["realizado"] ?? false,
        tsRealizado: json["tsRealizado"] ?? 0,
        orden: json['orden'] ?? 0,
        idUsuario: json['idUsuario'] ?? '',
        iniciado: json["iniciado"] ?? false,
        tsIniciado: json["tsIniciado"] ?? 0,
        // nombreUsuario: json['nombreUsuario'] ?? 'Sin nombre usuario';
      );

  Map<String, dynamic> toJson() => {
        "descripcion": descripcion,
        "subetapa": subetapa,
        "id": id,
        "isDefault": isDefault,
        "realizado": realizado,
        "tsRealizado": tsRealizado,
        "iniciado": realizado,
        "tsIniciado": tsRealizado,
        "orden": orden,
        "idUsuario": idUsuario
      };
}
