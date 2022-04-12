// ignore_for_file: prefer_function_declarations_over_variables, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/asignar_equipo.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class MiembroForm extends StatefulWidget {
  static const String routeName = 'miembro';
  static String nameForm = 'Nuevo miembro';
  static String alertMessage = 'Confirmar nuevo miembro';
  static Function accion = (BuildContext context) {
    bool isValid = true;
    final _service = Provider.of<UsuarioService>(context, listen: false);

    txtNombreCtrl.text.trim() == '' ? isValid = false : true;
    txtApellidoCtrl.text.trim() == '' ? isValid = false : true;
    txtDNICtrl.text == '' ? isValid = false : true;
    txtTelefonoCtrl.text == '' ? isValid = false : true;
    txtMailCtrl.text == '' ? isValid = false : true;

    if (isValid) {
      final prop = Miembro(
          nombre: txtNombreCtrl.text,
          apellido: txtApellidoCtrl.text,
          dni: txtDNICtrl.text,
          telefono: txtTelefonoCtrl.text,
          email: txtMailCtrl.text,
          role: personalSelected);
      _service.grabarUsuario(prop);
      openAlertDialog(context, 'Miembro creado');
      Timer(
          Duration(milliseconds: 750),
          () => Navigator.of(context)
              .popAndPushNamed(AsignarEquipoPage.routeName));
    } else {
      openAlertDialog(context, 'Formulario invalido');
    }
  };
  const MiembroForm({Key? key}) : super(key: key);
  @override
  State<MiembroForm> createState() => _MiembroFormState();
}

final TextEditingController txtNombreCtrl = TextEditingController();
final TextEditingController txtApellidoCtrl = TextEditingController();
final TextEditingController txtDNICtrl = TextEditingController();
final TextEditingController txtTelefonoCtrl = TextEditingController();
final TextEditingController txtMailCtrl = TextEditingController();
int personalSelected = 2;

class _MiembroFormState extends State<MiembroForm> {
  @override
  Widget build(BuildContext context) {
    final miembros = [
      DropdownMenuItem<int>(
        value: 1,
        child: Text('Arquitecto interno'),
      ),
      DropdownMenuItem<int>(
        value: 2,
        child: Text('Arquitecto'),
      ),
      DropdownMenuItem<int>(
        value: 4,
        child: Text('Obrero'),
      ),
      DropdownMenuItem<int>(
        value: 5,
        child: Text('Encargado de compras'),
      ),
      DropdownMenuItem<int>(
        value: 6,
        child: Text('Repartidor'),
      ),
    ];
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
                validaError: true,
                validarInput: (value) => Helper.campoObligatorio(value),
              ),
              CustomInput(
                  hintText: 'Apellido ',
                  icono: Icons.person,
                  textController: txtApellidoCtrl,
                  validaError: true,
                  validarInput: (value) => Helper.campoObligatorio(value),
                  teclado: TextInputType.text),
              CustomInput(
                hintText: 'DNI',
                icono: Icons.assignment_ind_outlined,
                textController: txtDNICtrl,
                teclado: TextInputType.number,
                validaError: true,
                validarInput: (value) => Helper.validNumeros(value),
              ),
              CustomInput(
                hintText: 'Numero de telefono',
                icono: Icons.phone_android,
                textController: txtTelefonoCtrl,
                teclado: TextInputType.phone,
                validaError: true,
                validarInput: (value) => Helper.validNumeros(value),
              ),
              CustomInput(
                hintText: 'Correo electronico',
                icono: Icons.alternate_email,
                textController: txtMailCtrl,
                teclado: TextInputType.emailAddress,
                validaError: true,
                validarInput: (value) => Helper.validEmail(value),
              ),
              Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.black45,
                      blurRadius: 5,
                      offset: Offset(0, 3))
                ]),
                child: DropdownButtonFormField(
                  value: personalSelected,
                  decoration: InputDecoration(
                      label: Text(
                        'Puesto en equipo',
                        style: TextStyle(color: Helper.primaryColor),
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.work_outline_rounded,
                        color: Helper.primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white),
                  onChanged: (value) {
                    personalSelected = int.parse(value.toString());
                  },
                  items: miembros,
                ),
              )
            ],
          ),
        ),
      ),
    );
    ;
  }
}
