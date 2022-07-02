import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/models/pedido.dart';
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

class _Form extends StatelessWidget {
  _Form({Key? key, this.pedido = null}) : super(key: key);
  Pedido? pedido;
  Color colorHint = Helper.brandColors[3];
  Preferences _pref = new Preferences();
  int prioridad = 1;
  String title = 'nuevo pedido';
  bool enable = true;
  TextEditingController areaTxtController = new TextEditingController();
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
  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    int initialData = 0;

    if (pedido != null) {
      initialData = pedido!.prioridad;
      areaTxtController.text = pedido!.nota;
      title = 'editar pedido';
      prioridad = pedido!.prioridad;
      pedido!.asignado ? enable = false : true;
      pedido!.cerrado ? enable = false : true;
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
                ],
              ),
            ),
            SizedBox(
              height: 150,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MainButton(
                  width: 120,
                  fontSize: 18,
                  color: Helper.brandColors[8].withOpacity(.5).withAlpha(150),
                  text: 'Grabar',
                  onPressed: () async {
                    String mensaje1 = 'Creando pedido...';
                    String mensaje2 = 'Error al crear pedido';
                    String mensaje3 = 'Pedido creado con exito';
                    if (pedido != null) {
                      mensaje1 = 'Actualizando pedido...';
                      mensaje2 = 'Error al actualizar el pedido';
                      mensaje3 = 'Pedido actualizado con exito';
                    }
                    openLoadingDialog(context, mensaje: mensaje1);
                    final response = await grabarPedido(
                        _obraService.obra.id, areaTxtController, _obraService);
                    closeLoadingDialog(context);

                    if (response[0]) {
                      openAlertDialog(context, mensaje2,
                          subMensaje: response[1]);
                    } else {
                      openAlertDialog(context, mensaje3);
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
    if (pedido == null) {
      final ped = new Pedido(
          idObra: obraId,
          idUsuario: _pref.id,
          nota: areaTxtController.text,
          prioridad: prioridad);
      response = await _obraService.nuevoPedido(ped);
    } else {
      pedido!.nota = areaTxtController.text;
      pedido!.prioridad = prioridad;
      response = await _obraService.editPedido(pedido!);
    }
    if (response.fallo) {
      return [true, response.error];
    } else {
      return [false, response.data];
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
