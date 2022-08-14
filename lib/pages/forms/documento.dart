import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/listas/documentos.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class DocumentoForm extends StatelessWidget {
  static final routeName = 'DocumentoForm';
  const DocumentoForm({Key? key}) : super(key: key);

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

class _Form extends StatefulWidget {
  _Form({Key? key}) : super(key: key);

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  DateTime now = DateTime.now();
  TextEditingController txtCtrlName = new TextEditingController(),
      txtCtrlFile = new TextEditingController(),
      txtCtrlDate = new TextEditingController();
  Preferences _pref = new Preferences();
  String inactividadId = '',
      textAction = 'Nuevo documento',
      imgButtonText = 'Seleccionar documento';
  bool edit = false,
      habilitaPropietario = false,
      documentSelected = false,
      imagenSelected = false;
  List<DropdownMenuItem<String>> formato = <DropdownMenuItem<String>>[
    DropdownMenuItem(
      value: '1',
      child: Text('Imagen'.toUpperCase()),
    ),
    DropdownMenuItem(
      value: '2',
      child: Text('Archivo'.toUpperCase()),
    ),
    DropdownMenuItem(
      value: '3',
      child: Text('Carpeta'.toUpperCase()),
    ),
  ];
  late int index;
  late String fileType = formato.first.value.toString();
  late String obraId;
  late ObraService _obraService;
  late Inactividad inactividad;
  late GoogleDriveService _driveService;
  late Function() submitAction;

  @override
  void initState() {
    super.initState();
    _driveService = Provider.of<GoogleDriveService>(context, listen: false);
    _obraService = Provider.of<ObraService>(context, listen: false);
    final _pref = new Preferences();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final driveId = arguments['driveId'];

    submitAction = () async {
      if (fileType == '1') {
        if (imagenSelected) {
          if (txtCtrlName.text.trim() != '') {
            openDialogConfirmation(context, (context) async {
              String msg = 'Subiendo imagenes...';
              openLoadingDialog(context, mensaje: msg);
              MyResponse response;
              try {
                final res = await _driveService.grabarImagenes(
                    driveId, txtCtrlName.text == '' ? null : txtCtrlName.text);
                if ((habilitaPropietario && res.length > 0) ||
                    _pref.role == 3) {
                  // modificar obra
                  final response = await _obraService.addEnabledFiles(
                      res, _obraService.obra.id);
                  _obraService.obra.enabledFiles
                      .insertAll(_obraService.obra.enabledFiles.length, res);
                  if (response.fallo) {
                    closeLoadingDialog(context);
                    openAlertDialog(context, response.message);
                  }
                }
                closeLoadingDialog(context);
                openAlertDialog(context, 'Imagenes subidas');
                Timer(
                    Duration(milliseconds: 750), () => Navigator.pop(context));
                Timer(
                    Duration(milliseconds: 750), () => Navigator.pop(context));
              } catch (err) {
                closeLoadingDialog(context);
                openAlertDialog(context, 'Error al subir imagen',
                    subMensaje: err.toString());
              }
            }, '¿Seguro que desea subir este documento?');
          } else {
            openAlertDialog(context, 'Debe ingresar un nombre al documento');
          }
        } else {
          openAlertDialog(context, 'No se ha seleccionado ningun documento');
        }
        ;
      }
      if (fileType == '2') {
        if (documentSelected) {
          if (txtCtrlName.text.trim() != '') {
            openDialogConfirmation(context, (context) async {
              openLoadingDialog(context, mensaje: 'Subiendo documento...');
              MyResponse response;
              try {
                final res = await _driveService.grabarDocumento(
                    txtCtrlName.text,
                    _driveService.getExtension(),
                    _obraService.obra.driveFolderId!);

                closeLoadingDialog(context);
                openAlertDialog(context, 'Documento subido');
                Timer(
                    Duration(milliseconds: 750),
                    () => Navigator.pushReplacementNamed(
                        context, DocumentosPage.routeName,
                        arguments: {'driveId': driveId}));
              } catch (err) {
                closeLoadingDialog(context);
                openAlertDialog(context, 'Error al subir imagen',
                    subMensaje: err.toString());
              }
            }, '¿Seguro que desea subir este documento?');
          } else {
            openAlertDialog(context, 'Debe ingresar un nombre al documento');
          }
        } else {
          openAlertDialog(context, 'No se ha seleccionado ningun documento');
        }
      } else if (fileType == '3') {
        if (txtCtrlName.text.trim() == '') {
          openAlertDialog(context, 'No se ha asignado nombre a la carpeta');
          return;
        }
        openLoadingDialog(context, mensaje: 'Creando carpeta...');
        final res = await _driveService.crearCarpeta(txtCtrlName.text, driveId);
        closeLoadingDialog(context);

        if (res.fallo) {
          openAlertDialog(context, 'No se pudo crear la carpeta');
        } else {
          openLoadingDialog(context, mensaje: 'Carpeta generado con éxito');

          Timer(Duration(milliseconds: 750), () => closeLoadingDialog(context));
          Timer(
              Duration(milliseconds: 750),
              () => Navigator.pushReplacementNamed(
                  context, DocumentosPage.routeName,
                  arguments: {'driveId': driveId}));
        }
      }
    };

    DateTime selectedDate = DateTime.now();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 35),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: Helper.brandColors[1]),
      child: SafeArea(
          child: SingleChildScrollView(
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
            DropdownButtonFormField2(
              value: fileType,
              items: formato,
              style: TextStyle(color: Helper.brandColors[5], fontSize: 16),
              iconSize: 30,
              buttonHeight: 60,
              buttonPadding: EdgeInsets.only(left: 20, right: 10),
              decoration: getDecoration(),
              hint: Text(
                '',
                style: TextStyle(fontSize: 16, color: Helper.brandColors[3]),
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Helper.brandColors[3],
              ),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Helper.brandColors[2],
              ),
              onChanged: (value) {
                setState(() {
                  fileType = value.toString();
                  print(fileType);
                });
              },
            ),
            SizedBox(
              height: 20,
            ),
            CustomInput(
                hintText: 'NOMBRE',
                icono: Icons.more_horiz,
                textController: txtCtrlName),
            fileType == '2'
                ? Container(
                    alignment: Alignment.centerLeft,
                    child: MaterialButton(
                        color: Helper.primaryColor,
                        textColor: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            documentSelected
                                ? Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(
                                      Icons.check,
                                      color: Helper.brandColors[8],
                                    ))
                                : Padding(
                                    padding: EdgeInsets.only(right: 14),
                                    child: Icon(
                                      Icons.photo_library_outlined,
                                      color:
                                          Helper.brandColors[9].withOpacity(.6),
                                    )),
                            Text(imgButtonText, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        onPressed: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            withData: true,
                            withReadStream: true,
                            allowMultiple: false,
                            // type: FileType.custom,
                            // allowedExtensions: ['jpg', 'pdf', 'doc', 'docx', 'xls'],
                          );
                          if (result != null) {
                            PlatformFile file = result.files.first;
                            result!.files.single;
                            _driveService.guardarDocumento(result!);
                            setState(() {
                              documentSelected = true;
                            });
                          }
                        }),
                  )
                : Container(),
            fileType == '1'
                ? Container(
                    alignment: Alignment.centerLeft,
                    child: MaterialButton(
                        color: Helper.primaryColor,
                        textColor: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            imagenSelected
                                ? Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(
                                      Icons.check,
                                      color: Helper.brandColors[8],
                                    ))
                                : Padding(
                                    padding: EdgeInsets.only(right: 14),
                                    child: Icon(
                                      Icons.photo_library_outlined,
                                      color:
                                          Helper.brandColors[9].withOpacity(.6),
                                    )),
                            Text(imgButtonText, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        onPressed: () async {
                          try {
                            var acciones = [
                              {
                                "text": 'Seleccionar de galería',
                                "default": true,
                                "accion": () async {
                                  final ImagePicker _picker = ImagePicker();
                                  final List<XFile>? images =
                                      await _picker.pickMultiImage();
                                  if (images != null) {
                                    _driveService.guardarImagenes(images);
                                    Navigator.pop(context);
                                    setState(() {
                                      imagenSelected = true;
                                      imgButtonText =
                                          'Imagenes seleccionadas (${_driveService.obtenerCantidadImgSeleccionada()})';
                                    });
                                  }
                                },
                              },
                              {
                                "text": 'Abrir camara',
                                "default": false,
                                "accion": () async {
                                  final ImagePicker _picker = ImagePicker();
                                  late List<XFile>? images;
                                  final XFile? image = await _picker.pickImage(
                                      source: ImageSource.camera);
                                  if (image != null) {
                                    images = [image];
                                  } else {
                                    images = null;
                                  }

                                  if (images != null) {
                                    _driveService.guardarImagenes(images);
                                    Navigator.pop(context);
                                    setState(() {
                                      imagenSelected = true;
                                      imgButtonText =
                                          'Imagenes seleccionadas (${_driveService.obtenerCantidadImgSeleccionada()})';
                                    });
                                  }
                                },
                              },
                            ];
                            openBottomSheet(context, 'Subir documento',
                                'Seleccionar método', acciones);
                          } catch (e) {
                            openAlertDialog(context, e.toString());
                          }
                        }))
                : Container(),
            _pref.role != 3
                ? Row(
                    children: [
                      Text(
                        'Habilitar propietario'.toUpperCase(),
                        style: TextStyle(color: Helper.brandColors[5]),
                      ),
                      Switch(
                        onChanged: (habilita) {
                          habilitaPropietario = habilita;
                          setState(() {});
                        },
                        value: habilitaPropietario,
                        activeColor: Helper.brandColors[3],
                        activeTrackColor: Helper.brandColors[8],
                        inactiveTrackColor: Helper.brandColors[3],
                      )
                    ],
                  )
                : Container(),
            SizedBox(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 45),
              child: Row(
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
              ),
            )
          ],
        ),
      )),
    );
  }

  getDecoration() {
    return InputDecoration(
        focusColor: Helper.brandColors[9],
        contentPadding: EdgeInsets.zero,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Helper.brandColors[9], width: .2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Helper.brandColors[9], width: .5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Helper.brandColors[9], width: 2.0),
        ),
        fillColor: Helper.brandColors[1],
        filled: true);
  }
}
