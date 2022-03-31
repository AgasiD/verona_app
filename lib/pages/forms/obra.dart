// ignore_for_file: unused_import, prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/addpropietarios.dart';

import 'package:verona_app/pages/form.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ObraForm extends StatefulWidget implements MyForm {
  static const String routeName = 'obras';
  static String nameForm = 'Nueva obra';
  static String alertMessage = 'Confirmar nueva obra';
  static Function accion = (BuildContext context) async {
    bool isValid = true;
    final _service = Provider.of<ObraService>(context, listen: false);

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
      await _service.grabarObra(obra);
      openAlertDialog(context, 'Obra creada');
      Timer(Duration(milliseconds: 750),
          () => Navigator.of(context).popAndPushNamed('obras'));
    } else {
      openAlertDialog(context, 'Formulario invalido');
    }
  };
  const ObraForm({Key? key}) : super(key: key);
  @override
  State<ObraForm> createState() => _ObraFormState();
}

final TextEditingController txtNombreCtrl = TextEditingController();
final TextEditingController txtBarrioCtrl = TextEditingController();
final TextEditingController txtLoteCtrl = TextEditingController();
final TextEditingController txtDuracionCtrl = TextEditingController();

class _ObraFormState extends State<ObraForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 25),
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
              MaterialButton(
                  child: Text('Cargar imagen'),
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    print(result);
                    if (result != null) {
                      File file = File(result.files.single.path!);
                    } else {
                      // User canceled the picker
                    }
                  })
              // TODO agregar fotos
            ],
          ),
        ),
      ),
    );
  }
}
