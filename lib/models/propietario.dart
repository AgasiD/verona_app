class Propietario {
  Propietario(
      {required this.nombre,
      required this.apellido,
      required this.dni,
      required this.email,
      required this.telefono});
  String nombre;
  String apellido;
  String dni;
  String telefono;
  String email;
  int role = 3;

  factory Propietario.fromJson(Map<String, dynamic> json) => Propietario(
        nombre: json["nombre"],
        apellido: json["apellido"],
        email: json["email"],
        telefono: json["telefono"],
        dni: json["dni"],
      );

  Map<String, dynamic> toJson() => {
        "nombre": this.nombre,
        "apellido": this.apellido,
        "email": this.email,
        "telefono": this.telefono,
        "dni": this.dni,
        "role": this.role,
      };
}
