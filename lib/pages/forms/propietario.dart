// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PropietarioForm extends StatefulWidget {
  static const String routeName = 'Propietario';
  static String nameForm = 'Nuevo propietario';
  static String alertMessage = 'Confirmar nuevo propietario';
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
    return Scaffold(
        appBar: CustomAppBar(
          muestraBackButton: false,
          title: 'Asociar propietario',
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
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
                  MainButton(
                      onPressed: () {
                        grabarPropietario(context);
                      },
                      text: 'Grabar'),
                  SizedBox(
                    height: 15,
                  ),
                  SecondaryButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: 'Cancelar')
                ],
              ),
            ),
          ),
        ));
  }

  grabarPropietario(BuildContext context) {
    bool isValid = true;
    final _service = Provider.of<UsuarioService>(context, listen: false);

    txtNombreCtrl.text.trim() == '' ? isValid = false : true;
    txtApellidoCtrl.text.trim() == '' ? isValid = false : true;
    txtDNICtrl.text == '' ? isValid = false : true;
    txtTelefonoCtrl.text == '' ? isValid = false : true;
    txtMailCtrl.text == '' ? isValid = false : true;

    if (isValid) {
      openLoadingDialog(context, mensaje: 'Guardando propietario...');

      final prop = Propietario(
          nombre: txtNombreCtrl.text,
          apellido: txtApellidoCtrl.text,
          dni: txtDNICtrl.text,
          telefono: txtTelefonoCtrl.text,
          email: txtMailCtrl.text);
      _service.grabarUsuario(prop);
      resetForm();
      closeLoadingDialog(context);
      openAlertDialog(context, 'Propietario creado');
      Timer(
          Duration(milliseconds: 750),
          () => Navigator.of(context)
              .popAndPushNamed(AgregarPropietariosPage.routeName));
    } else {
      openAlertDialog(context, 'Formulario invalido');
    }
  }

  void resetForm() {
    txtNombreCtrl.text = '';
    txtApellidoCtrl.text = '';
    txtDNICtrl.text = '';
    txtTelefonoCtrl.text = '';
    txtMailCtrl.text = '';
  }
}
