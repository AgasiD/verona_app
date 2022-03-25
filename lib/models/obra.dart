import 'package:verona_app/models/propietario.dart';

class Obra {
  String nombre;
  String placeHolderImage = 'https://via.placeholder.com/300x150';
  String id;
  String barrio;
  String chatE;
  String chatI;
  int diasEstimados;
  List<dynamic> diasInactivos;
  int diasTranscurridos;
  List<dynamic> docs;
  List<dynamic> equipo;
  List<dynamic> estadios;
  String imagen;
  int lote;
  List<Propietario> propietarios;
  String? ts;
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
    this.imagen = 'https://via.placeholder.com/300x150',
    required this.lote,
    this.propietarios = const [],
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
    this.imagen = imagen;
    this.lote = lote;
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
        equipo: json["equipo"],
        estadios: json["estadios"],
        imagen: json['imagen'],
        lote: json["lote"],
        ts: json["ts"],
        propietarios: (json["propietarios"] as List<dynamic>)
            .map((e) => Propietario.fromJson(e))
            .toList(),
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
        'imagen': this.imagen,
        'lote': this.lote,
        'ts': this.ts,
        'propietarios': this.propietarios,
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
}
