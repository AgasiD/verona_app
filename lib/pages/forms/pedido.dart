import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/pedido.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/pedidos.dart';
import 'package:verona_app/pages/visor_imagen.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/google_drive_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PedidoForm extends StatelessWidget implements MyForm {
  static String nameForm = 'Nuevo pedido';
  static String alertMessage = 'Confirmar nuevo pedido';
  static const String routeName = 'pedido';

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context, listen: false);
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final pedidoId = arguments['pedidoId'] ?? '';
    bool edit = pedidoId != '';

    return Scaffold(
        body: edit
            ? FutureBuilder(
                future: _obraService.obtenerPedido(pedidoId),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Loading(
                      mensaje: 'Cargando pedido',
                    );
                  } else {
                    MyResponse response = snapshot.data as MyResponse;
                    if (response.fallo) {
                      return Container();
                    }
                    final pedido =
                        Pedido.fromJson(response.data as Map<String, dynamic>);
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
                ),
              ));
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
  TextEditingController areaTxtController = new TextEditingController();
  TextEditingController indicacionesTxtController = new TextEditingController();
  TextEditingController txtCtrlDate = new TextEditingController();
  TextEditingController txtCtrlDateDeseada = new TextEditingController();

  int prioridad = 1;

  DateTime selectedDate = DateTime.now();
  String repartidoId = '1',
      title = 'nuevo pedido',
      usuarioAsignado = '1',
      imgButtonText = 'Foto/Evidencia',
      formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now()),
      nombreUsuario = 'Sin nombre';
  bool enable = true,
      pedidoEnStock = false,
      pedidoConfirmado = false,
      editConfirmado = true,
      imageSelected = false,
      tieneImagen = false;

  List<DropdownMenuItem<int>> prioridades = <DropdownMenuItem<int>>[
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
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context, listen: false);
    final _driveService =
        Provider.of<GoogleDriveService>(context, listen: false);
    txtCtrlDate.text = formattedDate.toString();
    txtCtrlDateDeseada.text = formattedDate.toString();

    if (widget.pedido!.estado == 0) {
      widget.pedido!.fechaDeseada = txtCtrlDateDeseada.text;
    } else if (widget.pedido!.estado >= 0) {
      //Editar pedido (Asignar atributos)
      areaTxtController.text = widget.pedido!.nota;
      title = 'editar pedido';
      prioridad = widget.pedido!.prioridad;
      txtCtrlDate.text = widget.pedido!.fechaEstimada == ''
          ? txtCtrlDate.text
          : widget.pedido!.fechaEstimada;
      txtCtrlDateDeseada.text = widget.pedido!.fechaDeseada == ''
          ? txtCtrlDateDeseada.text
          : widget.pedido!.fechaDeseada;

      repartidores = obtenerRepartidoresAsignados(_obraService.obra.equipo);

      pedidoConfirmado = false;
      if (widget.pedido!.estado == 1) {
        // ESTADO: Pedido sin confirmar
      }
      if (widget.pedido!.estado == 2) {
        // ESTADO: Pedido Pendiente de compra
        pedidoConfirmado = true;
      }
      if (widget.pedido!.estado == 3) {
        // ESTADO: Pedido Asignado
        pedidoEnStock = true;
        pedidoConfirmado = true;
        tieneImagen = widget.pedido!.imagenId == '' ? false : true;
        tieneImagen ? imgButtonText = 'Ver evidencia' : false;
        indicacionesTxtController.text = widget.pedido!.indicaciones;
        repartidoId = widget.pedido!.usuarioAsignado == ''
            ? repartidores.first.value.toString()
            : widget.pedido!.usuarioAsignado;
      }

      if (widget.pedido!.estado == 5) {
        // ESTADO: Pedido cerrado
        tieneImagen = widget.pedido!.imagenId == '' ? false : true;

        imgButtonText = tieneImagen ? 'Ver evidencia' : 'Foto/Evidencia';
        pedidoConfirmado = true;
        pedidoEnStock = true;
        repartidoId = widget.pedido!.usuarioAsignado == ''
            ? repartidores.first.value.toString()
            : widget.pedido!.usuarioAsignado;
        indicacionesTxtController.text = widget.pedido!.indicaciones;
        txtCtrlDate.text = widget.pedido!.fechaEstimada;
        prioridad = widget.pedido!.prioridad;
      }
    }

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
                            enable: editableByEstado(0),
                            hintText: 'Detallar solicitud de materiales',
                            icono: Icons.description_outlined,
                            textController: areaTxtController,
                            lines: 8,
                          ),
                          DropdownButtonFormField2(
                            value: prioridad,
                            items: prioridades,
                            style: TextStyle(
                                color: Helper.brandColors[5], fontSize: 16),
                            iconSize: 30,
                            buttonHeight: 60,
                            buttonPadding: EdgeInsets.only(left: 20, right: 10),
                            decoration: getDecoration(),
                            hint: Text(
                              'Seleccione prioridad',
                              style: TextStyle(fontSize: 16, color: colorHint),
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: colorHint,
                            ),
                            dropdownDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Helper.brandColors[2],
                            ),
                            onChanged: (value) {
                              prioridad = value as int;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          permiteVerByEstado([0, 1, 2, 3]) &&
                                  permiteVerByRole([1, 2, 4, 5, 6])
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
                                      enable: editableByEstado(0),
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
                              permiteVerByEstado([1]) &&
                                      permiteVerByRole([1, 5])
                                  ? TextButton(
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.zero)),
                                      onPressed: abrirChat,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Consultar a ${widget.pedido!.nombreUsuario}'
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: Helper.brandColors[8]),
                                          ),
                                          Icon(Icons.chat,
                                              color: Helper.brandColors[8]),
                                        ],
                                      ))
                                  : Container(),
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
                                        value: widget.pedido!.estado >= 2,
                                        activeColor: Helper.brandColors[3],
                                        activeTrackColor: Helper.brandColors[8],
                                        inactiveTrackColor:
                                            Helper.brandColors[3],
                                        onChanged: permiteVerByRole([1, 5])
                                            ? !permiteVerByEstado([5])
                                                ? (confirmar) {
                                                    setState(() {
                                                      if (!confirmar) {
                                                        widget.pedido!.estado =
                                                            1;
                                                      } else {
                                                        widget.pedido!.estado =
                                                            2;
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
                                                  onChanged:
                                                      !permiteVerByEstado([5])
                                                          ? (enStock) {
                                                              setState(() {
                                                                if (!enStock) {
                                                                  widget.pedido!
                                                                      .estado = 2;
                                                                } else {
                                                                  widget.pedido!
                                                                      .estado = 3;
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
                                            ? DropdownButtonFormField2(
                                                value: repartidoId,
                                                items: repartidores,
                                                style: TextStyle(
                                                    color:
                                                        Helper.brandColors[5],
                                                    fontSize: 16),
                                                iconSize: 30,
                                                buttonHeight: 60,
                                                buttonPadding: EdgeInsets.only(
                                                    left: 20, right: 10),
                                                decoration: getDecoration(),
                                                hint: Text(
                                                  'Seleccione delivery',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: colorHint),
                                                ),
                                                icon: Icon(
                                                  Icons.arrow_drop_down,
                                                  color: colorHint,
                                                ),
                                                dropdownDecoration:
                                                    BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: Helper.brandColors[2],
                                                ),
                                                onChanged: (value) {
                                                  if (value != '1') {
                                                    widget.pedido!
                                                        .tsAsignado = DateTime
                                                            .now()
                                                        .millisecondsSinceEpoch;
                                                    widget.pedido!
                                                            .usuarioAsignado =
                                                        value.toString();
                                                  } else {
                                                    widget.pedido!.tsAsignado =
                                                        0;
                                                    widget.pedido!
                                                        .usuarioAsignado = '';
                                                  }
                                                },
                                                onSaved: (value) {},
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
                          permiteVerByEstado([3, 4, 5]) &&
                                  permiteVerByRole([1, 6])
                              ? Row(
                                  children: [
                                    Text(
                                      'Cerrar pedido',
                                      style: TextStyle(
                                          color: Helper.brandColors[5]),
                                    ),
                                    Switch(
                                        value: widget.pedido!.estado == 4 ||
                                            widget.pedido!.estado == 5,
                                        activeColor: Helper.brandColors[3],
                                        activeTrackColor: Helper.brandColors[8],
                                        inactiveTrackColor:
                                            Helper.brandColors[3],
                                        onChanged: permiteVerByRole([1, 5, 6])
                                            ? !permiteVerByEstado([5])
                                                ? (cerrado) {
                                                    setState(() {
                                                      if (cerrado) {
                                                        widget.pedido!.estado =
                                                            4;
                                                        widget.pedido!
                                                            .tsCerrado = DateTime
                                                                .now()
                                                            .millisecondsSinceEpoch;
                                                      } else {
                                                        widget.pedido!.estado =
                                                            3;
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
                          (permiteVerByRole([1]) && // admin agrega y ve foto
                                      permiteVerByEstado([4, 5])) ||
                                  (permiteVerByRole(
                                          [5]) && //Comprador solo ve foto
                                      permiteVerByEstado([4, 5])) ||
                                  (permiteVerByRole(
                                          [6]) && // devery agrega y ve foto
                                      permiteVerByEstado([4, 5]))
                              ? MaterialButton(
                                  // evidencia
                                  color: Helper.primaryColor,
                                  textColor: Colors.white,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      imageSelected
                                          ? Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Icon(
                                                Icons.check,
                                                color: Helper.brandColors[8],
                                              ))
                                          : Padding(
                                              padding:
                                                  EdgeInsets.only(right: 14),
                                              child: Icon(
                                                Icons.photo_library_outlined,
                                                color: Helper.brandColors[9]
                                                    .withOpacity(.6),
                                              )),
                                      Text(imgButtonText,
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  onPressed: () async {
                                    if (!tieneImagen) {
                                      final ImagePicker _picker = ImagePicker();
                                      final image = await _picker.pickImage(
                                          source: ImageSource.camera);
                                      if (image != null) {
                                        _driveService
                                            .guardarImagenPedido(image!);

                                        setState(() {
                                          imageSelected = true;
                                          tieneImagen = true;
                                          print('imagen cargada!');
                                          print(tieneImagen);
                                        });
                                      }
                                    } else {
                                      Navigator.pushNamed(
                                          context, ImagenViewer.routeName,
                                          arguments: {
                                            'imagenId': widget.pedido!.imagenId
                                          });
                                    }
                                  })
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
                        ? widget.pedido!.estado == 3 ||
                                widget.pedido!.estado == 5
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceAround
                        : MainAxisAlignment.spaceAround,
                    children: [
                      !permiteVerByEstado([5])
                          ? MainButton(
                              width: 120,
                              fontSize: 18,
                              color: Helper.brandColors[8]
                                  .withOpacity(.5)
                                  .withAlpha(150),
                              text: 'Grabar',
                              onPressed: () async {
                                String mensaje1 = 'Creando pedido...';
                                String mensaje2 = 'Error al crear pedido';
                                String mensaje3 = 'Pedido creado con exito';
                                if (widget.pedido != null) {
                                  mensaje1 = 'Actualizando pedido...';
                                  mensaje2 = 'Error al actualizar el pedido';
                                  mensaje3 = 'Pedido actualizado con exito';
                                }

                                openLoadingDialog(context, mensaje: mensaje1);
                                final response = await grabarPedido(
                                    _obraService.obra.id,
                                    areaTxtController,
                                    _obraService,
                                    _driveService);

                                closeLoadingDialog(context);

                                if (response[0]) {
                                  openAlertDialog(context, mensaje2,
                                      subMensaje: response[1]);
                                } else {
                                  openLoadingDialog(context, mensaje: mensaje3);
                                  Timer(Duration(milliseconds: 750), () {
                                    closeLoadingDialog(context);
                                    Timer(Duration(milliseconds: 750), () {
                                      Navigator.pop(
                                        context,
                                        PedidosPage.routeName,
                                      );
                                    });
                                  });
                                }
                              },
                            )
                          : Container(),
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
              ]),
            ),
          ),
        ));
  }

  grabarPedido(obraId, areaTxtController, ObraService _obraService,
      GoogleDriveService _driveService) async {
    MyResponse response;

    switch (widget.pedido!.estado) {
      case 0: // PEDIDO NUEVO
        final ped = new Pedido(
          idObra: obraId,
          idUsuario: _pref.id,
          nota: areaTxtController.text,
          prioridad: prioridad,
          fechaDeseada: widget.pedido!.fechaDeseada,
          /*
          notificar a  
        */
        );

        response = await _obraService.nuevoPedido(ped);
        if (response.fallo) {
          return [true, response.error];
        } else {
          return [false, response.data];
        }
        break;
      case 1: // PEDIDO SIN CONFIRMAR
        response = await _obraService.editPedido(widget.pedido!);
        if (response.fallo) {
          return [true, response.error];
        } else {
          return [false, response.data];
        }
        break;
      case 2: // PEDIDO CONFIRMADO. PENDIENTE DE COMPRA

        response = await _obraService.editPedido(widget.pedido!);
        if (response.fallo) {
          return [true, response.error];
        } else {
          return [false, response.data];
        }
        break;
      case 3:
        if (widget.pedido!.usuarioAsignado == '') {
          return [true, 'No se ha seleccionado repartidor'];
        }
        widget.pedido!.indicaciones = indicacionesTxtController.text;
        widget.pedido!.nota = areaTxtController.text;
        widget.pedido!.prioridad = prioridad;
        widget.pedido!.fechaEstimada = txtCtrlDate.text;

        response = await _obraService.editPedido(widget.pedido!);
        if (response.fallo) {
          return [true, response.error];
        } else {
          return [false, response.data];
        }
        break;

      case 4:
        widget.pedido!.nota = areaTxtController.text;
        widget.pedido!.prioridad = prioridad;
        print('tiene Imagen:' + tieneImagen.toString());
        if (!tieneImagen) {
          // openAlertDialog(context, 'No se ha cargado imagen/evidencia');
          return [true, 'No se ha cargado imagen/evidencia'];
        } else {
          final idImagen = await _driveService.grabarImagenPedido(
              'Pedido-${new DateFormat('dd/MM/yy').parse(widget.pedido!.fechaEstimada)}-${_obraService.obra.nombre}',
              _obraService.obra.driveFolderId!);
          widget.pedido!.imagenId = idImagen;
        }
        response = await _obraService.editPedido(widget.pedido!);
        if (response.fallo) {
          return [true, response.error];
        } else {
          return [false, response.data];
        }
        break;

      default:
        break;
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

  void selectDate(context, txtCtrlDate, selectedDate) {
    DatePicker.showDatePicker(context,
        showTitleActions: true, minTime: DateTime(2022, 1, 1),
        // maxTime: DateTime(2025, 12, 31),
        onConfirm: (date) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(date);

      txtCtrlDate.text = formattedDate.toString();
      widget.pedido!.fechaEstimada = formattedDate.toString();
      selectedDate = date;
    }, onChanged: (date) {}, currentTime: selectedDate, locale: LocaleType.es);
  }

  void selectDateDeseada(context, txtCtrlDate, selectedDate) {
    DatePicker.showDatePicker(context,
        showTitleActions: true, minTime: DateTime(2022, 1, 1),
        // maxTime: DateTime(2025, 12, 31),
        onConfirm: (date) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(date);

      txtCtrlDate.text = formattedDate.toString();
      widget.pedido!.fechaDeseada = formattedDate.toString();
      selectedDate = date;
    }, onChanged: (date) {}, currentTime: selectedDate, locale: LocaleType.es);
  }

  bool permiteVerByRole(List<int> lista) {
    final rol = new Preferences().role;
    return lista.contains(rol);
  }

  bool permiteVerByEstado(List<int> lista) {
    if (widget.pedido != null) {
      return lista.contains(widget.pedido!.estado);
    } else {
      return lista.contains(0);
    }
  }

  bool editableByEstado(int estadoVisible) {
    if (widget.pedido != null) {
      return widget.pedido!.estado == estadoVisible;
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
    if (repartidores.length == 1) {
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
    final response =
        await _chatService.crearChat(_pref.id, widget.pedido!.idUsuario);
    if (response.fallo) {
      openAlertDialog(context, 'Error al crear el chat',
          subMensaje: response.error);
    } else {
      Navigator.pushNamed(context, ChatPage.routeName, arguments: {
        'chatId': response.data['chatId'],
        'chatName': response.data['chatName'],
      });
    }
  }
}
