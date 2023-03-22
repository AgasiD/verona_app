class Inactividad {
  String id;
  String nombre;
  String fecha;
  String fileName;
  String usuarioId;
  String fileId;
  bool privado;
  late int diasInactivos;
  Inactividad({
    this.id = '',
    required this.nombre,
    required this.fecha,
    this.fileName = '',
    this.fileId = '',
    required this.usuarioId,
    this.privado = true,
    diasInactivos = 1,
  }) {
    this.nombre = nombre;
    this.fecha = fecha;
    this.fileName = fileName;
    this.usuarioId = usuarioId;
    this.privado = privado;
    this.diasInactivos = diasInactivos;
  }

  factory Inactividad.fromMap(Map<String, dynamic> json) => Inactividad(
        id: json["id"],
        nombre: json.containsKey('nombre') ? json['nombre'] : 'Sin nombre',
        fecha: json["fecha"],
        fileName: json["fileName"],
        fileId: json.containsKey('fileId') ? json["fileId"] : '',
        usuarioId:
            json.containsKey('usuarioId') ? json["usuarioId"] : json["usuario"],
        privado: json.containsKey('privado') ? json["privado"] : 1,
        diasInactivos: json.containsKey('diasInactivos') ? json["diasInactivos"] : 1,
      );

  toMap() => {
        'id': this.id,
        'nombre': this.nombre,
        'fecha': this.fecha,
        'fileName': this.fileName,
        'fileId': this.fileId,
        'usuarioId': this.usuarioId,
        'privado': this.privado,
        'diasInactivos': this.diasInactivos
      };
}
