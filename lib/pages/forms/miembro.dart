// ignore_for_file: prefer_function_declarations_over_variables, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/asignar_equipo.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class MiembroForm extends StatefulWidget {
  static const String routeName = 'miembro';
  static String nameForm = 'Nuevo miembro';
  static String alertMessage = 'Confirmar nuevo miembro';
  const MiembroForm({Key? key}) : super(key: key);
  @override
  State<MiembroForm> createState() => _MiembroFormState();
}

final TextEditingController txtNombreCtrl = TextEditingController();
final TextEditingController txtApellidoCtrl = TextEditingController();
final TextEditingController txtDNICtrl = TextEditingController();
final TextEditingController txtTelefonoCtrl = TextEditingController();
final TextEditingController txtMailCtrl = TextEditingController();
String personalSelected = '2';

class _MiembroFormState extends State<MiembroForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: _Form()),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _Form extends StatelessWidget {
  _Form({Key? key}) : super(key: key);
  final miembros = [
    DropdownMenuItem<String>(
      value: '7',
      child: Text('PM'),
    ),
    DropdownMenuItem<String>(
      value: '2',
      child: Text('Arquitecto'),
    ),
    DropdownMenuItem<String>(
      value: '4',
      child: Text('Obrero'),
    ),
    DropdownMenuItem<String>(
      value: '5',
      child: Text('Encargado de compras'),
    ),
    DropdownMenuItem<String>(
      value: '6',
      child: Text('Repartidor'),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final colorHint = Helper.brandColors[3];
    return Container(
      color: Helper.brandColors[2],
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Logo(
                size: 70,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'NUEVO MIEMBRO',
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
                      textInputAction: TextInputAction.done,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 25),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Helper.brandColors[0],
                              blurRadius: 4,
                              offset: Offset(10, 8))
                        ],
                      ),
                      child: DropdownButtonFormField2(
                        items: miembros,
                        style: TextStyle(
                            color: Helper.brandColors[5], fontSize: 16),
                        iconSize: 30,
                        buttonHeight: 60,
                        buttonPadding: EdgeInsets.only(left: 20, right: 10),
                        decoration: InputDecoration(
                            focusColor: Helper.brandColors[9],
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                  color: Helper.brandColors[9], width: .2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                  color: Helper.brandColors[9], width: .5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                  color: Helper.brandColors[9], width: 2.0),
                            ),
                            fillColor: Helper.brandColors[1],
                            filled: true),
                        hint: Text(
                          'Seleccione puesto',
                          style: TextStyle(fontSize: 16, color: colorHint),
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: colorHint,
                        ),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Helper.brandColors[2],
                        ),
                        onChanged: (value) {
                          personalSelected = value.toString();
                          //Do something when changing the item if you want.
                        },
                        onSaved: (value) {},
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MainButton(
                          width: 120,
                          fontSize: 18,
                          color: Helper.brandColors[8]
                              .withOpacity(.5)
                              .withAlpha(150),
                          text: 'Grabar',
                          onPressed: () async {
                            grabarMiembro(context);
                          },
                        ),
                        SecondaryButton(
                            width: 120,
                            fontSize: 18,
                            color: Helper.brandColors[2],
                            text: 'Cancelar',
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  grabarMiembro(BuildContext context) {
    bool isValid = true;
    final _service = Provider.of<UsuarioService>(context, listen: false);

    txtNombreCtrl.text.trim() == '' ? isValid = false : true;
    txtApellidoCtrl.text.trim() == '' ? isValid = false : true;
    txtDNICtrl.text == '' ? isValid = false : true;
    txtTelefonoCtrl.text == '' ? isValid = false : true;
    txtMailCtrl.text == '' ? isValid = false : true;

    if (isValid) {
      final miembro = Miembro(
          id: '',
          nombre: txtNombreCtrl.text,
          apellido: txtApellidoCtrl.text,
          dni: txtDNICtrl.text,
          telefono: txtTelefonoCtrl.text,
          email: txtMailCtrl.text,
          role: int.parse(personalSelected));
      _service.grabarUsuario(miembro);
      openAlertDialog(context, 'Miembro creado');
      resetForm();
      Timer(
          Duration(milliseconds: 750),
          () => Navigator.of(context)
              .popAndPushNamed(AsignarEquipoPage.routeName));
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
