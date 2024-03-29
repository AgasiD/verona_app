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

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ObraForm extends StatelessWidget {
  ObraForm({Key? key}) : super(key: key);
  static const String routeName = 'obraForm';
  static String nameForm = 'Nueva obra';
  static String alertMessage = 'Confirmar nueva obra';
  final TextEditingController txtNombreCtrl = TextEditingController();
  final TextEditingController txtBarrioCtrl = TextEditingController();
  final TextEditingController txtLoteCtrl = TextEditingController();
  final TextEditingController txtDuracionCtrl = TextEditingController();
  final TextEditingController txtDescripCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final _obraService = Provider.of<ObraService>(context, listen: false);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Helper.brandColors[1],
        child: SafeArea(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: obraId == null
                    ? _Form(
                        txtNombre: txtNombreCtrl,
                        txtBarrio: txtBarrioCtrl,
                        txtLote: txtLoteCtrl,
                        txtDescrip: txtDescripCtrl,
                        txtDuracion: txtDuracionCtrl)
                    : FutureBuilder(
                        future: _obraService.obtenerObra(obraId),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Loading(
                              mensaje: 'Cargando obra',
                            );
                          } else {
                            final obra = snapshot.data as Obra;

                            return _Form(
                                obra: snapshot.data as Obra,
                                txtNombre: txtNombreCtrl,
                                txtBarrio: txtBarrioCtrl,
                                txtLote: txtLoteCtrl,
                                txtDescrip: txtDescripCtrl,
                                txtDuracion: txtDuracionCtrl);
                          }
                        }))),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _Form extends StatefulWidget {
  @override
  TextEditingController txtNombre, txtBarrio, txtLote, txtDescrip, txtDuracion;
  Obra? obra;
  _Form(
      {Key? key,
      this.obra,
      required this.txtNombre,
      required this.txtBarrio,
      required this.txtLote,
      required this.txtDescrip,
      required this.txtDuracion})
      : super(key: key);

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  bool imageSelected = false;

  bool edit = false;

  String imgButtonText = '';

  @override
  void initState() {
    super.initState();

    if (widget.obra != null) {
      // edit = true;
      widget.txtNombre.text = widget.obra!.nombre;
      widget.txtBarrio.text = widget.obra!.barrio;
      widget.txtLote.text = widget.obra!.lote;
      widget.txtDescrip.text = widget.obra!.descripcion;
      widget.txtDuracion.text = widget.obra!.diasEstimados == 0
          ? ''
          : widget.obra!.diasEstimados.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _driveService = Provider.of<GoogleDriveService>(context);
    if (imageSelected == false) {
      imgButtonText = 'Seleccionar imagen';
      if (edit) {
        imgButtonText = 'Cambiar imagen';
      }
    } else {
      imgButtonText = 'Imagen seleccionada';
    }
    if (widget.obra != null) {
      edit = true;
    }

    return SingleChildScrollView(
        child: Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          Logo(ring: false, size: 75),
          SizedBox(
            height: 40,
          ),
          Text(
            edit ? 'EDITAR PROYECTO' : 'NUEVO PROYECTO',
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
            hintText: 'Nombre del proyecto',
            icono: Icons.house,
            textController: widget.txtNombre,
            validaError: true,
            validarInput: (value) => Helper.campoObligatorio(value),
          ),
          CustomInput(
            hintText: 'Barrio',
            icono: Icons.holiday_village_outlined,
            validaError: true,
            validarInput: (value) => Helper.campoObligatorio(value),
            textController: widget.txtBarrio,
          ),
          CustomInput(
              hintText: 'Lote',
              icono: Icons.format_list_numbered,
              textController: widget.txtLote,
              validaError: true,
              validarInput: (value) => Helper.campoObligatorio(value)),
          CustomInput(
            hintText: 'Duración estimada (días)',
            icono: Icons.hourglass_bottom,
            textController: widget.txtDuracion,
            teclado: TextInputType.numberWithOptions(signed: true),
            validaError: true,
            validarInput: (value) {
              return Helper.validNumeros(value);
            },
            textInputAction: TextInputAction.done,
          ),
          CustomInput(
            hintText: 'Descripción',
            icono: Icons.description_outlined,
            textController: widget.txtDescrip,
            lines: 3,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: MaterialButton(
                color: Helper.primaryColor,
                textColor: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    imageSelected
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
                  final ImagePicker _picker = ImagePicker();
                  // Pick an image
                  final image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    _driveService.guardarImagen(image!);
                    setState(() {
                      imageSelected = true;
                    });
                  }
                }),
          ),
          SizedBox(height: 40),
          Container(
            margin: EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MainButton(
                  width: 120,
                  fontSize: 18,
                  color: Helper.brandColors[8].withOpacity(.5).withAlpha(150),
                  text: 'Grabar',
                  onPressed: () async {
                    edit
                        ? actualizarObra(
                            context, widget.obra!.id, widget.obra!.imageId)
                        : grabarObra(context);
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
            ),
          )
        ],
      ),
    ));
  }

  void dispose() {
    super.dispose();

    widget.txtNombre.text = '';
    widget.txtBarrio.text = '';
    widget.txtLote.text = '';
    widget.txtDuracion.text = '';
    widget.txtDescrip.text = '';
  }

  grabarObra(BuildContext context) async {
    bool isValid = true;
    final _service = Provider.of<ObraService>(context, listen: false);
    final _driveService =
        Provider.of<GoogleDriveService>(context, listen: false);

    widget.txtNombre.text.trim() == '' ? isValid = false : true;
    widget.txtBarrio.text.trim() == '' ? isValid = false : true;
    widget.txtLote.text.trim() == '' ? isValid = false : true;
    int.tryParse(widget.txtDuracion.text) == null ? isValid = false : true;

    if (isValid) {
      final obra = Obra(
          nombre: widget.txtNombre.text,
          barrio: widget.txtBarrio.text,
          lote: widget.txtLote.text,
          propietarios: [],
          descripcion: widget.txtDescrip.text,
          diasEstimados: int.parse(widget.txtDuracion.text));
      if (_driveService.imagenValida()) {
        openLoadingDialog(context, mensaje: 'Subiendo imagen');
        final imageResponse = await _driveService.grabarImagen(obra.nombre);
        obra.imageId = imageResponse;
        closeLoadingDialog(context);
      }
      openLoadingDialog(context, mensaje: 'Grabando obra...');
      Map<String, dynamic> response = await _service.grabarObra(obra);
      final obraResponse = Obra.fromMap(response["obra"]);
      widget.txtNombre.text = '';
      widget.txtBarrio.text = '';
      widget.txtLote.text = '';
      widget.txtDuracion.text = '';
      widget.txtDescrip.text = '';
      closeLoadingDialog(context);
      openLoadingDialog(context, mensaje: 'Grabando obra...');
      Timer(Duration(milliseconds: 750), () {
        openLoadingDialog(context, mensaje: 'Obra guardada');
      });
      Timer(Duration(milliseconds: 750), () {
        Navigator.of(context).popAndPushNamed('obras');
      });
    } else {
      openAlertDialog(context, 'Formulario invalido');
    }
  }

  actualizarObra(BuildContext context, String obraId, String imageId) async {
    bool isValid = true;
    final _service = Provider.of<ObraService>(context, listen: false);
    final _driveService =
        Provider.of<GoogleDriveService>(context, listen: false);

    widget.txtNombre.text.trim() == '' ? isValid = false : true;
    widget.txtBarrio.text.trim() == '' ? isValid = false : true;
    widget.txtLote.text.trim() == '' ? isValid = false : true;
    int.tryParse(widget.txtDuracion.text) == null ? isValid = false : true;

    if (isValid) {
      widget.obra!.nombre = widget.txtNombre.text;
      widget.obra!.barrio = widget.txtBarrio.text;
      widget.obra!.lote = widget.txtLote.text;
      widget.obra!.descripcion = widget.txtDescrip.text;
      widget.obra!.diasEstimados = int.parse(widget.txtDuracion.text);
      widget.obra!.id = obraId;

      if (imageSelected) {
        if (_driveService.imagenValida()) {
          // subir imagen
          openLoadingDialog(context, mensaje: 'Subiendo imagen');
          final imageResponse =
              await _driveService.grabarImagen(widget.obra!.nombre);
          widget.obra!.imageId = imageResponse;
          closeLoadingDialog(context);
        }
      }
      openLoadingDialog(context, mensaje: 'Actualizando obra...');
      Map<String, dynamic> response =
          await _service.actualizarObra(widget.obra!);
      final obraResponse = Obra.fromMap(response["obra"]);
      closeLoadingDialog(context);
      openLoadingDialog(context, mensaje: 'Obra modificada');
      Timer(Duration(milliseconds: 750), () {
        closeLoadingDialog(context);
      });
      Timer(Duration(milliseconds: 750), () {
        Navigator.of(context).popAndPushNamed('obras');
      });
    } else {
      openAlertDialog(context, 'Formulario invalido');
    }
  }
}
