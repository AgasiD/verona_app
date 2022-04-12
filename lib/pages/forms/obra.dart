// ignore_for_file: unused_import, prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

//import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/addpropietarios.dart';

import 'package:verona_app/pages/form.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/loading_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ObraForm extends StatefulWidget implements MyForm {
  static const String routeName = 'obraForm';
  static String nameForm = 'Nueva obra';
  static String alertMessage = 'Confirmar nueva obra';

  ObraForm({Key? key}) : super(key: key);
  @override
  State<ObraForm> createState() => _ObraFormState();
}

final TextEditingController txtNombreCtrl = TextEditingController();
final TextEditingController txtBarrioCtrl = TextEditingController();
final TextEditingController txtLoteCtrl = TextEditingController();
final TextEditingController txtDuracionCtrl = TextEditingController();

class _ObraFormState extends State<ObraForm> {
  bool imageSelected = false;
  @override
  Widget build(BuildContext context) {
    String imgButtonText;
    if (imageSelected == false) {
      imgButtonText = 'Seleccionar imagen';
    } else {
      imgButtonText = 'Imagen seleccionada';
    }
    final _driveService = Provider.of<GoogleDriveService>(context);

    return Scaffold(
        appBar: CustomAppBar(
          muestraBackButton: true,
          title: 'Nuva obra',
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
                    hintText: 'Nombre del proyecto',
                    icono: Icons.house,
                    textController: txtNombreCtrl,
                    validaError: true,
                    validarInput: (value) => Helper.campoObligatorio(value),
                  ),
                  CustomInput(
                    hintText: 'Barrio',
                    icono: Icons.holiday_village_outlined,
                    validaError: true,
                    validarInput: (value) => Helper.campoObligatorio(value),
                    textController: txtBarrioCtrl,
                  ),
                  CustomInput(
                    hintText: 'Lote',
                    icono: Icons.format_list_numbered,
                    textController: txtLoteCtrl,
                    validaError: true,
                    validarInput: (value) {
                      Helper.campoObligatorio(value);
                      return Helper.validNumeros(value);
                    },
                  ),
                  CustomInput(
                    hintText: 'Duracion estimada (días)',
                    icono: Icons.hourglass_bottom,
                    textController: txtDuracionCtrl,
                    teclado: TextInputType.number,
                    validaError: true,
                    validarInput: (value) {
                      return Helper.validNumeros(value);
                    },
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: MaterialButton(
                        color: Helper.primaryColor,
                        textColor: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(imgButtonText, style: TextStyle(fontSize: 16)),
                            imageSelected
                                ? Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(Icons.check))
                                : Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(Icons.photo_library_outlined))
                          ],
                        ),
                        onPressed: () async {
                          final ImagePicker _picker = ImagePicker();
                          // Pick an image
                          final image = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            _driveService.guardarImagen(image!);
                            setState(() {
                              print(image);
                              imageSelected = true;
                            });
                          }
                        }),
                  ),
                  SizedBox(height: 40),
                  SecondaryButton(
                      onPressed: () async {
                        grabarObra(context);
                      },
                      text: 'Grabar'),
                  SizedBox(height: 10),
                  MainButton(
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

  grabarObra(BuildContext context) async {
    bool isValid = true;
    final _service = Provider.of<ObraService>(context, listen: false);
    final _driveService =
        Provider.of<GoogleDriveService>(context, listen: false);

    txtNombreCtrl.text.trim() == '' ? isValid = false : true;
    txtBarrioCtrl.text.trim() == '' ? isValid = false : true;
    int.tryParse(txtLoteCtrl.text) == null ? isValid = false : true;
    int.tryParse(txtDuracionCtrl.text) == null ? isValid = false : true;

    if (isValid) {
      final obra = Obra(
          nombre: txtNombreCtrl.text,
          barrio: txtBarrioCtrl.text,
          lote: int.parse(txtLoteCtrl.text),
          propietarios: [],
          diasEstimados: int.parse(txtDuracionCtrl.text));
      if (_driveService.imagenValida()) {
        openLoadingDialog(context, mensaje: 'Subiendo imagen');
        final imageResponse = await _driveService.grabarImagen(obra.nombre);
        obra.imageId = imageResponse;
        closeLoadingDialog(context);
      }
      openLoadingDialog(context, mensaje: 'Grabando obra...');
      Map<String, dynamic> response = await _service.grabarObra(obra);
      final obraResponse = Obra.fromMap(response["obra"]);
      txtNombreCtrl.text = '';
      txtBarrioCtrl.text = '';
      txtLoteCtrl.text = '';
      txtDuracionCtrl.text = '';
      closeLoadingDialog(context);
      Timer(Duration(milliseconds: 750), () {
        Navigator.of(context).popAndPushNamed('obras');
      });
    } else {
      openAlertDialog(context, 'Formulario invalido');
    }
  }
}
