// ignore_for_file: unused_import, prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

//import 'package:file_picker/file_picker.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
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

import 'package:verona_app/pages/form.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/image_service.dart';
import 'package:verona_app/services/loading_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';
import 'package:verona_app/widgets/map_coordinates.dart';

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
                            if (snapshot.data == null) {
                              return Loading(
                                mensaje: 'Cargando obra',
                              );
                            } else {
                              final obra = snapshot.data as Obra;

                              return _Form(
                                  obra: snapshot.data as Obra,);
                            }
                          }))),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _Form extends StatefulWidget {
  @override
 final TextEditingController  txtNombreCtrl = TextEditingController();
  final TextEditingController txtBarrioCtrl = TextEditingController();
  final TextEditingController txtLoteCtrl = TextEditingController();
  final TextEditingController txtDescripCtrl = TextEditingController();
  final TextEditingController txtDiaInicio = TextEditingController();
  final TextEditingController txtIdDrive = TextEditingController();
  final TextEditingController txtDuracionCtrl = TextEditingController();
  final TextEditingController txtCoordenadas = TextEditingController();
  Obra? obra;
  _Form(
      {Key? key,
      this.obra,})
      : super(key: key);

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  bool imageSelected = false;

  bool edit = false, crearDrive = true;

  String imgButtonText = '';
  DateTime selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();

    if (widget.obra != null) {
      // edit = true;
      widget.txtNombreCtrl.text = widget.obra!.nombre;
      widget.txtBarrioCtrl.text = widget.obra!.barrio;
      widget.txtLoteCtrl.text = widget.obra!.lote;
      widget.txtDescripCtrl.text = widget.obra!.descripcion;
      widget.txtDiaInicio.text = widget.obra!.driveFolderId ?? "";
      widget.txtDuracionCtrl.text = widget.obra!.diasEstimados == 0
          ? ''
          : widget.obra!.diasEstimados.toString();
      widget.txtIdDrive.text = widget.obra!.driveFolderId!;
      final f = new DateFormat('dd/MM/yyyy');
      widget.txtDiaInicio.text = f
          .format(
              new DateTime.fromMillisecondsSinceEpoch(widget.obra!.diaInicio))
          .toString();
      widget.txtCoordenadas.text = widget.obra!.ubicToText();
    } else {
      final f = new DateFormat('dd/MM/yyyy');
      widget.txtDiaInicio.text = f.format(DateTime.now()).toString();
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
                textController: widget.txtNombreCtrl,
                validaError: true,
                validarInput: (value) => Helper.campoObligatorio(value),
              ),
              CustomInput(
                hintText: 'Barrio',
                icono: Icons.holiday_village_outlined,
                validaError: true,
                validarInput: (value) => Helper.campoObligatorio(value),
                textController: widget.txtBarrioCtrl,
              ),
              CustomInput(
                  hintText: 'Lote',
                  icono: Icons.format_list_numbered,
                  textController: widget.txtLoteCtrl,
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
                textController: widget.txtDiaInicio,
                iconButton: IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: Helper.brandColors[3],
                    ),
                    onPressed: () {
                      selectDateDeseada(
                        context,
                        widget.txtDiaInicio,
                        selectedDate,
                      );
                    }),
              )),
              CustomInput(
                hintText: 'Duración estimada (días)',
                icono: Icons.hourglass_bottom,
                textController: widget.txtDuracionCtrl,
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
                textController: widget.txtDescripCtrl,
                lines: 3,
              ),
              CustomInput(hintText: 'Ubicación', 
              iconButton: IconButton(icon: Icon(Icons.search, color: Helper.brandColors[4],), onPressed: ()async=>openMap(),),
               icono: Icons.location_on_outlined, textController: widget.txtCoordenadas)
              ,
               Visibility(
                visible: edit,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: CustomInput(hintText: "Id de carpeta drive", icono: FontAwesomeIcons.googleDrive, textController: widget.txtIdDrive, 
                  iconButton: IconButton(onPressed: () => refreshDriveId(), icon: Icon(Icons.refresh, color: Helper.brandColors[4],))),
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
                      final image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
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
                    Text('Crear carpeta en Drive', style: TextStyle(fontSize: 18, color: Helper.brandColors[4]),),
                    Checkbox(
                      activeColor: Helper.brandColors[8],
                      value: crearDrive, onChanged: (a){
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
                      width: 120,
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
      initialValue: [selectedDate],
      borderRadius: BorderRadius.circular(5),
    );

    if (results != null) {
      final date = results![0];
      print(date);
      String formattedDate = DateFormat('dd/MM/yyyy').format(date!);

      txtCtrlDate.text = formattedDate.toString();
      widget.txtDiaInicio.text = formattedDate.toString();

      selectedDate = date;
    }
  }

  void dispose() {
    super.dispose();

    widget.txtNombreCtrl.text = '';
    widget.txtBarrioCtrl.text = '';
    widget.txtLoteCtrl.text = '';
    widget.txtDuracionCtrl.text = '';
    widget.txtDescripCtrl.text = '';
  }

  grabarObra(BuildContext context) async {
    try {
      bool isValid = true;
      final _service = Provider.of<ObraService>(context, listen: false);
      final _imageService = Provider.of<ImageService>(context, listen: false);

      widget.txtNombreCtrl.text.trim() == '' ? isValid = false : true;
      widget.txtBarrioCtrl.text.trim() == '' ? isValid = false : true;
      widget.txtLoteCtrl.text.trim() == '' ? isValid = false : true;
      int.tryParse(widget.txtDuracionCtrl.text) == null ? isValid = false : true;

      if (isValid) {
        final obra = Obra(
            nombre: widget.txtNombreCtrl.text,
            barrio: widget.txtBarrioCtrl.text,
            lote: widget.txtLoteCtrl.text,
            propietarios: [],
            descripcion: widget.txtDescripCtrl.text,
            diasEstimados: int.parse(widget.txtDuracionCtrl.text),
            diaInicio: new DateFormat("dd/MM/yyyy")
          .parse(widget.txtDiaInicio.text)
          .millisecondsSinceEpoch
            );
            
        if (_imageService.imagenValida()) {
          openLoadingDialog(context, mensaje: 'Subiendo imagen');
          final dataImage = await _imageService.grabarImagen(obra.nombre);
          if (!dataImage['success']) {
            closeLoadingDialog(context);
            openAlertDialog(context, 'No se pudo cargar imagen');
            return;
          }
          final imageUrl = dataImage['data']['url'];

          obra.imageURL = imageUrl;
          closeLoadingDialog(context);
        }
        openLoadingDialog(context, mensaje: 'Grabando obra...');
        MyResponse response = await _service.grabarObra(obra, crearDrive);
        if(response.fallo)
          throw new Exception(response.error);
        final obraResponse = Obra.fromMap(response.data);
        widget.txtNombreCtrl.text = '';
        widget.txtBarrioCtrl.text = '';
        widget.txtLoteCtrl.text = '';
        widget.txtDuracionCtrl.text = '';
        widget.txtDescripCtrl.text = '';
        _imageService.descartarImagen();

        closeLoadingDialog(context);

        _service.obra = obraResponse;

        await openAlertDialogReturn(context, 'Obra creada con éxito');
        Navigator.pushReplacementNamed(context, ObraPage.routeName,
            arguments: {"obraId": obraResponse.id});
      } else {
        openAlertDialog(context, 'Formulario invalido');
      }
    } catch (err) {
      closeLoadingDialog(context);

      openAlertDialog(context, 'Error al grabar formulario',
          subMensaje: err.toString());
    }
  }

  actualizarObra(BuildContext context, String obraId, String imageId) async {
    bool isValid = true;
    final _service = Provider.of<ObraService>(context, listen: false);
    final _imageService = Provider.of<ImageService>(context, listen: false);

    widget.txtNombreCtrl.text.trim() == '' ? isValid = false : true;
    widget.txtBarrioCtrl.text.trim() == '' ? isValid = false : true;
    widget.txtLoteCtrl.text.trim() == '' ? isValid = false : true;
    int.tryParse(widget.txtDuracionCtrl.text) == null ? isValid = false : true;

    if (isValid) {
      widget.obra!.nombre = widget.txtNombreCtrl.text;
      widget.obra!.barrio = widget.txtBarrioCtrl.text;
      widget.obra!.lote = widget.  txtLoteCtrl.text;
      widget.obra!.descripcion = widget.txtDescripCtrl.text;
      widget.obra!.diasEstimados = int.parse(widget.txtDuracionCtrl.text);
      widget.obra!.id = obraId;
      widget.obra!.diaInicio = new DateFormat("dd/MM/yyyy")
          .parse(widget.txtDiaInicio.text)
          .millisecondsSinceEpoch;

      if (_imageService.imagenValida()) {
        openLoadingDialog(context, mensaje: 'Subiendo imagen');
        final dataImage = await _imageService.grabarImagen(widget.obra!.nombre);
        if (!dataImage['success']) {
          closeLoadingDialog(context);
          openAlertDialog(context, 'No se pudo cargar imagen');
          return;
        }
        final imageUrl = dataImage['data']['url'];

        widget.obra!.imageURL = imageUrl;
        closeLoadingDialog(context);
      }
      openLoadingDialog(context, mensaje: 'Actualizando obra...');
      Map<String, dynamic> response =
          await _service.actualizarObra(widget.obra!);
      final obraResponse = Obra.fromMap(response["obra"]);
      _imageService.descartarImagen();
      closeLoadingDialog(context);
      await openAlertDialogReturn(context, 'Obra modificada con éxito');
      
    Navigator.pushReplacementNamed(context, ObraPage.routeName,
            arguments: {"obraId": obraResponse.id});    
  
    } else {
      openAlertDialog(context, 'Formulario invalido');
    }
  }
  
  refreshDriveId() async{
    if(widget.txtIdDrive.text.isEmpty)
    {
      openAlertDialog(context, 'Ingrese ID de carpeta para actualizar');
      return;
    }
    openLoadingDialog(context,mensaje: "Actualizando carpetas de obra...");
    final _obraService = Provider.of<ObraService>(context, listen: false);
    final response = await _obraService.actualizarIdDrive(widget.txtIdDrive.text);
    closeLoadingDialog(context);
    if(response.fallo){
      openAlertDialog(context, "Error al actualizar carpetas", subMensaje: response.error);
      return;
    }

      await openAlertDialogReturn (context, "Carpetas actualizadas con éxito");
      widget.obra!.driveFolderId = response.data["driveFolderId"];
      widget.obra!.folderImages = response.data["folderImages"];
      widget.obra!.rootDriveCliente = response.data["rootDriveCliente"];
      widget.obra!.folderImagesCliente = response.data["folderImagesCliente"];
      _obraService.notifyListeners();



  }
  
  openMap() async {
    
    dynamic arguments = null;
    if(edit)  arguments = {'latitud': widget.obra!.latitud, 'longitud': widget.obra!.longitud};
    Marker? coordenadas = await Navigator.pushNamed(context, MapCoordenates.routeName, arguments: arguments) as Marker?;

    if( coordenadas != null ) {
      widget.obra!.latitud = coordenadas.position.latitude;
      widget.obra!.longitud = coordenadas.position.longitude;
      widget.txtCoordenadas.text = widget.obra!.ubicToText();      
    }
    

  }
}
