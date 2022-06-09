import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class InactividadesForm extends StatelessWidget {
  static final routeName = 'inactividadesForm';
  const InactividadesForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        muestraBackButton: true,
      ),
      extendBodyBehindAppBar: true,
      body: _Form(),
    );
  }
}

class _Form extends StatefulWidget {
  _Form({Key? key}) : super(key: key);

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  bool esPrivado = false;

  TextEditingController txtCtrlName = new TextEditingController();
  TextEditingController txtCtrlFile = new TextEditingController();
  TextEditingController txtCtrlDate = new TextEditingController();
  DateTime now = DateTime.now();
  Preferences _pref = new Preferences();
  late ObraService _obraService;
  late SocketService _socketService;
  String inactividadId = '';
  late String obraId;
  String textAction = 'Nueva inactividad';

  bool edit = false;
  @override
  void initState() {
    super.initState();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    txtCtrlDate.text = formattedDate.toString();
    _obraService = Provider.of<ObraService>(context, listen: false);
    _socketService = Provider.of<SocketService>(context, listen: false);
    final _pref = new Preferences();
    _socketService.connect(_pref.id);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    obraId = arguments['obraId'];
    if (arguments.containsKey('id')) {
      inactividadId = arguments['id'];
      edit = true;
      textAction = 'Editar inactividad';
    }

    DateTime selectedDate = DateTime.now();
    if (edit) {
      return FutureBuilder(
          future: _obraService.obtenerObra(obraId),
          builder: ((context, snapshot) {
            if (snapshot.data == null) {
              return Loading();
            } else {
              final obra = snapshot.data as Obra;
              Inactividad inactividad = Inactividad.fromMap(obra.diasInactivos
                  .where((element) => element["id"] == inactividadId)
                  .first);
              txtCtrlName.text = inactividad.nombre;
              txtCtrlFile.text = inactividad.fileName;
              txtCtrlDate.text = inactividad.fecha;
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: Helper.formDecoration,
                  child: SafeArea(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                    alignment: Alignment.center,
                                    width: 165,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: .5,
                                            color: Helper.primaryColor!),
                                        color:
                                            Color.fromARGB(96, 212, 202, 104)),
                                    child: Text(
                                      (textAction).toUpperCase(),
                                      style: TextStyle(fontSize: 15),
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 13,
                            ),
                            CustomFormInput(
                                // enable: edit,
                                hintText: ('Nombre').toUpperCase(),
                                icono: Icons.abc,
                                textController: txtCtrlName),
                            SizedBox(
                              height: 15,
                            ),
                            // CustomFormInput(
                            //     // enable: edit,
                            //     hintText: ('nombre Archivo').toUpperCase(),
                            //     icono: Icons.abc,
                            //     iconButton: IconButton(
                            //         icon: Icon(Icons.file_present_outlined),
                            //         onPressed: () async {
                            //           FilePickerResult? result =
                            //               await FilePicker.platform
                            //                   .pickFiles(allowMultiple: true);

                            //           if (result != null) {
                            //             List<File> files = result.paths
                            //                 .map((path) => File(path!))
                            //                 .toList();
                            //             print(files[0].path);
                            //           } else {
                            //             // User canceled the picker
                            //           }
                            //         }),
                            //     textController: txtCtrlFile),
                            // SizedBox(
                            //   height: 15,
                            // ),
                            CustomFormInput(
                                // enable: edit,
                                hintText: ('Fecha').toUpperCase(),
                                icono: Icons.abc,
                                iconButton: IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () {
                                      selectDate(
                                        context,
                                        txtCtrlDate,
                                        selectedDate,
                                      );
                                    }),
                                textController: txtCtrlDate),
                            // Row(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     children: [
                            //       SizedBox(
                            //         //height: 24,
                            //         width: 19,
                            //         child: Checkbox(
                            //           materialTapTargetSize:
                            //               MaterialTapTargetSize.padded,
                            //           value: esPrivado,
                            //           onChanged: (value) {
                            //             esPrivado = !esPrivado;
                            //             setState(() {});
                            //           },
                            //           activeColor: Helper.secondaryColor,
                            //         ),
                            //       ),
                            //       SizedBox(
                            //         width: 10,
                            //       ),
                            //       Text(
                            //         'Privado',
                            //         style: TextStyle(fontSize: 17),
                            //       )
                            //     ]),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SecondaryButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            text: 'Cancelar',
                            width: 100,
                          ),
                          MainButton(
                            onPressed: () async {
                              openDialogConfirmation(context, (context) async {
                                openLoadingDialog(context,
                                    mensaje: 'Modificando inactividad...');
                                final inactividad = new Inactividad(
                                    id: inactividadId,
                                    nombre: txtCtrlName.text,
                                    fecha: txtCtrlDate.text,
                                    fileName: txtCtrlFile.text,
                                    usuarioId: _pref.id,
                                    privado: esPrivado);
                                MyResponse response;

                                response = await _obraService.editInactividad(
                                    obraId, inactividad);
                                closeLoadingDialog(context);

                                if (response.fallo) {
                                  openAlertDialog(context,
                                      'No se pudo modificar la inactividad',
                                      subMensaje: response.error);
                                } else {
                                  openAlertDialog(
                                      context, 'Inactividad generada');
                                }
                              }, '¿Seguro que desea modificar la inactividad?');
                            },
                            text: 'Guardar',
                            width: 100,
                          ),
                        ],
                      )
                    ],
                  )));
            }
          }));
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 35),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: Helper.formDecoration,
        child: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Row(
                children: [
                  Container(
                      alignment: Alignment.center,
                      width: 165,
                      height: 35,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: .5, color: Helper.primaryColor!),
                          color: Color.fromARGB(96, 212, 202, 104)),
                      child: Text(
                        (textAction).toUpperCase(),
                        style: TextStyle(fontSize: 15),
                      ))
                ],
              ),
              SizedBox(
                height: 13,
              ),
              CustomFormInput(
                  // enable: edit,
                  hintText: ('Nombre').toUpperCase(),
                  icono: Icons.abc,
                  textController: txtCtrlName),
              SizedBox(
                height: 15,
              ),
              // CustomFormInput(
              //     // enable: edit,
              //     hintText: ('nombre Archivo').toUpperCase(),
              //     icono: Icons.abc,
              //     iconButton: IconButton(
              //         icon: Icon(Icons.file_present_outlined),
              //         onPressed: () async {
              //           FilePickerResult? result = await FilePicker.platform
              //               .pickFiles(allowMultiple: true);

              //           if (result != null) {
              //             List<File> files =
              //                 result.paths.map((path) => File(path!)).toList();
              //             print(files[0].path);
              //           } else {
              //             // User canceled the picker
              //           }
              //         }),
              //     textController: txtCtrlFile),
              // SizedBox(
              //   height: 15,
              // ),
              CustomFormInput(
                  // enable: edit,
                  hintText: ('Fecha').toUpperCase(),
                  icono: Icons.abc,
                  iconButton: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        selectDate(
                          context,
                          txtCtrlDate,
                          selectedDate,
                        );
                      }),
                  textController: txtCtrlDate),
              // Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              //   SizedBox(
              //     //height: 24,
              //     width: 19,
              //     child: Checkbox(
              //       materialTapTargetSize: MaterialTapTargetSize.padded,
              //       value: esPrivado,
              //       onChanged: (value) {
              //         esPrivado = !esPrivado;
              //         setState(() {});
              //       },
              //       activeColor: Helper.secondaryColor,
              //     ),
              //   ),
              //   SizedBox(
              //     width: 10,
              //   ),
              //   Text(
              //     'Privado',
              //     style: TextStyle(fontSize: 17),
              //   )
              // ])
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SecondaryButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Cancelar',
                  width: 100,
                ),
                MainButton(
                  onPressed: () async {
                    openDialogConfirmation(context, (context) async {
                      openLoadingDialog(context,
                          mensaje: 'Guardando inactividad...');

                      final inactividad = new Inactividad(
                          nombre: txtCtrlName.text,
                          fecha: txtCtrlDate.text,
                          fileName: txtCtrlFile.text,
                          usuarioId: _pref.id,
                          privado: esPrivado);
                      MyResponse response;
                      if (edit) {
                        response = await _obraService.editInactividad(
                            obraId, inactividad);
                      } else {
                        _socketService.agregarInactividad(inactividad, obraId);
                      }
                      closeLoadingDialog(context);

                      // if (response.fallo) {
                      //   openAlertDialog(
                      //       context, 'No se pudo grabar la inactividad',
                      //       subMensaje: response.error);
                      // } else {
                      openAlertDialog(context, 'Inactividad generada');
                      // }
                    }, '¿Seguro que desea generar la inactividad?');
                  },
                  text: 'Guardar',
                  width: 100,
                )
              ],
            )
          ],
        )));
  }
}

void selectDate(context, txtCtrlDate, selectedDate) {
  DatePicker.showDatePicker(context,
      showTitleActions: true, minTime: DateTime(2022, 1, 1),
      // maxTime: DateTime(2025, 12, 31),
      onConfirm: (date) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    txtCtrlDate.text = formattedDate.toString();
    selectedDate = date;
  }, onChanged: (date) {}, currentTime: selectedDate, locale: LocaleType.es);
}
