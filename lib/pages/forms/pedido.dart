import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
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
  String title = 'nuevo pedido';
  Color colorHint = Helper.brandColors[3];
  Preferences _pref = new Preferences();
  int prioridad = 1;
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final pedidoId = arguments['pedidoId'] ?? '';
    final _obraService = Provider.of<ObraService>(context);

    TextEditingController areaTxtController = new TextEditingController();
    List<DropdownMenuItem<int>> items = <DropdownMenuItem<int>>[
      DropdownMenuItem(
        value: 1,
        child: Text('Baja'),
      ),
      DropdownMenuItem(
        value: 2,
        child: Text('Media'),
      ),
      DropdownMenuItem(
        value: 3,
        child: Text('Alta'),
      )
    ];
    return Scaffold(
      body: Container(
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
                      hintText: 'Detallar solicitud de materiales',
                      icono: Icons.description_outlined,
                      textController: areaTxtController,
                      lines: 8,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField2(
                      items: items,
                      style:
                          TextStyle(color: Helper.brandColors[5], fontSize: 16),
                      iconSize: 30,
                      buttonHeight: 60,
                      buttonPadding: EdgeInsets.only(left: 20, right: 10),
                      decoration: getDecoration(),
                      hint: Text(
                        'Seleccione puesto',
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
                        //Do something when changing the item if you want.
                      },
                      onSaved: (value) {},
                    ),
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
                      grabarPedido(obraId, areaTxtController, _obraService);
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
          )),
    );
  }

  grabarPedido(obraId, areaTxtController, ObraService _obraService) {
    final pedido = new Pedido(
        idObra: obraId,
        idUsuario: _pref.id,
        nota: areaTxtController.text,
        prioridad: prioridad);
    await _obraService.agregarPedido(pedido);
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
