class Propietario {
  Propietario(
      {this.id = '',
      required this.nombre,
      required this.apellido,
      required this.dni,
      required this.email,
      required this.telefono});
  String nombre;
  String apellido;
  String dni;
  String telefono;
  String email;
  String id;
  int role = 3;

  factory Propietario.fromJson(Map<String, dynamic> json) => Propietario(
      nombre: json["nombre"],
      apellido: json["apellido"],
      email: json["email"],
      telefono: json["telefono"] ?? '',
      dni: json["dni"],
      id: json["id"]);

  Map<String, dynamic> toJson() => {
        "nombre": this.nombre,
        "apellido": this.apellido,
        "email": this.email,
        "telefono": this.telefono,
        "dni": this.dni,
        "role": this.role,
        "id": this.id
      };
}
