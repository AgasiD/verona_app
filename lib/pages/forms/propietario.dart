// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/forms/miembro.dart';
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
  bool edit = false;
  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    String? _usuarioId;
    String _pageFrom = 'menu';
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _usuarioId = arguments['usuarioId'] ?? null;
      _pageFrom = arguments['pageFrom'] ?? 'menu';
    }
    if (_usuarioId != null) edit = true;
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
                        color: Helper.brandColors[8],
                        fontSize: 23),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  edit
                      ? FutureBuilder(
                          future: _usuarioService.obtenerUsuario(_usuarioId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return Loading(
                                mensaje: 'Cargando propietario',
                              );

                            final response = snapshot.data as MyResponse;
                            if (response.fallo)
                              return Center(
                                child: Text(
                                    'Error al cargar datos ' + response.error),
                              );

                            final propietario = Miembro.fromJson(response.data);

                            return _Form(from: _pageFrom, propietario: propietario);
                          },
                        )
                      : _Form(from: _pageFrom,),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _Form extends StatefulWidget {
  _Form({Key? key,required this.from, this.propietario = null}) : super(key: key);

  Miembro? propietario;
  String from;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  @override
  void dispose() {
    super.dispose();
    resetForm();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.propietario != null) {
      setForm();
    }
    return Form(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MainButton(
                  width: 100,
                  color: Helper.brandColors[8],
                  onPressed: () {
                    widget.propietario == null
                        ? grabarPropietario(context)
                        : editarPropietario(context);
                    ;
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
    );
  }

  void setForm() {
     txtNombreCtrl.text = widget.propietario!.nombre;
    txtApellidoCtrl.text = widget.propietario!.apellido;
    txtDNICtrl.text = widget.propietario!.dni;
    txtTelefonoCtrl.text = widget.propietario!.telefono;
    txtMailCtrl.text = widget.propietario!.email;
  }

  grabarPropietario(BuildContext context) async {
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
      final response = await _service.grabarUsuario(prop);
      closeLoadingDialog(context);

      if (response.fallo) {

        await openAlertDialogReturn(context, 'Error al crear propietario',
            subMensaje: response.error);
        return;
      }
      resetForm();
      
      await openAlertDialogReturn(context, 'Propietario creado');
      leavePage(context);
    } else {
      openAlertDialog(context, 'Formulario invalido');
    }
  }

  void leavePage(BuildContext context) {
    if(widget.from == 'obra'){
      Navigator.of(context).popAndPushNamed(AgregarPropietariosPage.routeName);
    }else{
      Navigator.of(context).pop();
    }
  }

  editarPropietario(BuildContext context) async {
    bool isValid = true;
    final _service = Provider.of<UsuarioService>(context, listen: false);

    txtNombreCtrl.text.trim() == '' ? isValid = false : true;
    txtApellidoCtrl.text.trim() == '' ? isValid = false : true;
    txtDNICtrl.text == '' ? isValid = false : true;
    txtTelefonoCtrl.text == '' ? isValid = false : true;
    txtMailCtrl.text == '' ? isValid = false : true;

    if (isValid) {
      openLoadingDialog(context, mensaje: 'Actualizando propietario...');

      final prop = Miembro(
          role: 3,
          id: widget.propietario!.id,
          nombre: txtNombreCtrl.text,
          apellido: txtApellidoCtrl.text,
          dni: txtDNICtrl.text,
          telefono: txtTelefonoCtrl.text,
          email: txtMailCtrl.text);
      final response = await _service.modificarUsuario(prop) as MyResponse;
      closeLoadingDialog(context);

      if (response.fallo) {
        await openAlertDialogReturn(context, 'Error al actualizar propietario',
            subMensaje: response.error);
        return;
      }
      await openAlertDialogReturn(context, 'Propietario actualizado')
          .then((value) => Navigator.pop(context));
      resetForm();
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
