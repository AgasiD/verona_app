import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/pages/listas/etapas.dart';

class Obra {
  int diasEstimados;
  int diasTranscurridos;
  List<dynamic> diasInactivos;
  List<dynamic> docs;
  List<dynamic> enabledFiles;
  List<dynamic> pedidos;
  List<Etapa> etapas;

  List<Miembro> equipo;
  List<Propietario> propietarios;
  String barrio;
  String chatE;
  String chatI;
  String descripcion;
  String id;
  String imageId;
  String imageURL;
  String imgFolderId;
  String lote;
  String nombre;
  String folderImages;
  String rootDriveCliente;
  String folderImagesCliente;
  String placeHolderImage = 'https://via.placeholder.com/300x150';
  String? driveFolderId;
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
    this.etapas = const [],
    this.imageId = '',
    required this.lote,
    this.propietarios = const [],
    this.descripcion = 'Sin descripción',
    this.pedidos = const [],
    this.driveFolderId = '',
    this.imgFolderId = '',
    this.enabledFiles = const [],
    ts,
    this.imageURL = '',
    this.folderImages = '',
    this.rootDriveCliente = '',
    this.folderImagesCliente = '',
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
    this.etapas = etapas;
    this.imageId = imageId;
    this.lote = lote;
    this.descripcion = descripcion;
    this.pedidos = pedidos;
    this.driveFolderId = driveFolderId;
    this.imgFolderId = imgFolderId;
    this.enabledFiles = enabledFiles;
    this.ts =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .toString();
    this.imageURL = imageURL;
    this.folderImages = folderImages;
    this.rootDriveCliente = rootDriveCliente;
    this.folderImagesCliente = folderImagesCliente;
  }

  factory Obra.fromMap(Map<String, dynamic> json) => Obra(
      nombre: json["nombre"],
      id: json["id"],
      barrio: json["barrio"],
      chatE: json["chatE"],
      chatI: json["chatI"],
      diasEstimados: json["diasEstimados"],
      diasInactivos: json["diasInactivos"],
      diasTranscurridos: 0,
      docs: [],
      driveFolderId: json["driveFolderId"] ?? '',
      imgFolderId: json["imgFolderId"] ?? '',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      equipo: (json["equipo"] as List<dynamic>)
          .map((e) => Miembro.fromJson(e))
          .toList(),
      etapas: (json["etapas"] as List).map((e) => Etapa.fromJson(e)).toList(),
      imageId: json['imageId'] ?? '',
      lote: json["lote"],
      ts: json["ts"],
      propietarios: (json["propietarios"] as List<dynamic>)
          .map((e) => Propietario.fromJson(e))
          .toList(),
      pedidos: json["pedidos"] ?? [],
      enabledFiles: json["enabledFiles"] as List<dynamic>,
      folderImages: json['folderImages'] ?? '',
      rootDriveCliente: json['rootDriveCliente'] ?? '',
      folderImagesCliente: json['folderImagesCliente'] ?? '',
      imageURL: json['imageURL'] ?? '');

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
        'etapas': this.etapas,
        'imageId': this.imageId,
        'lote': this.lote,
        'ts': this.ts,
        'propietarios': this.propietarios,
        'descripcion': this.descripcion,
        'pedidos': this.pedidos,
        'driveFolderId': this.driveFolderId,
        'enabledFiles': this.enabledFiles,
        'imageURL': this.imageURL
      };

  double get porcentajeRealizado {
    int cantTotalTareas = 0;
    int cantTotalTaresHechas = 0;
    etapas.forEach((etapa) {
      cantTotalTareas += etapa.totalTareas;
      cantTotalTaresHechas += etapa.cantSubtareasTerminadas;
    });
    return double.parse(
        (cantTotalTaresHechas / cantTotalTareas * 100).toStringAsFixed(2));
  }

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

  sumarTarea(String etapaId, Tarea tarea) {
    final indexEtapa = etapas.indexWhere((etapa) => etapa.id == etapaId);
    final indexSubetapa = etapas[indexEtapa]
        .subetapas
        .indexWhere((subetapa) => subetapa.id == tarea.subetapa);
    etapas[indexEtapa].subetapas[indexSubetapa].tareas.add(tarea);
  }

  quitarTarea(String etapaId, Tarea tarea) {
    final indexEtapa = etapas.indexWhere((etapa) => etapa.id == etapaId);
    final indexSubetapa = etapas[indexEtapa]
        .subetapas
        .indexWhere((subetapa) => subetapa.id == tarea.subetapa);
    final indexTarea = etapas[indexEtapa]
        .subetapas[indexSubetapa]
        .tareas
        .indexWhere((tareaAux) => tareaAux.id == tarea.id);
    etapas[indexEtapa].subetapas.removeAt(indexTarea);
  }

  sumarEtapa(Etapa etapa) {
    etapas.add(etapa);
  }

  quitarEtapa(String etapa) {
    final indexEtapa = etapas.indexWhere((etapaAux) => etapaAux.id == etapa);
    etapas.removeAt(indexEtapa);
  }
}
