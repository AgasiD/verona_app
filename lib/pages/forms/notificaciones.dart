import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/pages/forms/inactividades_masiva.dart';
import 'package:verona_app/services/notificaciones_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class NotificacionesForm extends StatelessWidget {
  const NotificacionesForm({Key? key}) : super(key: key);
  static final routeName = 'NotificacionesForm';
  @override
  Widget build(BuildContext context) {
    final _usuariService = Provider.of<UsuarioService>(context);
    return GestureDetector(
        onTap: () => Helper.requestFocus(context),
        child: Scaffold(
          backgroundColor: Helper.brandColors[1],
          body: FutureBuilder(
              future: _usuariService.obtenerPropietariosAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return Loading(mensaje: 'Cargando información');
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al recuperar información'),
                  );
                }
                final response = snapshot.data as MyResponse;
                if (response.fallo)
                  return Center(child: Text('Error al recuperar información'));
                final propietarios = (response.data['prop'] as List)
                    .map((e) => Propietario.fromJson(e))
                    .toList();
                final admin = (response.data['admin'] as List)
                    .map((e) => Miembro.fromJson(e))
                    .toList();
                final personal = (response.data['personal'] as List)
                    .map((e) => Miembro.fromJson(e))
                    .toList();
                return _FormNotificaciones(
                    propietarios: propietarios,
                    personal: personal,
                    admin: admin);
              }),
          bottomNavigationBar: CustomNavigatorFooter(),
        ));
  }
}

class _FormNotificaciones extends StatefulWidget {
  _FormNotificaciones(
      {Key? key,
      required this.propietarios,
      required this.personal,
      required this.admin})
      : super(key: key);
  List<Propietario> propietarios;

  List<Miembro> admin;
  List<Miembro> personal;
  @override
  State<_FormNotificaciones> createState() => _FormNotificacionesState();
}

class _FormNotificacionesState extends State<_FormNotificaciones> {
  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtMsg = TextEditingController();
  List<String> propietariosItems = [];
  List<String> personalItems = [];

  String adminSelected = '';
  List<DropdownMenuItem<String>> administradoresItem = [];
  List<String> idPersonalSelected = [];
  List<String> idPropietariosSelected = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    propietariosItems = widget.propietarios
        .map((e) =>
            '${e.nombre.toUpperCase()} ${e.apellido.toUpperCase()}: ${e.dni}')
        .toList();

    personalItems = widget.personal
        .map((e) =>
            '${e.nombre.trim().toUpperCase()} ${e.apellido.trim().toUpperCase()}')
        .toList();

    administradoresItem = widget.admin
        .map((e) => DropdownMenuItem<String>(
              child: FittedBox(
                  child: Text(
                      '${e.nombre.toUpperCase()} ${e.apellido.toUpperCase()}')),
              value: e.id,
            ))
        .toList();
    adminSelected = widget.admin[0].id;
    propietariosItems.sort((a, b) => a.compareTo(b));
    personalItems.sort((a, b) => a.compareTo(b));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'nueva notificación'.toUpperCase(),
                    style:
                        TextStyle(color: Helper.brandColors[8], fontSize: 23),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: CustomInput(
                      hintText: 'Título',
                      textController: txtTitle,
                      icono: Icons.title,
                    ),
                  ),
                  CustomInputArea(
                    hintText: 'Escriba hasta 50 caracteres',
                    textController: txtMsg,
                    icono: Icons.notifications_active_sharp,
                    lines: 4,
                  ),
                   DropDownMultiSelect(
                          decoration: getDecoration(),
                          childBuilder: (option) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Propietarios seleccionados: ' +
                                  idPropietariosSelected.length.toString(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: Helper.brandColors[5], fontSize: 17),
                            ),
                          ),
                          selected_values_style: TextStyle(color: Colors.white),
                          options: propietariosItems,
                          selectedValues: idPropietariosSelected,
                          whenEmpty: 'Sin obras seleccionadas',
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_drop_down_outlined,
                              size: 35,
                              color: Helper.brandColors[3],
                            ),
                          ),
                          onChanged: (x) {
                            setState(() {
                              idPropietariosSelected = x as List<String>;
                            });
                          },
                        ),
                      TextButton(onPressed: () => selectAllProp(), child: idPropietariosSelected.length == propietariosItems.length ? Text('Ninguno') :Text('Todos')),                    
                        DropDownMultiSelect(
                            decoration: getDecoration(),
                            childBuilder: (option) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Personal seleccionado: ' +
                                      idPersonalSelected.length.toString(),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Helper.brandColors[5],
                                      fontSize: 17),
                                )),
                            selected_values_style:
                                TextStyle(color: Colors.white),
                            options: personalItems,
                            selectedValues: idPersonalSelected,
                            whenEmpty: 'Sin obras seleccionadas',
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_drop_down_outlined,
                                size: 35,
                                color: Helper.brandColors[3],
                              ),
                            ),
                            onChanged: (x) {
                              setState(() {
                                idPersonalSelected = x as List<String>;
                              });
                            }),
                      TextButton(onPressed: () => selectAllPersonal(), child: idPersonalSelected.length == personalItems.length ? Text('Ninguno') :Text('Todos')),
                    
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selecione autorizante:',
                            style: TextStyle(
                                fontSize: 18, color: Helper.brandColors[4])),
                        SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField2(
                          value: adminSelected,
                          items: administradoresItem,
                          style: TextStyle(
                              color: Helper.brandColors[5], fontSize: 16),
                          iconSize: 30,
                          // buttonWidth: 30,
                          buttonHeight: 50,
                          buttonPadding: EdgeInsets.only(left: 5, right: 10),
                          decoration: getDecoration(),

                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Helper.brandColors[4],
                          ),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Helper.brandColors[2],
                          ),
                          onChanged: (value) {
                            print(value);
                            adminSelected = value as String;
                          },
                          onSaved: (value) {
                            print(value);
                            adminSelected = value as String;
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: MainButton(
                  onPressed: () => enviarNotificacion(context),
                  text: 'Envíar',
                  color: Helper.brandColors[8],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  enviarNotificacion(context) async {
    bool loading = false;
    try {
      final result = validaForm();
      if (!result[0]) {
        await openAlertDialogReturn(context, result[1]);
        return;
      }

      if (!await openDialogConfirmationReturn(
          context, 'Confirme para enviar notificación')) return;

      openLoadingDialog(context, mensaje: 'Enviando notificación...');
      loading = true;
      final _notifService =
          Provider.of<NotificacionesService>(context, listen: false);
      String title = txtTitle.text.trim();
      String msg = txtMsg.text.trim();
      List<String> ids = obtenerIdByDni();
      ids.addAll(obtenerByNombre());
      String idAuth = adminSelected;
      final _pref = new Preferences();
      final response = await _notifService.enviarNotificacion(
          _pref.id, title, msg, ids, idAuth);
      closeLoadingDialog(context);
      if (response.fallo) {
        openAlertDialog(context, 'Error al enviar notificación',
            subMensaje: response.error);
        return;
      }
      openAlertDialog(context, 'Mensaje enviando con éxito');
    } catch (err) {
      if (loading) closeLoadingDialog(context);
      await openAlertDialogReturn(context, 'Error al enviar notificacion',
          subMensaje: err.toString());
    } finally {
      return;
    }
  }

  // addPropietario(String id) {
  //   if (isAdded(id))
  //     idUsuarioSelected.removeWhere((element) => element == id);
  //   else
  //     idUsuarioSelected.add(id);
  // }

  // isAdded(String id) {
  //   return idUsuarioSelected.indexWhere((element) => element == id) >= 0;
  // }

  obtenerIdByDni() {
    List<String> ids = [];
    try {
      idPropietariosSelected.forEach((item) {
        final dni = item.split(' ').last;
        final id =
            widget.propietarios.singleWhere((prop) => prop.dni == dni).id;
        ids.add(id);
      });
      return ids;
    } catch (err) {
      openAlertDialog(context,
          'Error al buscar ID de usuario seleccionado: ${err.toString()}');
      throw new Exception();
    }
  }

  obtenerByNombre() {
    List<String> ids = [];
    try {
      idPersonalSelected.forEach((item) {
        final id = widget.personal
            .singleWhere((personal) =>
                item ==
                '${personal.nombre.trim().toUpperCase()} ${personal.apellido.trim().toUpperCase()}')
            .id;
        ids.add(id);
      });
      return ids;
    } catch (err) {
      openAlertDialog(context,
          'Error al buscar ID de usuario seleccionado: ${err.toString()}');
      throw new Exception();
    }
  }

  validaForm() {
    String mensaje = '';
    bool valido = true;
    if (idPersonalSelected.length == 0 && idPropietariosSelected.length == 0) {
      valido = false;
      mensaje = 'No se ingresaron destinatarios';
    }
    if (txtMsg.text.trim().length == 0) {
      valido = false;
      mensaje = 'No se ha ingresado mensaje';
    }

    if (txtTitle.text.trim().length == 0) {
      valido = false;
      mensaje = 'El título es obligatorio';
    }
    if (txtMsg.text.trim().length > 50) {
      valido = false;
      mensaje = 'Escriba máximo 50 caracteres (${txtMsg.text.trim().length})';
    }
    return [valido, mensaje];
  }
  
  
  selectAllProp() {
    setState(() {
      if(idPropietariosSelected.length == propietariosItems.length){
        idPropietariosSelected.clear();
        return;
      }
      idPropietariosSelected = propietariosItems.map((e) => e).toList();
    });
  }
  
  selectAllPersonal() {
    setState(() {
      if(idPersonalSelected.length == personalItems.length){
        idPersonalSelected.clear();
        return;
      }
      idPersonalSelected = personalItems.map((e) => e).toList();
    });
  }
}
