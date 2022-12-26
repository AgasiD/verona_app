import 'package:verona_app/models/anotacion.dart';

class Miembro {
  Miembro(
      {required this.id,
      required this.nombre,
      required this.apellido,
      required this.dni,
      required this.email,
      required this.telefono,
      required this.role,
      this.username = '',
      this.externo = false,
      this.chats = const [],
      this.profileURL = '',
      this.anotaciones = null});
  String id;
  String nombre;
  String apellido;
  String dni;
  String telefono;
  String email;
  String username;
  String profileURL;
  int role;
  bool externo;
  List<dynamic> chats;
  List<Anotacion>? anotaciones;

  factory Miembro.fromJson(Map<String, dynamic> json) => Miembro(
      id: json['id'] ?? '',
      nombre: json["nombre"] ?? '',
      apellido: json["apellido"] ?? '',
      email: json["email"] ?? '',
      telefono: json["telefono"] ?? '',
      dni: json["dni"] ?? '',
      role: json["role"] ?? 0,
      chats: json.containsKey('chats') ? json["chats"] : [],
      username: json['username'] ?? '',
      profileURL: json['profileURL'] ?? '',
      anotaciones: json['anotaciones'] != null
          ? (json['anotaciones'] as List)
              .map((e) => Anotacion.fromJson(e))
              .toList()
          : null);

  Map<String, dynamic> toJson() => {
        "nombre": this.nombre,
        "apellido": this.apellido,
        "email": this.email,
        "telefono": this.telefono,
        "dni": this.dni,
        "role": this.role,
        "username": this.username,
        "profileURL": this.profileURL,
        "anotaciones": this.anotaciones
      };

  agregarAnotacion(Anotacion anota) {
    if (this.anotaciones == null) this.anotaciones = [];
    this.anotaciones!.add(anota);
  }

  eliminarAnotacion(String id) {
    this.anotaciones!.removeWhere((anotacion) => anotacion.id == id);
  }

  actualizarAnotacion(Anotacion anota) {
    final i = this.anotaciones!.indexWhere((element) => element.id == anota.id);
    this.anotaciones![i] = anota;
  }
}
