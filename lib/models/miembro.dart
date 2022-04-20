class Miembro {
  Miembro({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.email,
    required this.telefono,
    required this.role,
    this.username = '',
    this.externo = false,
  });
  String id;
  String nombre;
  String apellido;
  String dni;
  String telefono;
  String email;
  String username;
  int role;
  bool externo;

  factory Miembro.fromJson(Map<String, dynamic> json) => Miembro(
      id: json['id'],
      nombre: json["nombre"],
      apellido: json["apellido"],
      email: json["email"],
      telefono: json["telefono"],
      dni: json["dni"],
      role: json["role"],
      username: json['username']);

  Map<String, dynamic> toJson() => {
        "nombre": this.nombre,
        "apellido": this.apellido,
        "email": this.email,
        "telefono": this.telefono,
        "dni": this.dni,
        "role": this.role,
        "username": this.username
      };
}
