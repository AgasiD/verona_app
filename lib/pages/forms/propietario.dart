// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PropietarioForm extends StatefulWidget implements MyForm {
  static const String routeName = 'Propietario';
  static String nameForm = 'Nuevo propietario';
  static String alertMessage = 'Confirmar nuevo propietario';
  static Function accion = (BuildContext context) {
    final _service = Provider.of<UsuarioService>(context, listen: false);
    final prop = Propietario(
        nombre: txtNombreCtrl.text,
        apellido: txtApellidoCtrl.text,
        dni: txtDNICtrl.text,
        telefono: txtTelefonoCtrl.text,
        email: txtMailCtrl.text);
    _service.grabarUsuario(prop);
  };
  const PropietarioForm({Key? key}) : super(key: key);
  @override
  State<PropietarioForm> createState() => _PropietarioFormState();
}

final TextEditingController txtNombreCtrl = TextEditingController();
final TextEditingController txtApellidoCtrl = TextEditingController();
final TextEditingController txtDNICtrl = TextEditingController();
final TextEditingController txtTelefonoCtrl = TextEditingController();
final TextEditingController txtMailCtrl = TextEditingController();

class _PropietarioFormState extends State<PropietarioForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 25),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black45, blurRadius: 5, offset: Offset(0, 3))
          ],
          color: Colors.grey.shade100,
        ),
        width: double.infinity,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              CustomInput(
                hintText: 'Nombre',
                icono: Icons.person,
                textController: txtNombreCtrl,
                teclado: TextInputType.text,
                validarInput: (value) => Helper.validNombres(value),
              ),
              CustomInput(
                  hintText: 'Apellido ',
                  icono: Icons.person,
                  textController: txtApellidoCtrl,
                  validarInput: (value) => Helper.validNombres(value),
                  teclado: TextInputType.text),
              CustomInput(
                hintText: 'DNI',
                icono: Icons.assignment_ind_outlined,
                textController: txtDNICtrl,
                teclado: TextInputType.number,
                validarInput: (value) => Helper.validNumeros(value),
              ),
              CustomInput(
                hintText: 'Numero de telefono',
                icono: Icons.phone_android,
                textController: txtTelefonoCtrl,
                teclado: TextInputType.phone,
                validarInput: (value) => Helper.validNumeros(value),
              ),
              CustomInput(
                hintText: 'Correo electronico',
                icono: Icons.alternate_email,
                textController: txtMailCtrl,
                teclado: TextInputType.emailAddress,
                validarInput: (value) => Helper.validEmail(value),
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
