import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/pages/listas/etapas.dart';

class Obra {
  int diasEstimados;
  int diasTranscurridos;
  int diaInicio;
  List<dynamic> diasInactivos;
  List<dynamic> docs;
  List<dynamic> enabledFiles;
  List<dynamic> pedidos;
  List<Etapa> etapas;

  List<Miembro> equipo;
  List<Propietario> propietarios;
  String articulosId;
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
  String folderPedidoImages;
  String? driveFolderId;
  String? ts;
  double? latitud;
  double? longitud;
  Obra({
    required this.barrio,
    required this.diasEstimados,
    required this.lote,
    required this.nombre,
    this.articulosId = '',
    this.chatE = '',
    this.chatI = '',
    this.descripcion = 'Sin descripción',
    this.diaInicio = 0,
    this.diasInactivos = const [],
    this.diasTranscurridos = 0,
    this.docs = const [],
    this.driveFolderId = '',
    this.enabledFiles = const [],
    this.equipo = const [],
    this.etapas = const [],
    this.folderImages = '',
    this.folderImagesCliente = '',
    this.folderPedidoImages = '',
    this.id = '',
    this.imageId = '',
    this.imageURL = '',
    this.imgFolderId = '',
    this.latitud,
    this.longitud,
    this.pedidos = const [],
    this.propietarios = const [],
    this.rootDriveCliente = '',
    ts,
  }) {
    this.barrio = barrio;
    this.chatE = chatE;
    this.chatI = chatI;
    this.descripcion = descripcion;
    this.diaInicio = diaInicio;
    this.diasEstimados = diasEstimados;
    this.diasInactivos = diasInactivos;
    this.diasTranscurridos = diasTranscurridos;
    this.docs = docs;
    this.driveFolderId = driveFolderId;
    this.enabledFiles = enabledFiles;
    this.equipo = equipo;
    this.etapas = etapas;
    this.folderImages = folderImages;
    this.folderImagesCliente = folderImagesCliente;
    this.folderPedidoImages = folderPedidoImages;
    this.id = id;
    this.imageId = imageId;
    this.imageURL = imageURL;
    this.imgFolderId = imgFolderId;
    this.latitud = latitud;
    this.longitud = longitud;
    this.lote = lote;
    this.nombre = nombre;
    this.pedidos = pedidos;
    this.rootDriveCliente = rootDriveCliente;
    this.ts =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .toString();
  }

  factory Obra.fromMap(Map<String, dynamic> json) => Obra(
      nombre: json["nombre"] ?? 'Sin nombre',
      id: json["id"] ?? '',
      barrio: json["barrio"] ?? 'Barrio',
      chatE: json["chatE"] ?? '',
      chatI: json["chatI"] ?? '',
      diasEstimados: json["diasEstimados"] ?? -1,
      diasInactivos: json["diasInactivos"] ?? -1,
      diaInicio: json["diaInicio"] ?? 0,
      docs: [],
      driveFolderId: json["driveFolderId"] ?? '',
      imgFolderId: json["imgFolderId"] ?? '',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      equipo: (json["equipo"] as List<dynamic>)
          .map((e) => Miembro.fromJson(e))
          .toList(),
      etapas: (json["etapas"] as List).map((e) => Etapa.fromJson(e)).toList(),
      imageId: json['imageId'] ?? '',
      lote: json["lote"] ?? '',
      ts: json["ts"] ?? 0,
      propietarios: (json["propietarios"] as List<dynamic>)
          .map((e) => Propietario.fromJson(e))
          .toList(),
      pedidos: json["pedidos"] ?? [],
      enabledFiles: (json["enabledFiles"] as List<dynamic>) ?? [],
      folderImages: json['folderImages'] ?? 'SinDato',
      rootDriveCliente: json['rootDriveCliente'] ?? 'SinDato',
      folderImagesCliente: json['folderImagesCliente'] ?? 'SinDato',
      latitud: json['latitud'] ?? 0,
      longitud: json['longitud'] ?? 0,
      folderPedidoImages: json['folderPedidoImages'] ?? 'SinDato',
      articulosId: json['articulosId'] ?? '',
      imageURL: json['imageURL'] ?? 'SinDato');

  int get cantDiasInactivos {
    int dias = 0;
    this.diasInactivos.forEach((element) {
      dias += element['diasInactivos'] == null
          ? 1
          : element['diasInactivos'] as int ?? 1;
    });
    return dias;
  }

  Map<String, dynamic> toMap() => {
        'nombre': this.nombre,
        'id': this.id,
        'barrio': this.barrio,
        'chatE': this.chatE,
        'chatI': this.chatI,
        'diasEstimados': this.diasEstimados,
        'diasInactivos': this.diasInactivos,
        'diaInicio': this.diaInicio,
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
        'imageURL': this.imageURL,
        'longitud': this.longitud,
        'latitud': this.latitud,
        'folderPedidoImages': this.folderPedidoImages,
        'articulosId': this.articulosId
      };

  double get porcentajeRealizado {
    int cantTotalTareas = 0;
    int cantTotalTaresHechas = 0;
    int cantTotalTaresIniciadas = 0;
    if (etapas.length > 0) {
      etapas.forEach((etapa) {
        cantTotalTareas += etapa.totalTareas;
        cantTotalTaresHechas += etapa.cantTareasTerminadas;
        cantTotalTaresIniciadas += etapa.cantSubtareasIniciadas;
      });
    } else {
      cantTotalTareas = 0;
      cantTotalTaresHechas = 0;
      cantTotalTaresIniciadas = 0;
      return 0;
    }

    if (cantTotalTareas > 0) {
      return double.parse(
          ((cantTotalTaresHechas + (cantTotalTaresIniciadas / 2)) /
                  cantTotalTareas *
                  100)
              .toStringAsFixed(2));
    } else
      return 0;
  }

  estaPropietario(usuarioId) {
    return propietarios.indexWhere((element) => element.id == usuarioId) > -1;
  }

  sumarPropietario(Propietario prop) {
    !estaPropietario(prop.id) ? this.propietarios.add(prop) : false;
  }

  quitarPropietario(Propietario prop) {
    if (estaPropietario(prop.id)) {
      propietarios.removeWhere((element) => element.id == prop.id);
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
    int posicion = tarea.orden ??
        etapas[indexEtapa].subetapas[indexSubetapa].tareas.length;
    posicion < 0
        ? posicion = etapas[indexEtapa].subetapas[indexSubetapa].tareas.length
        : posicion;
    etapas[indexEtapa].subetapas[indexSubetapa].tareas.insert(posicion, tarea);
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
    etapas[indexEtapa].subetapas[indexSubetapa].tareas.removeAt(indexTarea);
  }

  sumarEtapa(Etapa etapa) {
    etapas.add(etapa);
  }

  quitarEtapa(String etapa) {
    final indexEtapa = etapas.indexWhere((etapaAux) => etapaAux.id == etapa);
    etapas.removeAt(indexEtapa);
  }

  getDiasTranscurridos({bool countSaturday = false, bool countSunday = false}) {
    //sin fines de semana
    if (diaInicio == 0 || diaInicio < 0) {
      return 0;
    }
    DateTime diaAnalizado, diaInicial, diaFin;
    diasTranscurridos = 0;
    diaFin = DateTime.now();
    diaAnalizado = DateTime.fromMillisecondsSinceEpoch(diaInicio);
    while (diaAnalizado.millisecondsSinceEpoch >= diaInicio &&
        diaAnalizado.isBefore(diaFin)) {
      if ((countSaturday ? true : diaAnalizado.weekday != DateTime.saturday) &&
          (countSunday ? true : diaAnalizado.weekday != DateTime.sunday)) {
        diasTranscurridos++;
      }
      diaAnalizado = diaAnalizado.add(Duration(days: 1));
    }

    return diasTranscurridos - cantDiasInactivos;
  }

  List<dynamic> obtenerTareasRealizadasByDias({int dias = 5}) {
    DateTime hasta = DateTime.now();

    DateTime desde = DateTime.now().subtract(Duration(days: dias));

    return _buscarTareas(desde, hasta);
  }

  dynamic obtenerTareasRealizadasDesdeHasta(DateTime desde, DateTime hasta) {
    return _buscarTareas(desde, hasta);
  }

  _buscarTareas(DateTime desde, DateTime hasta) {
    List<dynamic> tareasRealizadas = [];
    List<dynamic> etapa_sub_tareasRealizadas = [];
    this.etapas.forEach((etapa) {
      etapa.subetapas.forEach((subetapa) {
        List<Subetapa> subetapasRealizadas = [];

        List<Tarea> tareasRealizadas = [];

        subetapa.tareas.forEach((tarea) {
          if ((!tarea.realizado &&
                  tarea.iniciado == true &&
                  ((tarea.tsIniciado > desde.millisecondsSinceEpoch &&
                          tarea.tsIniciado < hasta.millisecondsSinceEpoch) ||
                      (tarea.tsIniciado < desde.millisecondsSinceEpoch &&
                          tarea.tsIniciado < hasta.millisecondsSinceEpoch))) ||
              (tarea.realizado &&
                  (tarea.tsRealizado >= desde.millisecondsSinceEpoch &&
                      tarea.tsRealizado <= hasta.millisecondsSinceEpoch))) {
            tareasRealizadas.add(tarea);
          }
          ;
        });
        if (tareasRealizadas.isNotEmpty) {
          etapa_sub_tareasRealizadas
              .add({"subetapa": subetapa.descripcion, "tareas": []});
          etapa_sub_tareasRealizadas.last['tareas'] = tareasRealizadas;
        }
      });
    });
    etapa_sub_tareasRealizadas = etapa_sub_tareasRealizadas
        .where((e) => e['tareas'].length > 0)
        .toList();
    return {
      'obra': this.nombre,
      'obraId': this.id,
      "subetapas": etapa_sub_tareasRealizadas
    };
  }

  String ubicToText() {
    if (this.latitud == null) return '';
    return '${this.latitud} ${this.longitud} ';
  }
}
