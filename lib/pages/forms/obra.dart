// ignore_for_file: unused_import, prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:io';
import 'dart:math';

//import 'package:file_picker/file_picker.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/error.dart';

import 'package:verona_app/pages/form.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/image_service.dart';
import 'package:verona_app/services/loading_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';
import 'package:verona_app/widgets/map_coordinates.dart';

import '../../helpers/Enviroment.dart';

class ObraForm extends StatelessWidget {
  ObraForm({Key? key}) : super(key: key);
  static const String routeName = 'obraForm';
  static String nameForm = 'Nueva obra';
  static String alertMessage = 'Confirmar nueva obra';

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final _obraService = Provider.of<ObraService>(context, listen: false);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Helper.brandColors[1],
          child: SafeArea(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: obraId == null
                      ? _Form()
                      : FutureBuilder(
                          future: _obraService.obtenerObra(obraId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return Loading(
                                mensaje: 'Recuperando obra...',
                              );
                            } else if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasError) {
                              return ErrorPage(
                                errorMsg: snapshot.error.toString(),
                              );
                            }
                            final obra = snapshot.data as Obra;

                            return _Form(
                              obra: snapshot.data as Obra,
                            );
                          }))),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _Form extends StatefulWidget {
  @override
  Obra? obra;
  _Form({
    Key? key,
    this.obra,
  }) : super(key: key);

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  bool imageSelected = false;

  bool edit = false, crearDrive = true;

  String imgButtonText = '';
  DateTime selectedDate = DateTime.now();
  double? latitud = null;
  double? longitud = null;

  final TextEditingController txtNombreCtrl = TextEditingController();
  final TextEditingController txtBarrioCtrl = TextEditingController();
  final TextEditingController txtLoteCtrl = TextEditingController();
  final TextEditingController txtDescripCtrl = TextEditingController();
  final TextEditingController txtDiaInicio = TextEditingController();
  final TextEditingController txtIdDrive = TextEditingController();
  final TextEditingController txtDuracionCtrl = TextEditingController();
  final TextEditingController txtCoordenadas = TextEditingController();
  @override
  void initState() {
    if (!Environment.isProduction) crearDrive = false;
    super.initState();

    if (widget.obra != null) {
      // edit = true;
      txtNombreCtrl.text = widget.obra!.nombre;
      txtBarrioCtrl.text = widget.obra!.barrio;
      txtLoteCtrl.text = widget.obra!.lote;
      txtDescripCtrl.text = widget.obra!.descripcion;
      txtDiaInicio.text = widget.obra!.driveFolderId ?? "";
      txtDuracionCtrl.text = widget.obra!.diasEstimados == 0
          ? ''
          : widget.obra!.diasEstimados.toString();
      txtIdDrive.text = widget.obra!.driveFolderId!;
      final f = new DateFormat('dd/MM/yyyy');
      txtDiaInicio.text = f
          .format(
              new DateTime.fromMillisecondsSinceEpoch(widget.obra!.diaInicio))
          .toString();
      txtCoordenadas.text = widget.obra!.ubicToText();
    } else {
      final f = new DateFormat('dd/MM/yyyy');
      txtDiaInicio.text = f.format(DateTime.now()).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _imageService = Provider.of<ImageService>(context);
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  validarInput: (value) => Helper.campoObligatorio(value)),
              Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: CustomInput(
                    icono: Icons.calendar_month,
                    hintText: 'Fecha inicio (dd/mm/aaaa)',
                    readOnly: true,
                    enable: true,
                    // width: 200,
                    textController: txtDiaInicio,
                    iconButton: IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: Helper.brandColors[3],
                        ),
                        onPressed: () {
                          selectDateDeseada(
                            context,
                            txtDiaInicio,
                            selectedDate,
                          );
                        }),
                  )),
              CustomInput(
                hintText: 'Duración estimada (días)',
                icono: Icons.hourglass_bottom,
                textController: txtDuracionCtrl,
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
                textController: txtDescripCtrl,
                lines: 3,
              ),
              CustomInput(
                  hintText: 'Ubicación',
                  readOnly: true,
                  iconButton: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Helper.brandColors[4],
                    ),
                    onPressed: () async => openMap(),
                  ),
                  icono: Icons.location_on_outlined,
                  textController: txtCoordenadas),
              Visibility(
                visible: edit,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: CustomInput(
                      hintText: "Id de carpeta drive",
                      icono: FontAwesomeIcons.googleDrive,
                      textController: txtIdDrive,
                      iconButton: IconButton(
                          onPressed: () => refreshDriveId(),
                          icon: Icon(
                            Icons.refresh,
                            color: Helper.brandColors[4],
                          ))),
                ),
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
                      openAlertDialog('Seleccionar imagen');
                      final image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      closeLoadingDialog();
                      if (image != null) {
                        if (await Helper.getWeigth(image!) >= 32.00) {
                          openAlertDialog('Imagen debe ser menor a 32 MB.');
                          return;
                        }
                        _imageService.guardarImagen(image!);
                        setState(() {
                          imageSelected = true;
                        });
                      }
                    }),
              ),
              Visibility(
                visible: !edit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Crear carpeta en Drive',
                      style:
                          TextStyle(fontSize: 18, color: Helper.brandColors[4]),
                    ),
                    Checkbox(
                        activeColor: Helper.brandColors[8],
                        value: crearDrive,
                        onChanged: (a) {
                          setState(() {
                            crearDrive = a!;
                          });
                        })
                  ],
                ),
              ),
              SizedBox(height: 40),
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MainButton(
                      width: 95,
                      fontSize: 18,
                      color:
                          Helper.brandColors[8].withOpacity(.5).withAlpha(150),
                      text: 'Grabar',
                      onPressed: () async {
                        edit
                            ? actualizarObra(
                                context, widget.obra!.id, widget.obra!.imageId)
                            : grabarObra(context);
                      },
                    ),
                    SecondaryButton(
                        width: 95,
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

  void selectDateDeseada(context, txtCtrlDate, selectedDate) async {
    double width = MediaQuery.of(context).size.width * .8;

    double height = MediaQuery.of(context).size.height * .5;
    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        selectedDayHighlightColor: Helper.brandColors[8],
        calendarType: CalendarDatePicker2Type.single,
        //shouldCloseDialogAfterCancelTapped: true,
      ),
      dialogSize: Size(width, height),
      value: [selectedDate],
      borderRadius: BorderRadius.circular(5),
    );

    if (results != null) {
      final date = results![0];
      String formattedDate = DateFormat('dd/MM/yyyy').format(date!);

      txtCtrlDate.text = formattedDate.toString();
      txtDiaInicio.text = formattedDate.toString();

      selectedDate = date;
    }
  }

  void dispose() {
    super.dispose();

    txtNombreCtrl.text = '';
    txtBarrioCtrl.text = '';
    txtLoteCtrl.text = '';
    txtDuracionCtrl.text = '';
    txtDescripCtrl.text = '';
  }

  grabarObra(BuildContext context) async {
    bool loading = true;
    bool isValid = true;
    final _service = Provider.of<ObraService>(context, listen: false);
    final _imageService = Provider.of<ImageService>(context, listen: false);
    try {
      txtNombreCtrl.text.trim() == '' ? isValid = false : true;
      txtBarrioCtrl.text.trim() == '' ? isValid = false : true;
      txtLoteCtrl.text.trim() == '' ? isValid = false : true;
      int.tryParse(txtDuracionCtrl.text) == null ? isValid = false : true;

      if (!isValid) throw new Exception('Formulario invalido');

      final obra = Obra(
          nombre: txtNombreCtrl.text,
          barrio: txtBarrioCtrl.text,
          lote: txtLoteCtrl.text,
          propietarios: [],
          latitud: latitud ?? null,
          longitud: longitud ?? null,
          descripcion: txtDescripCtrl.text,
          diasEstimados: int.parse(txtDuracionCtrl.text),
          diaInicio: new DateFormat("dd/MM/yyyy")
              .parse(txtDiaInicio.text)
              .millisecondsSinceEpoch);

      if (_imageService.imagenValida()) {
        openLoadingDialog(mensaje: 'Subiendo imagen');
        final dataImage = await _imageService.grabarImagen(obra.nombre);
        if (!dataImage['success'])
          throw new Exception('No se pudo cargar imagen');

        final imageUrl = dataImage['data']['url'];
        obra.imageURL = imageUrl;
        loading = false;
        closeLoadingDialog();
      }

      openLoadingDialog(mensaje: 'Grabando obra...');
      dynamic obra_response = await _service.grabarObra(obra, crearDrive);
      final obraResponse = Obra.fromMap(obra_response as Map<String, dynamic>);
      txtNombreCtrl.clear();
      txtBarrioCtrl.clear();
      txtLoteCtrl.clear();
      txtDuracionCtrl.clear();
      txtDescripCtrl.clear();
      txtCoordenadas.clear();
      _imageService.descartarImagen();

      closeLoadingDialog();

      _service.obra = obraResponse;

      await openAlertDialogReturn('Obra creada con éxito');
      Navigator.pushReplacementNamed(context, ObraPage.routeName,
          arguments: {"obraId": obraResponse.id});
    } catch (err) {
      closeLoadingDialog();

      openAlertDialog('Error al grabar formulario', subMensaje: err.toString());
    }
  }

  actualizarObra(BuildContext context, String obraId, String imageId) async {
    bool isValid = true, loading = false;
    try {
      final _service = Provider.of<ObraService>(context, listen: false);
      final _imageService = Provider.of<ImageService>(context, listen: false);

      txtNombreCtrl.text.trim() == '' ? isValid = false : true;
      txtBarrioCtrl.text.trim() == '' ? isValid = false : true;
      txtLoteCtrl.text.trim() == '' ? isValid = false : true;
      int.tryParse(txtDuracionCtrl.text) == null ? isValid = false : true;
      if (isValid) {
        widget.obra!.nombre = txtNombreCtrl.text;
        widget.obra!.barrio = txtBarrioCtrl.text;
        widget.obra!.lote = txtLoteCtrl.text;
        widget.obra!.descripcion = txtDescripCtrl.text;
        widget.obra!.diasEstimados = int.parse(txtDuracionCtrl.text);
        widget.obra!.id = obraId;
        widget.obra!.diaInicio = new DateFormat("dd/MM/yyyy")
            .parse(txtDiaInicio.text)
            .millisecondsSinceEpoch;

        if (_imageService.imagenValida()) {
          openLoadingDialog(mensaje: 'Subiendo imagen');
          loading = true;
          final dataImage =
              await _imageService.grabarImagen(widget.obra!.nombre);
          if (!dataImage['success']) {
            closeLoadingDialog();
            openAlertDialog('No se pudo cargar imagen');
            return;
          }
          final imageUrl = dataImage['data']['url'];

          widget.obra!.imageURL = imageUrl;
          closeLoadingDialog();
          loading = false;
        }
        openLoadingDialog(mensaje: 'Actualizando obra...');
        loading = true;
        Map<String, dynamic> response = await _service.actualizarObra({
          'id': widget.obra!.id,
          'nombre': widget.obra!.nombre,
          'barrio': widget.obra!.barrio,
          'lote': widget.obra!.lote,
          'diaInicio': widget.obra!.diaInicio,
          'diasEstimados': widget.obra!.diasEstimados,
          'descripcion': widget.obra!.descripcion,
          'latitud': widget.obra!.latitud,
          'longitud': widget.obra!.longitud,
          'driveFolderId': widget.obra!.driveFolderId,
          'imageURL': widget.obra!.imageURL,
        });
        final obraResponse = Obra.fromMap(response["response"]);
        _imageService.descartarImagen();
        closeLoadingDialog();
        loading = true;
        await openAlertDialogReturn('Obra modificada con éxito');

        Navigator.pop(context);
      } else {
        openAlertDialog('Formulario invalido');
      }
    } catch (err) {
      closeLoadingDialog();
      openAlertDialog('Error al actualizar', subMensaje: err.toString());
      return;
    }
  }

  refreshDriveId() async {
    if (txtIdDrive.text.isEmpty)
      throw new Exception('Ingrese ID de carpeta para actualizar');

    openLoadingDialog(mensaje: "Actualizando carpetas de obra...");
    final _obraService = Provider.of<ObraService>(context, listen: false);
    try {
      final response = await _obraService.actualizarIdDrive(txtIdDrive.text);
      closeLoadingDialog();
      await openAlertDialogReturn("Carpetas actualizadas con éxito");
      widget.obra!.driveFolderId = response.data["driveFolderId"];
      widget.obra!.folderImages = response.data["folderImages"];
      widget.obra!.rootDriveCliente = response.data["rootDriveCliente"];
      widget.obra!.folderImagesCliente = response.data["folderImagesCliente"];
      widget.obra!.articulosId = response.data["articulosId"] ?? '';

      _obraService.notifyListeners();
    } catch (err) {
      openAlertDialog( "Error al actualizar carpetas", subMensaje: err.toString());
    }
  }

  openMap() async {
    dynamic arguments = null;
    if (edit)
      arguments = {
        'latitud': widget.obra!.latitud,
        'longitud': widget.obra!.longitud
      };
    Marker? coordenadas = await Navigator.pushNamed(
        context, MapCoordenates.routeName,
        arguments: arguments) as Marker?;

    if (coordenadas != null) {
      if (edit) {
        widget.obra!.latitud = coordenadas.position.latitude;
        widget.obra!.longitud = coordenadas.position.longitude;
        txtCoordenadas.text = widget.obra!.ubicToText();
      } else {
        latitud = coordenadas.position.latitude;
        longitud = coordenadas.position.longitude;
        txtCoordenadas.text = '${latitud} ${longitud}';
      }
    }
  }
}
