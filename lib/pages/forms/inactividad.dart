import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class InactividadesForm extends StatelessWidget {
  static final routeName = 'inactividadesForm';
  const InactividadesForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Form(),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _Form extends StatefulWidget {
  _Form({Key? key}) : super(key: key);

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  TextEditingController txtCtrlName = new TextEditingController();
  TextEditingController txtCtrlFile = new TextEditingController();
  TextEditingController txtCtrlDate = new TextEditingController();
  DateTime now = DateTime.now();
  Preferences _pref = new Preferences();
  String inactividadId = '';
  String textAction = 'Nueva inactividad';
  bool edit = false;
  bool esPrivado = false;

  late ObraService _obraService;
  late String obraId;
  late Function() submitAction;
  late Inactividad inactividad;
  late int index;
  @override
  void initState() {
    super.initState();
    _obraService = Provider.of<ObraService>(context, listen: false);
    final _pref = new Preferences();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    obraId = arguments['obraId'];
    print('rebuild');
    if (arguments.containsKey('id')) {
      //NUEVA INACTIVIDAD
      inactividadId = arguments['id'];
      edit = true;
      textAction = 'Editar inactividad';
      index = _obraService.obra.diasInactivos
          .indexWhere((element) => element["id"] == inactividadId);
      inactividad = Inactividad.fromMap(_obraService.obra.diasInactivos[index]);
      txtCtrlName.text = inactividad.nombre;
      txtCtrlFile.text = inactividad.fileName;
      txtCtrlDate.text = inactividad.fecha;

      //Accion al grabar
      submitAction = () async {
        inactividad.fecha = txtCtrlDate.text;
        inactividad.nombre = txtCtrlName.text;
        openDialogConfirmation(context, (context) async {
          openLoadingDialog(context, mensaje: 'Actualizando inactividad...');
          MyResponse response;
          response = await _obraService.editInactividad(obraId, inactividad);
          print(response.data);
          closeLoadingDialog(context);

          if (response.fallo) {
            openAlertDialog(context, 'No se pudo grabar la inactividad',
                subMensaje: response.error);
          } else {
            _obraService.obra.diasInactivos[index] = inactividad.toMap();
            openAlertDialog(context, 'Inactividad actualizada');
          }
        }, '¿Seguro que desea actualizar la inactividad?');
      };
      // fin accion al grabar
    } else {
      //NUEVA INACTIVIDAD
      String formattedDate = DateFormat('dd/MM/yyyy').format(now);
      txtCtrlDate.text = formattedDate.toString();
      submitAction = () async {
        openDialogConfirmation(context, (context) async {
          openLoadingDialog(context, mensaje: 'Guardando inactividad...');

          final inactividad = new Inactividad(
              nombre: txtCtrlName.text,
              fecha: txtCtrlDate.text,
              fileName: txtCtrlFile.text,
              usuarioId: _pref.id,
              privado: esPrivado);
          MyResponse response;
          response = await _obraService.nuevaInactividad(obraId, inactividad);
          closeLoadingDialog(context);

          if (response.fallo) {
            openAlertDialog(context, 'No se pudo grabar la inactividad',
                subMensaje: response.error);
          } else {
            openAlertDialog(context, 'Inactividad generada');
          }
        }, '¿Seguro que desea generar la inactividad?');
      };
    }

    DateTime selectedDate = DateTime.now();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 35),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: Helper.brandColors[1]),
      child: SafeArea(
          child: Column(
        children: [
          Logo(),
          SizedBox(
            height: 40,
          ),
          Text(
            textAction.toUpperCase(),
            style: TextStyle(
                foreground: Paint()
                  ..shader = Helper.getGradient(
                      [Helper.brandColors[8], Helper.brandColors[9]]),
                fontSize: 23),
          ),
          SizedBox(
            height: 40,
          ),
          CustomInput(
              hintText: 'NOMBRE',
              icono: Icons.more_horiz,
              textController: txtCtrlName),
          CustomFormInput(
            // enable: edit,
            hintText: ('Fecha').toUpperCase(),
            icono: Icons.abc,
            textController: txtCtrlDate,
            iconButton: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () {
                  selectDate(
                    context,
                    txtCtrlDate,
                    selectedDate,
                  );
                }),
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MainButton(
                color: Helper.brandColors[8],
                onPressed: submitAction,
                text: 'Guardar',
                width: 100,
              ),
              SecondaryButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Cancelar',
                  width: 100,
                  color: Helper.brandColors[2]),
            ],
          )
        ],
      )),
    );
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



/*import 'dart:io';

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
                  // decoration: Helper.formDecoration,
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
        decoration: BoxDecoration(color: Helper.brandColors[1]),
        child: SafeArea(
            child: Column(
          children: [
            Logo(),
            SizedBox(
              height: 40,
            ),
            Text(
              'NUEVO INACTIVIDAD',
              style: TextStyle(
                  foreground: Paint()
                    ..shader = Helper.getGradient(
                        [Helper.brandColors[8], Helper.brandColors[9]]),
                  fontSize: 23),
            ),
            SizedBox(
              height: 40,
            ),
            CustomInput(
                hintText: 'NOMBRE',
                icono: Icons.more_horiz,
                textController: txtCtrlName),
            CustomFormInput(
              // enable: edit,
              hintText: ('Fecha').toUpperCase(),
              icono: Icons.abc,
              textController: txtCtrlDate,
              iconButton: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    selectDate(
                      context,
                      txtCtrlDate,
                      selectedDate,
                    );
                  }),
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MainButton(
                  color: Helper.brandColors[8],
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
                        await _obraService.nuevaInactividad(
                            obraId, inactividad);
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
                ),
                SecondaryButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Cancelar',
                    width: 100,
                    color: Helper.brandColors[2]),
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

*/