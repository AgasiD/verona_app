// ignore_for_file: prefer_function_declarations_over_variables, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/asignar_equipo.dart';
import 'package:verona_app/pages/listas/personal_adm.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class MiembroForm extends StatefulWidget {
  static const String routeName = 'miembro';
  static String nameForm = 'Nuevo miembro';
  static String alertMessage = 'Confirmar nuevo miembro';
  MiembroForm({Key? key}) : super(key: key);
  @override
  State<MiembroForm> createState() => _MiembroFormState();
}

final TextEditingController txtNombreCtrl = TextEditingController();
final TextEditingController txtApellidoCtrl = TextEditingController();
final TextEditingController txtDNICtrl = TextEditingController();
final TextEditingController txtTelefonoCtrl = TextEditingController();
final TextEditingController txtMailCtrl = TextEditingController();
String personalSelected = '2';
late String? usuarioId;

class _MiembroFormState extends State<MiembroForm> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    usuarioId = arguments['usuarioId'];
    final _usuarioService = Provider.of<UsuarioService>(context);

    return Scaffold(
      body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: usuarioId == null
              ? _Form(
                  txtNombreCtrl: txtNombreCtrl,
                  txtApellidoCtrl: txtApellidoCtrl,
                  txtDNICtrl: txtDNICtrl,
                  txtTelefonoCtrl: txtTelefonoCtrl,
                  txtMailCtrl: txtMailCtrl)
              : FutureBuilder(
                  future: _usuarioService.obtenerUsuario(usuarioId),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Loading(
                        mensaje: 'Recuperando información',
                      );
                    } else {
                      final response = MyResponse.fromJson(
                          snapshot.data as Map<String, dynamic>);
                      if (!response.fallo) {
                        final usuario = Miembro.fromJson(response.data);
                        txtNombreCtrl.text = usuario.nombre;
                        txtApellidoCtrl.text = usuario.apellido;
                        txtDNICtrl.text = usuario.dni;
                        txtTelefonoCtrl.text = usuario.telefono;
                        txtMailCtrl.text = usuario.email;
                        personalSelected = usuario.role.toString();
                        return _Form(
                          txtNombreCtrl: txtNombreCtrl,
                          txtApellidoCtrl: txtApellidoCtrl,
                          txtDNICtrl: txtDNICtrl,
                          txtTelefonoCtrl: txtTelefonoCtrl,
                          txtMailCtrl: txtMailCtrl,
                          edit: true,
                        );
                      } else {
                        return Container(
                            height: MediaQuery.of(context).size.height - 140,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                'Error al recuperar la información',
                                style: TextStyle(
                                    fontSize: 18, color: Helper.brandColors[4]),
                              ),
                            ));
                      }
                    }
                  })),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _Form extends StatelessWidget {
  _Form(
      {required this.txtNombreCtrl,
      required this.txtApellidoCtrl,
      required this.txtDNICtrl,
      required this.txtTelefonoCtrl,
      required this.txtMailCtrl,
      this.edit = false,
      Key? key})
      : super(key: key);

  TextEditingController txtNombreCtrl;
  TextEditingController txtApellidoCtrl;
  TextEditingController txtDNICtrl;
  TextEditingController txtTelefonoCtrl;
  TextEditingController txtMailCtrl;
  bool edit;
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
    DropdownMenuItem<String>(
      value: '1',
      child: Text('Admin'),
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
                edit ? 'Actualizar personal'.toUpperCase() : 'NUEVO MIEMBRO',
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
                        value: personalSelected,
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
                            await _grabarMiembro(context);
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

  _grabarMiembro(BuildContext context) async {
    bool isValid = true;
    final _service = Provider.of<UsuarioService>(context, listen: false);
    openLoadingDialog(context, mensaje: 'Cargando...');
    txtNombreCtrl.text.trim() == '' ? isValid = false : true;
    txtApellidoCtrl.text.trim() == '' ? isValid = false : true;
    txtDNICtrl.text == '' ? isValid = false : true;
    txtTelefonoCtrl.text == '' ? isValid = false : true;
    txtMailCtrl.text == '' ? isValid = false : true;

    if (isValid) {
      final miembro = Miembro(
          id: edit ? usuarioId! : '',
          nombre: txtNombreCtrl.text,
          apellido: txtApellidoCtrl.text,
          dni: txtDNICtrl.text,
          telefono: txtTelefonoCtrl.text,
          email: txtMailCtrl.text,
          role: int.parse(personalSelected));
      late MyResponse response;
      edit
          ? response = await _service.modificarUsuario(miembro)
          : response = await _service.grabarUsuario(miembro);
      closeLoadingDialog(context);

      if (response.fallo) {
        edit
            ? openAlertDialog(context, 'No se pudo actualizar el personal',
                subMensaje: response.error)
            : openAlertDialog(context, 'No se pudo crear el personal',
                subMensaje: response.error);
      } else {
        edit
            ? openAlertDialog(context, 'Personal actualizado')
            : openAlertDialog(context, 'Personal creado');
        resetForm();
        Timer(Duration(milliseconds: 750), () => Navigator.pop(context));
        Timer(
            Duration(milliseconds: 750),
            () => edit
                ? Navigator.pop(context)
                : Navigator.of(context)
                    .popAndPushNamed(AsignarEquipoPage.routeName));
      }
    } else {
      closeLoadingDialog(context);

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
