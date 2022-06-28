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
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Helper.brandColors[1],
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                children: [
                  Logo(
                    size: 70,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'nuevo propietario'.toUpperCase(),
                    style: TextStyle(
                        foreground: Paint()
                          ..shader = Helper.getGradient(
                              [Helper.brandColors[8], Helper.brandColors[9]]),
                        fontSize: 23),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        CustomInput(
                          hintText: 'Nombre',
                          icono: Icons.person,
                          textController: txtNombreCtrl,
                          teclado: TextInputType.text,
                          validaError: true,
                          validarInput: (value) =>
                              Helper.campoObligatorio(value),
                        ),
                        CustomInput(
                            hintText: 'Apellido ',
                            icono: Icons.person,
                            textController: txtApellidoCtrl,
                            validaError: true,
                            validarInput: (value) =>
                                Helper.campoObligatorio(value),
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
                          textInputAction: TextInputAction.done,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MainButton(
                                width: 100,
                                color: Helper.brandColors[7],
                                onPressed: () {
                                  grabarPropietario(context);
                                },
                                text: 'Grabar'),
                            SecondaryButton(
                                width: 100,
                                color: Helper.brandColors[0],
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                text: 'Cancelar'),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
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
