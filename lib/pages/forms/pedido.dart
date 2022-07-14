import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/models/pedido.dart';
import 'package:verona_app/pages/pedidos.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PedidoForm extends StatelessWidget implements MyForm {
  static String nameForm = 'Nuevo pedido';
  static String alertMessage = 'Confirmar nuevo pedido';
  static const String routeName = 'pedido';

  static Function() accion = () {
    // TODO:
  };
  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final pedidoId = arguments['pedidoId'] ?? '';
    bool edit = false;
    if (pedidoId != '') {
      edit = true;
    }
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
            : _Form());
  }
}

class _Form extends StatefulWidget {
  _Form({Key? key, this.pedido = null}) : super(key: key);
  Pedido? pedido;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  Color colorHint = Helper.brandColors[3];

  Preferences _pref = new Preferences();

  int prioridad = 1;
  String repartidoId = '';
  String title = 'nuevo pedido';
  String usuarioAsignado = '1';

  bool enable = true;

  bool pedidoCerrado = false, pedidoAsignado = false;

  TextEditingController areaTxtController = new TextEditingController();
  late List<DropdownMenuItem<String>> repartidores;
  List<DropdownMenuItem<int>> items = <DropdownMenuItem<int>>[
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

  late bool vistaComprado, vistaDelivery, vistaAdmin, vistaGeneral;

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);

    // SI ES UN PEDIDO EXISTENTE
    if (widget.pedido != null) {
      areaTxtController.text = widget.pedido!.nota;
      title = 'editar pedido';
      prioridad = widget.pedido!.prioridad;
      widget.pedido!.asignado ? enable = false : true;
      widget.pedido!.cerrado ? enable = false : true;
      final rep = _obraService.obra.equipo
          .where((element) => element.role == 6)
          .toList();

      repartidores = rep
          .map((e) => DropdownMenuItem(
                value: e.id,
                child: Text('${e.nombre} ${e.apellido}'.toUpperCase()),
              ))
          .toList();
      repartidores.insert(
          0,
          DropdownMenuItem(
            value: '1',
            child: Text('Seleccione repartidor'.toUpperCase()),
          ));
      if (repartidores.length == 1) {
        repartidores.add(DropdownMenuItem(
          value: '1',
          child: Text('Sin repartidores asignados'.toUpperCase()),
        ));
      }

      repartidoId = '1';

      if (widget.pedido!.asignado) {
        pedidoAsignado = true;
        repartidoId = widget.pedido!.usuarioAsignado;
        usuarioAsignado = widget.pedido!.usuarioAsignado;
      }
    }
    // vista admin
    if (widget.pedido != null && _pref.role == 1 && !widget.pedido!.cerrado) {
      vistaAdmin = true;
      vistaComprado = false;
      vistaDelivery = false;
    } else if (widget.pedido != null &&
        _pref.role == 5 &&
        !widget.pedido!.cerrado) {
      //vista comprado
      vistaAdmin = false;
      vistaComprado = true;
      vistaDelivery = false;
    } else if (widget.pedido != null &&
        _pref.role == 6 &&
        !widget.pedido!.cerrado) {
      // vista repartidor
      vistaAdmin = false;
      vistaComprado = false;
      vistaDelivery = true;
    } else {
      vistaGeneral = true;
      vistaAdmin = false;
      vistaComprado = false;
      vistaDelivery = false;
    }
    return Container(
        color: Helper.brandColors[1],
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
          padding: EdgeInsets.all(20),
          width: double.infinity,
          child: Column(children: [
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
                    enable: enable,
                    hintText: 'Detallar solicitud de materiales',
                    icono: Icons.description_outlined,
                    textController: areaTxtController,
                    lines: 8,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  enable
                      ? DropdownButtonFormField2(
                          value: prioridad,
                          items: items,
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
                          onSaved: (value) {},
                        )
                      : Container(),
                  SizedBox(
                    height: 20,
                  ),
                  (vistaAdmin || vistaComprado)
                      ? DropdownButtonFormField2(
                          value: repartidoId,
                          items: repartidores,
                          style: TextStyle(
                              color: Helper.brandColors[5], fontSize: 16),
                          iconSize: 30,
                          buttonHeight: 60,
                          buttonPadding: EdgeInsets.only(left: 20, right: 10),
                          decoration: getDecoration(),
                          hint: Text(
                            'Seleccione delivery',
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
                            if (value != '1') {
                              pedidoAsignado = true;
                              usuarioAsignado = value.toString();
                              widget.pedido!.tsAsignado =
                                  DateTime.now().millisecondsSinceEpoch;
                            } else {
                              widget.pedido!.tsAsignado = 0;
                              widget.pedido!.usuarioAsignado = '';
                              pedidoAsignado = false;
                            }
                          },
                          onSaved: (value) {},
                        )
                      : Container(),
                  (vistaAdmin || vistaComprado || vistaDelivery) &&
                          widget.pedido!.asignado
                      ? Row(
                          children: [
                            Text(
                              'Cerrar pedido',
                              style: TextStyle(color: Helper.brandColors[5]),
                            ),
                            Switch(
                                value: pedidoCerrado,
                                activeColor: Helper.brandColors[3],
                                activeTrackColor: Helper.brandColors[8],
                                inactiveTrackColor: Helper.brandColors[3],
                                onChanged: (cerrado) {
                                  setState(() {
                                    pedidoCerrado = cerrado;
                                    if (cerrado) {
                                      widget.pedido!.tsCerrado =
                                          DateTime.now().millisecondsSinceEpoch;
                                    } else {
                                      widget.pedido!.tsCerrado = 0;
                                    }
                                  });
                                })
                          ],
                        )
                      : Container()
                ],
              ),
            ),
            SizedBox(
              height: 150,
            ),
            Row(
              mainAxisAlignment: widget.pedido != null
                  ? widget.pedido!.cerrado
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceAround
                  : MainAxisAlignment.spaceAround,
              children: [
                widget.pedido != null
                    ? !widget.pedido!.cerrado
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
                                  _obraService);
                              closeLoadingDialog(context);

                              if (response[0]) {
                                openAlertDialog(context, mensaje2,
                                    subMensaje: response[1]);
                              } else {
                                openAlertDialog(context, mensaje3);
                              }
                            },
                          )
                        : SizedBox()
                    : MainButton(
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
                              _obraService);
                          closeLoadingDialog(context);

                          if (response[0]) {
                            openAlertDialog(context, mensaje2,
                                subMensaje: response[1]);
                          } else {
                            openAlertDialog(context, mensaje3);
                            Navigator.pop(
                              context,
                              PedidosPage.routeName,
                            );
                          }
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
            )
          ]),
        ));
  }

  grabarPedido(obraId, areaTxtController, ObraService _obraService) async {
    MyResponse response;
    if (widget.pedido == null) {
      final ped = new Pedido(
          idObra: obraId,
          idUsuario: _pref.id,
          nota: areaTxtController.text,
          prioridad: prioridad);
      response = await _obraService.nuevoPedido(ped);
      return [false, ''];
    } else {
      if (usuarioAsignado == '1') {
        return [true, 'No se ha seleccionado repartidor'];
      } else {
        widget.pedido!.nota = areaTxtController.text;
        widget.pedido!.prioridad = prioridad;
        widget.pedido!.asignado = pedidoAsignado;
        widget.pedido!.usuarioAsignado = usuarioAsignado;
        widget.pedido!.cerrado = pedidoCerrado;
        response = await _obraService.editPedido(widget.pedido!);
        if (response.fallo) {
          return [true, response.error];
        } else {
          return [false, response.data];
        }
      }
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
}
