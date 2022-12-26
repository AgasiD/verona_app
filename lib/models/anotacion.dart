class Anotacion {
  String descripcion = '';
  String id = '';
  int tsGenerado = 0;
  int? tsRealizado;
  bool realizado = false;

  Anotacion(descri, {id = '', tsRealizado = 0, realizado = false, tsGenerado}) {
    this.descripcion = descri;
    this.id = id;
    this.tsRealizado = tsRealizado;
    this.realizado = realizado;
    this.tsGenerado = DateTime.now().millisecondsSinceEpoch;
  }

  cambioEstado(bool estado) {
    realizado = estado;
    realizado ? tsRealizado = DateTime.now().millisecondsSinceEpoch : false;
  }

  factory Anotacion.fromJson(Map<String, dynamic> json) =>
      Anotacion(json['descripcion'],
          id: json['id'],
          realizado: json['realizado'] ?? false,
          tsRealizado: json['tsRealizado'] ?? 0,
          tsGenerado: json['tsGenerado'] ?? 0);

  toJson() => {
        "descripcion": descripcion,
        "id": id,
        "tsRealizado": tsRealizado,
        "realizado": realizado,
        "tsGenerado": tsGenerado,
      };
}
