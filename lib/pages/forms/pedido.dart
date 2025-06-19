import 'dart:async';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/pedido.dart';
import 'package:verona_app/navigator_key.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/error.dart';
import 'package:verona_app/pages/listas/pedidos.dart';
import 'package:verona_app/pages/visor_imagen.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/pdf_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';
import 'package:open_file/open_file.dart';

class PedidoForm extends StatelessWidget implements MyForm {
  static String nameForm = 'Nuevo pedido';
  static String alertMessage = 'Confirmar nuevo pedido';
  static const String routeName = 'pedido';

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context, listen: false);
    final _socketService = Provider.of<SocketService>(context, listen: false);
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final pedidoId = arguments['pedidoId'] ?? '';
    final obraId = arguments['obraId'] ?? _obraService.obra.id;
    bool edit = pedidoId != '';
    quitarNovedad(pedidoId, _socketService, obraId);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: edit
              ? FutureBuilder(
                  future: _obraService.obtenerPedido(pedidoId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Loading(
                        mensaje: 'Cargando pedido...',
                      );
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.hasError) {
                      return ErrorPage(errorMsg: snapshot.error.toString());
                    } else {
                      final pedido = Pedido.fromJson(
                          snapshot.data as Map<String, dynamic>);
                      return _Form(pedido: pedido);
                    }
                  },
                )
              : _Form(
                  pedido: new Pedido(
                    idUsuario: '',
                    idObra: '',
                    nota: '',
                    prioridad: 1,
                    estado: 0,
                    titulo: '',
                  ),
                )),
    );
  }

  void quitarNovedad(
      String pedidoId, SocketService _socketService, String obraId) {
    final dato = (_socketService.novedades ?? []).where((novedad) =>
        novedad['tipo'] == 1 &&
        novedad['obraId'] == obraId &&
        novedad['pedidoId'] == pedidoId);

    if (dato.length == 0) return;
    final _pref = Preferences();
    _socketService.quitarNovedad(_pref.id, dato.map((e) => e['id']).toList());
  }
}

class _Form extends StatefulWidget {
  _Form({Key? key, this.pedido = null}) : super(key: key);
  Pedido? pedido;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late List<DropdownMenuItem<String>> repartidores;
  Color colorHint = Helper.brandColors[3];
  Preferences _pref = new Preferences();
  TextEditingController titleTxtController = new TextEditingController();
  TextEditingController areaTxtController = new TextEditingController();
  TextEditingController indicacionesTxtController = new TextEditingController();
  TextEditingController txtCtrlDate = new TextEditingController();
  TextEditingController txtCtrlDateDeseada = new TextEditingController();

  int prioridad = 1;
  int estadoPedido = 0;
  int tsAsignado = 0;

  DateTime selectedDate = DateTime.now();
  String repartidoId = '0',
      formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now()),
      fechaEntrega = DateFormat('dd/MM/yyyy').format(DateTime.now()),
      fechaDeseada = DateFormat('dd/MM/yyyy').format(DateTime.now()),
      title = 'nuevo pedido',
      usuarioAsignado = '0',
      imgButtonText = 'Foto/Evidencia',
      nombreUsuario = 'Sin nombre',
      detallePedido = '',
      indicacionesPedido = '';

  late String tituloPedido;
  late String repartidorAsignado;

  bool enable = true,
      pedidoEnStock = false,
      pedidoConfirmado = false,
      editConfirmado = true,
      imageSelected = false,
      tieneImagen = false,
      entregaExterna = false;

  List<DropdownMenuItem<int>> PRIORIDADES = <DropdownMenuItem<int>>[
    DropdownMenuItem(
      value: 1,
      child: Text('Prioridad baja'.toUpperCase()),
    ),
    DropdownMenuItem(
      value: 2,
      child: Text('Prioridad media'.toUpperCase()),
    ),
    DropdownMenuItem(
      value: 3,
      child: Text('Prioridad alta'.toUpperCase()),
    )
  ];

  @override
  void initState() {
    super.initState();
    cargarObra();
    final _obraService = Provider.of<ObraService>(context, listen: false);
    estadoPedido = widget.pedido!.estado;
    if (estadoPedido == 0) {
      tituloPedido = _obraService.obra.lote + ' - ';
    } else if (estadoPedido >= 0) {
      //Editar pedido (Asignar atributos)
      tituloPedido = widget.pedido!.titulo;
      detallePedido = widget.pedido!.nota;
      title = 'editar pedido';
      prioridad = widget.pedido!.prioridad;
      fechaEntrega = widget.pedido!.fechaEstimada == ''
          ? formattedDate
          : widget.pedido!.fechaEstimada;
      fechaDeseada = widget.pedido!.fechaDeseada == ''
          ? formattedDate
          : widget.pedido!.fechaDeseada;

      repartidores = obtenerRepartidoresAsignados(_obraService.obra.equipo);
      repartidoId = repartidores[0].value.toString();

      pedidoConfirmado = false;
      switch (estadoPedido) {
        case 1:
          // ESTADO: Pedido sin confirmar
          break;
        case 2:
          // ESTADO: Pedido Pendiente de compra
          pedidoConfirmado = true;
          break;
        case 3:
          // ESTADO: Pedido Asignado
          pedidoEnStock = true;
          pedidoConfirmado = true;
          tieneImagen = widget.pedido!.imagenId.isEmpty ? false : true;
          tieneImagen ? imgButtonText = 'Ver evidencia' : false;
          indicacionesPedido = widget.pedido!.indicaciones;
          repartidoId = widget.pedido!.usuarioAsignado == ''
              ? repartidores.first.value.toString()
              : widget.pedido!.usuarioAsignado;
          entregaExterna = widget.pedido!.entregaExterna;
          break;
        case 5:
          // ESTADO: Pedido cerrado
          pedidoEnStock = true;
          pedidoConfirmado = true;
          tieneImagen = widget.pedido!.imagenId.isEmpty ? false : true;
          imgButtonText = tieneImagen ? 'Ver evidencia' : 'Foto/Evidencia';
          repartidoId = widget.pedido!.usuarioAsignado == ''
              ? repartidores.first.value.toString()
              : widget.pedido!.usuarioAsignado;
          indicacionesPedido = widget.pedido!.indicaciones;
          fechaEntrega = widget.pedido!.fechaEstimada;
          prioridad = widget.pedido!.prioridad;
          entregaExterna = widget.pedido!.entregaExterna;
          break;
      }

      if (entregaExterna) {
        repartidoId = '9999';
        repartidorAsignado = 'Entrega Externa';
      }
    }
    areaTxtController.text = detallePedido;
    txtCtrlDate.text = fechaEntrega;
    txtCtrlDateDeseada.text = fechaDeseada;
    titleTxtController.text = tituloPedido;
    indicacionesTxtController.text = indicacionesPedido;
  }

  inicializaDatos() {}

  Future cargarObra() async {
    final _obraService = Provider.of<ObraService>(context, listen: false);
    if (_obraService.obra.id == '') {
      final obra = await _obraService.obtenerObra(widget.pedido!.idObra);
      _obraService.obra = obra;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context, listen: false);
    final _driveService =
        Provider.of<GoogleDriveService>(context, listen: false);

    return Container(
        color: Helper.brandColors[1],
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
          padding: EdgeInsets.all(20),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              child: Column(children: [
                Column(
                  children: [
                    Logo(
                      size: 70,
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                          foreground: Paint()
                            ..shader = Helper.getGradient(
                                [Helper.brandColors[8], Helper.brandColors[9]]),
                          fontSize: 23),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Form(
                      child: Column(
                        children: [
                          CustomInput(
                            readOnly: !habilitaEdicion(),
                            hintText: 'Título del pedido',
                            icono: Icons.title,
                            textController: titleTxtController,
                            lines: 1,
                          ),
                          CustomInput(
                            readOnly: !habilitaEdicion(),
                            hintText: 'Detallar solicitud de materiales',
                            icono: Icons.description_outlined,
                            teclado: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            textController: areaTxtController,
                            lines: 8,
                          ),
                          estadoPedido != 0
                              ? TextButton(
                                  onPressed: () async =>
                                      await descargarPDF(context),
                                  child: Text('Exportar PDF detalle'))
                              : Container(),
                          Theme(
                              data: Theme.of(context).copyWith(
                                  disabledColor: Helper.brandColors[3]),
                              child: DropdownButtonFormField2(
                                value: prioridad,
                                items: PRIORIDADES,
                                style: TextStyle(
                                    color: Helper.brandColors[5], fontSize: 16),
                                decoration: getDecoration(),
                                dropdownStyleData: DropdownStyleData(
                                    decoration: getDropdownDecoration()),
                                onChanged: (habilitaEdicion())
                                    ? (value) {
                                        prioridad = value as int;
                                      }
                                    : null,
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          permiteVerByEstado([0, 1, 2, 3]) &&
                                  !permiteVerByRole([3])
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'F. Deseada'.toUpperCase(),
                                      style: TextStyle(
                                          color: Helper.brandColors[5]),
                                    ),
                                    CustomInput(
                                      readOnly: true,
                                      enable: habilitaEdicion(),
                                      width: 200,
                                      hintText: ('Fecha').toUpperCase(),
                                      icono: null,
                                      textController: txtCtrlDateDeseada,
                                      iconButton: IconButton(
                                          icon: Icon(
                                            Icons.calendar_today,
                                            color: Helper.brandColors[3],
                                          ),
                                          onPressed: () {
                                            selectDateDeseada(
                                              context,
                                              txtCtrlDateDeseada,
                                              selectedDate,
                                            );
                                            widget.pedido!.fechaDeseada =
                                                txtCtrlDateDeseada.text;
                                          }),
                                    ),
                                  ],
                                )
                              : Container(),
                          Column(
                            children: [
                              permiteVerByEstado([1, 2, 3, 5]) &&
                                      permiteVerByRole([1, 2, 5])
                                  ? Row(children: [
                                      Text(
                                        pedidoConfirmado
                                            ? 'Confirmado'.toUpperCase()
                                            : 'Confirmar'.toUpperCase(),
                                        style: TextStyle(
                                            color: Helper.brandColors[5]),
                                      ),
                                      Switch(
                                        value: estadoPedido >= 2,
                                        activeColor: Helper.brandColors[3],
                                        activeTrackColor: Helper.brandColors[8],
                                        inactiveTrackColor:
                                            Helper.brandColors[3],
                                        onChanged: permiteVerByRole([1, 5])
                                            ? !permiteVerByEstado([5])
                                                ? (confirmar) {
                                                    setState(() {
                                                      if (!confirmar) {
                                                        estadoPedido = 1;
                                                      } else {
                                                        estadoPedido = 2;
                                                      }
                                                      pedidoConfirmado =
                                                          confirmar;

                                                      !pedidoConfirmado
                                                          ? pedidoEnStock =
                                                              false
                                                          : false;
                                                    });
                                                  }
                                                : null
                                            : null,
                                      ),
                                      pedidoConfirmado
                                          ? Row(
                                              children: [
                                                Text(
                                                  'En stock'.toUpperCase(),
                                                  style: TextStyle(
                                                      color: Helper
                                                          .brandColors[5]),
                                                ),
                                                Switch(
                                                  value: pedidoEnStock,
                                                  activeColor:
                                                      Helper.brandColors[3],
                                                  activeTrackColor:
                                                      Helper.brandColors[8],
                                                  inactiveTrackColor:
                                                      Helper.brandColors[3],
                                                  onChanged: !permiteVerByEstado(
                                                              [5]) &&
                                                          (
                                                              // Habilitado para admin (1)
                                                              permiteVerByEstado(
                                                                      [2, 3]) &&
                                                                  permiteVerByRole(
                                                                      [5, 1]))
                                                      ? (enStock) {
                                                          setState(() {
                                                            if (!enStock) {
                                                              estadoPedido = 2;
                                                            } else {
                                                              estadoPedido = 3;
                                                            }
                                                            pedidoEnStock =
                                                                enStock;
                                                          });
                                                        }
                                                      : null,
                                                )
                                              ],
                                            )
                                          : Container()
                                    ])
                                  : Container(),
                              pedidoEnStock
                                  ? Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'F. Entrega'.toUpperCase(),
                                                style: TextStyle(
                                                    color:
                                                        Helper.brandColors[5]),
                                              ),
                                              CustomInput(
                                                readOnly: true,
                                                enable:
                                                    permiteVerByRole([1, 5]) &&
                                                        permiteVerByEstado(
                                                            [1, 3, 2]),
                                                width: 200,
                                                hintText:
                                                    ('Fecha').toUpperCase(),
                                                icono: null,
                                                textController: txtCtrlDate,
                                                iconButton: IconButton(
                                                    icon: Icon(
                                                      Icons.calendar_today,
                                                      color:
                                                          Helper.brandColors[3],
                                                    ),
                                                    onPressed: () {
                                                      selectDate(
                                                        context,
                                                        txtCtrlDate,
                                                        selectedDate,
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                        ),
                                        permiteVerByRole([1, 5]) &&
                                                permiteVerByEstado([1, 3, 2])
                                            ? _Custom_Dropdown(
                                                actionOnChange: ((a) =>
                                                    asignaEntrega(a)),
                                                valores: repartidores,
                                                valorId: repartidoId,
                                              )
                                            : Container(),
                                        SizedBox(
                                          height: 25,
                                        ),
                                        CustomInput(
                                          enable: permiteVerByRole([1, 5]) &&
                                              permiteVerByEstado([3]),
                                          hintText: 'Detallar indicaciones ',
                                          icono: Icons.checklist_sharp,
                                          textController:
                                              indicacionesTxtController,
                                          lines: 8,
                                        ),
                                      ],
                                    )
                                  : Container()
                            ],
                          ),
                          permiteVerByEstado([2, 3, 4, 5]) &&
                                  permiteVerByRole([1, 6, 5])
                              ? Row(
                                  children: [
                                    Text(
                                      'Cerrar pedido',
                                      style: TextStyle(
                                          color: Helper.brandColors[5]),
                                    ),
                                    Switch(
                                        value: estadoPedido == 4 ||
                                            estadoPedido == 5,
                                        activeColor: Helper.brandColors[3],
                                        activeTrackColor: Helper.brandColors[8],
                                        inactiveTrackColor:
                                            Helper.brandColors[3],
                                        onChanged: permiteVerByRole([1, 5, 6])
                                            ? !permiteVerByEstado([5])
                                                ? (cerrado) {
                                                    setState(() {
                                                      if (cerrado) {
                                                        estadoPedido = 4;
                                                        widget.pedido!
                                                            .tsCerrado = DateTime
                                                                .now()
                                                            .millisecondsSinceEpoch;
                                                      } else {
                                                        estadoPedido = 3;
                                                        widget.pedido!
                                                            .tsCerrado = 0;
                                                      }
                                                    });
                                                  }
                                                : null
                                            : null)
                                  ],
                                )
                              : Container(),
                          !(permiteVerByEstado([5, 6]) && !tieneImagen)
                              ? (permiteVerByRole(
                                              [1]) && // admin agrega y ve foto
                                          permiteVerByEstado([4, 5])) ||
                                      (permiteVerByRole(
                                              [5]) && //Comprador solo ve foto
                                          permiteVerByEstado([4, 5])) ||
                                      (permiteVerByRole([
                                            6
                                          ]) && // delivery agrega y ve foto
                                          permiteVerByEstado([4, 5])) ||
                                      permiteVerByEstado([5, 6]) && tieneImagen
                                  ? MaterialButton(
                                      color: Helper.primaryColor,
                                      textColor: Colors.white,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          tieneImagen
                                              ? Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 10),
                                                  child: Icon(
                                                    Icons.check,
                                                    color:
                                                        Helper.brandColors[8],
                                                  ))
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 14),
                                                  child: Icon(
                                                    Icons
                                                        .photo_library_outlined,
                                                    color: Helper.brandColors[9]
                                                        .withOpacity(.6),
                                                  )),
                                          Text(imgButtonText,
                                              style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                      onPressed: () =>
                                          guardarImagen(entregaExterna))
                                  : Container()
                              : Container()
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 45),
                  child: Row(
                    mainAxisAlignment: widget.pedido != null
                        ? estadoPedido == 3 || estadoPedido == 5
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceAround
                        : MainAxisAlignment.spaceAround,
                    children: [
                      permiteVerByEstado([0, 1]) && permiteVerByRole([4]) ||
                              !permiteVerByEstado([5]) && !permiteVerByRole([4])
                          ? MainButton(
                              width: 95,
                              fontSize: 18,
                              color: Helper.brandColors[8]
                                  .withOpacity(.5)
                                  .withAlpha(150),
                              text: 'Grabar',
                              onPressed: () async =>
                                  grabar(_obraService, _driveService))
                          : Container(),
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
              ]),
            ),
          ),
        ));
  }

  Future<void> grabar(_obraService, _driveService) async {
    {
      try {
        openLoadingDialogG(mensaje: 'Procesando pedido...');
        final response = await grabarPedido(_obraService.obra.id,
            areaTxtController, _obraService, _driveService);
        closeLoadingDialogG();
        if (response[0]) throw new Exception(response[1]);

        await openAlertDialogReturnG('Pedido guardado con éxito');
        Navigator.pop(
          context,
          PedidosPage.routeName,
        );
      } catch (err) {
        closeLoadingDialogG();
        openAlertDialogG('Error al grabar pedido',
            subMensaje: err.toString());
      }
    }
  }

  void asignaEntrega(String value) {
    if (value != '0') {
      entregaExterna = false;
      tsAsignado = DateTime.now().millisecondsSinceEpoch;

      if (value == '9999') {
        entregaExterna = true;
        repartidorAsignado = 'Entrega Externa';
      } else {
        entregaExterna = false;
      }
    } else {
      tsAsignado = 0;
      repartidorAsignado = '';
      entregaExterna = false;
    }
    repartidoId = value.toString();
  }

  guardarImagen(bool entregaExterna) async {
    final _driveService =
        Provider.of<GoogleDriveService>(context, listen: false);
    final _pref = new Preferences();

    bool ambosMetodos = _pref.role == 1 || _pref.role == 5 || entregaExterna;

    try {
      if (!tieneImagen) {
        if (ambosMetodos) {
          var acciones = [
            {
              "text": 'Seleccionar de galería',
              "default": true,
              "accion": await imagenFromGallery
            },
            {
              "text": 'Abrir camara',
              "default": false,
              "accion": await imagenFromCamera
            },
          ];
          openBottomSheet(
              context, 'Subir documento', 'Seleccionar método', acciones);
        } else {
          await imagenFromCamera();
        }
      } else {
        Navigator.pushNamed(context, ImagenViewer.routeName,
            arguments: {'imagenId': widget.pedido!.imagenId[0]});
      }
    } catch (e) {
      openAlertDialog(context, e.toString());
    }
  }

  grabarPedido(obraId, areaTxtController, ObraService _obraService,
      GoogleDriveService _driveService) async {
    dynamic response;
    bool loading = false;
    detallePedido = areaTxtController.text;
    tituloPedido = titleTxtController.text;

    if (estadoPedido > 0) {
      widget.pedido!.titulo = tituloPedido;
      widget.pedido!.nota = detallePedido;
      widget.pedido!.prioridad = prioridad;
      widget.pedido!.fechaDeseada = txtCtrlDateDeseada.text;
      widget.pedido!.fechaEstimada = txtCtrlDate.text;
      widget.pedido!.usuarioAsignado = repartidoId;
      widget.pedido!.indicaciones = indicacionesTxtController.text;
      widget.pedido!.estado = estadoPedido;
      widget.pedido!.entregaExterna = entregaExterna;
    }
    loading = true;
    try {
      switch (estadoPedido) {
        case 0: // PEDIDO NUEVO
          return nuevoPedido(_obraService, obraId);
        case 1: // PEDIDO SIN CONFIRMAR
          response = await _obraService.editPedido(widget.pedido!);
          return [false, response];
        case 2: // PEDIDO CONFIRMADO. PENDIENTE DE COMPRA

          response = await _obraService.editPedido(widget.pedido!);
          return [false, response];

        case 3:
          if (repartidoId == '0')
            return [true, 'No se ha seleccionado repartidor'];

          if (widget.pedido!.usuarioAsignado == '9999')
            widget.pedido!.entregaExterna = true;

          response = await _obraService.editPedido(widget.pedido!);

          return [false, response];

        case 4:
          return cerrarPedido(_obraService, _driveService);
        default:
          break;
      }
    } catch (err) {
      return [true, err.toString()];
    }
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

  getDropdownDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Helper.brandColors[2],
    );
  }

  void selectDate(context, txtCtrlDate, selectedDate) async {
    double width = MediaQuery.of(context).size.width * .8;
    double height = MediaQuery.of(context).size.height * .5;

    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        selectedDayHighlightColor: Helper.brandColors[8],
        calendarType: CalendarDatePicker2Type.single,
        closeDialogOnCancelTapped: true,
      ),
      dialogSize: Size(width, height),
      value: [selectedDate],
      borderRadius: BorderRadius.circular(5),
    );

    if (results != null) {
      final date = results![0];
      String formattedDate = DateFormat('dd/MM/yyyy').format(date!);

      txtCtrlDate.text = formattedDate.toString();
      widget.pedido!.fechaEstimada = formattedDate.toString();
      selectedDate = date;
    }
  }

  void selectDateDeseada(context, txtCtrlDate, selectedDate) async {
    double width = MediaQuery.of(context).size.width * .8;

    double height = MediaQuery.of(context).size.height * .5;
    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        selectedDayHighlightColor: Helper.brandColors[8],
        calendarType: CalendarDatePicker2Type.single,
        closeDialogOnCancelTapped: true,
      ),
      dialogSize: Size(width, height),
      value: [selectedDate],
      borderRadius: BorderRadius.circular(5),
    );

    if (results != null) {
      final date = results![0];
      String formattedDate = DateFormat('dd/MM/yyyy').format(date!);

      txtCtrlDate.text = formattedDate.toString();
      widget.pedido!.fechaDeseada = formattedDate.toString();
      selectedDate = date;
    }
  }

  bool permiteVerByRole(List<int> lista) {
    final rol = new Preferences().role;
    return lista.contains(rol);
  }

  bool esCreador() {
    final idUsuario = new Preferences().id;
    return widget.pedido!.idUsuario == idUsuario;
  }

  bool permiteVerByEstado(List<int> lista) {
    if (widget.pedido != null) {
      return lista.contains(estadoPedido);
    } else {
      return lista.contains(0);
    }
  }

  bool editableByEstado(int estadoVisible) {
    if (widget.pedido != null) {
      return estadoPedido == estadoVisible;
    } else {
      return true;
    }
  }

  List<DropdownMenuItem<String>> obtenerRepartidoresAsignados(
      List<Miembro> equipo) {
    final rep = equipo.where((element) => element.role == 6).toList();
    repartidores = [];
    repartidores = rep
        .map((e) => DropdownMenuItem(
              value: e.id,
              child: Text('${e.nombre} ${e.apellido}'.toUpperCase()),
            ))
        .toList();
    repartidores.insert(
        0,
        DropdownMenuItem(
          value: '0',
          child: Text('Seleccione repartidor'.toUpperCase()),
        ));
    repartidores.add(DropdownMenuItem(
      value: '9999',
      child: Text('Entrega externa'.toUpperCase()),
    ));
    if (repartidores.length == 2) {
      repartidores.add(DropdownMenuItem(
        value: '1',
        child: Text('Sin repartidores asignados'.toUpperCase()),
      ));
    }
    return repartidores;
  }

  abrirChat() async {
    final _chatService = Provider.of<ChatService>(context, listen: false);
    // Generar Chat
    try {
      final response =
          await _chatService.crearChat(_pref.id, widget.pedido!.idUsuario);

      Navigator.pushNamed(context, ChatPage.routeName, arguments: {
        'chatId': response.data['chatId'],
        'chatName': response.data['chatName'],
      });
    } catch (err) {
      openAlertDialog(context, 'Error al crear el chat',
          subMensaje: err.toString());
    }
  }

  habilitaEdicion() {
    return editableByEstado(0) || // Habiltado para todos al crear
        permiteVerByRole([1]) || // Habilitado para admin (1)
        permiteVerByEstado([1]) &&
            esCreador() || // Habilitado para creador antes de confirmar por compras (5)
        permiteVerByEstado([1, 2]) &&
            permiteVerByRole(
                [5]); // habilitado para compras(5) antes de asignar
  }

  imagenFromGallery() async {
    final _driveService =
        Provider.of<GoogleDriveService>(context, listen: false);
    final ImagePicker _picker = ImagePicker();
    final List<XFile?>? images = await _picker.pickMultiImage();
    if (images != null && images.length > 0) {
      tieneImagen = true;
      _driveService.guardarImagenPedido(images);
      Navigator.pop(context);
      setState(() {
        // imagenSelected = true;
        imgButtonText = 'Imagenes seleccionadas (${images.length})';
      });
    }
  }

  imagenFromCamera() async {
    final _driveService =
        Provider.of<GoogleDriveService>(context, listen: false);
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      tieneImagen = true;
      _driveService.guardarImagenPedido([image]);
      Navigator.pop(context);
      setState(() {
        // imagenSelected = true;
        imgButtonText = 'Imagen selecciona';
      });
    }
  }

  descargarPDF(BuildContext context) async {
    openLoadingDialog(context, mensaje: 'Descargando archivo...');
    try {
      final genero = await PDFService.generarPDFPedido(widget.pedido!);
      if (!genero[0]) {
        throw Exception(genero[1]);
      }
      closeLoadingDialog(context);
      var downloadsDirectory = await getTemporaryDirectory();

      Helper.showSnackBar(
          context,
          'Archivo descargado',
          null,
          Duration(seconds: 4),
          SnackBarAction(
            label: 'Ver PDF',
            onPressed: () {
              OpenFile.open(genero[1]);
            },
          ));
    } catch (err) {
      closeLoadingDialog(context);
      openAlertDialog(context, 'No se pudo descargar archivo',
          subMensaje: err.toString());
    }
  }

  nuevoPedido(ObraService _obraService, obraId) async {
    final ped = new Pedido(
        idObra: obraId,
        idUsuario: _pref.id,
        nota: detallePedido,
        prioridad: prioridad,
        fechaDeseada: fechaDeseada,
        titulo: tituloPedido,
        estado: 1);

    try {
      final response = await _obraService.nuevoPedido(ped);
      return [false, response];
    } catch (err) {
      return [true, err.toString()];
    }
  }

  cerrarPedido(_obraService, GoogleDriveService _driveService) async {
    bool loading = false;
    if (tieneImagen) {
      final idDrive = _obraService.obra.folderPedidoImages == ''
          ? _obraService.obra.driveFolderId
          : _obraService.obra.folderPedidoImages;
      loading = true;
      final pedido_aux = widget.pedido!;
      if (_driveService.imgsPedido!.length > 0) {
        final idsImagenes =
            await subirImagenesPedido(_driveService, _obraService, idDrive);
        loading = false;
        widget.pedido = pedido_aux;
        widget.pedido!.imagenId = idsImagenes;
      }
    }

    try {
      final response = await _obraService.editPedido(widget.pedido!);
      return [false, response];
    } catch (err) {
      return [true, err.toString()];
    }
  }

  Future<List<String>> subirImagenesPedido(
      GoogleDriveService _driveService, _obraService, idDrive) async {
    int index = 1;
    List<String> idsImagenes = [];
    for (var img in _driveService.imgsPedido!) {
      final tituloImg =
          'Pedido-${widget.pedido!.titulo}-${_obraService.obra.nombre}($index)';
      openLoadingDialog(context,
          mensaje:
              'Subiendo ${_driveService.imgsPedido!.length} imagenes... ($index)');
      final idImagen =
          await _driveService.grabarImagenPedido(tituloImg, idDrive!, img!);
      idsImagenes.add(idImagen);
      index++;
      closeLoadingDialog(context);
    }
    return idsImagenes;
  }
}

class _Custom_Dropdown extends StatelessWidget {
  _Custom_Dropdown(
      {Key? key,
      required this.valores,
      this.valorId = '',
      required this.actionOnChange})
      : super(key: key);
  List<DropdownMenuItem<String>> valores;
  String valorId;
  List<DropdownMenuItem<int>> lista_valores = [];
  Color colorHint = Helper.brandColors[3];
  void Function(String) actionOnChange;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2(
      value: valorId,
      items: valores,
      style: TextStyle(color: Helper.brandColors[5], fontSize: 16),
      decoration: getDecoration(),
      dropdownStyleData: DropdownStyleData(decoration: getDropdownDecoration()),
      hint: Text(
        'Seleccione delivery',
        style: TextStyle(fontSize: 16, color: colorHint),
      ),
      onChanged: (value) {
        actionOnChange(value.toString());
      },
      onSaved: (value) {},
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

  getDropdownDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Helper.brandColors[2],
    );
  }
}
