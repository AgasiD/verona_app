import 'dart:async';

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
import 'package:verona_app/models/message.dart';
import 'package:verona_app/pages/listas/documentos.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ImagenesForm extends StatelessWidget {
  static final routeName = 'ImagenForm';
  const ImagenesForm({Key? key}) : super(key: key);

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
  DateTime now = DateTime.now();
  Preferences _pref = new Preferences();
  String textAction = 'Subir imagen';

  bool esPrivado = false;
  bool imagenSelected = false;
  String imgButtonText = 'Seleccionar imagenes';
  late ObraService _obraService;
  late GoogleDriveService _driveService;
  @override
  void initState() {
    super.initState();
    _driveService = Provider.of<GoogleDriveService>(context, listen: false);
    _obraService = Provider.of<ObraService>(context, listen: false);
    final _pref = new Preferences();
  }

  @override
  Widget build(BuildContext context) {
    //NUEVO DOCUMENTO
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final driveId = arguments['driveId'];

    final submitAction = () async {
      if (imagenSelected) {
        if (txtCtrlName.text.trim() != '') {
          openDialogConfirmation(context, (context) async {
            String msg = 'Subiendo imagenes...';
            openLoadingDialog(context, mensaje: msg);
            MyResponse response;
            try {
              final res = await _driveService.grabarImagenes(
                  driveId, txtCtrlName.text == '' ? null : txtCtrlName.text);
              closeLoadingDialog(context);
              openAlertDialog(context, 'Imagenes subidas');
              Timer(Duration(milliseconds: 750), () => Navigator.pop(context));
              Timer(Duration(milliseconds: 750), () => Navigator.pop(context));
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
    };

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
          Container(
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
                              color: Helper.brandColors[9].withOpacity(.6),
                            )),
                    Text(imgButtonText, style: TextStyle(fontSize: 16)),
                  ],
                ),
                onPressed: () async {
                  try {
                    final ImagePicker _picker = ImagePicker();
                    // Pick an image
                    final List<XFile>? images = await _picker.pickMultiImage();
                    if (images != null) {
                      _driveService.guardarImagenes(images);
                      setState(() {
                        imagenSelected = true;
                        imgButtonText =
                            'Imagenes seleccionadas (${_driveService.obtenerCantidadImgSeleccionada()})';
                      });
                    }
                  } catch (e) {
                    openAlertDialog(context, e.toString());
                  }
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
