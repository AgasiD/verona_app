import 'package:flutter/material.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class AsignarPedidoForm extends StatefulWidget {
  const AsignarPedidoForm({Key? key}) : super(key: key);
  static const String routeName = 'asignarPedido';
  static String nameForm = 'Asignar pedido';
  static String alertMessage = 'Confirmar asignacion de pedido';
  static Function() accion = () {
    // TODO:
  };

  @override
  State<AsignarPedidoForm> createState() => _AsignarPedidoFormState();
}

class _AsignarPedidoFormState extends State<AsignarPedidoForm> {
  int repartidor = 1;
  @override
  Widget build(BuildContext context) {
    TextEditingController areaTxtController = new TextEditingController();
    final items = <DropdownMenuItem>[
      DropdownMenuItem(
        value: 1,
        child: Text('Uno'),
      ),
      DropdownMenuItem(
        value: 2,
        child: Text('dos'),
      ),
      DropdownMenuItem(
        value: 3,
        child: Text('t'),
      ),
      DropdownMenuItem(
        value: 4,
        child: Text('c'),
      ),
      DropdownMenuItem(
        value: 5,
        child: Text('ci'),
      ),
    ];
    return Container(
      margin: EdgeInsets.symmetric(vertical: 25),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(0, 3))
        ],
        color: Colors.grey.shade100,
      ),
      width: double.infinity,
      child: Form(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Repartidor'),
                DropdownButton(
                    isDense: false,
                    icon: Icon(Icons.delivery_dining_outlined),
                    isExpanded: true,
                    value: this.repartidor,
                    items: items,
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    hint: Text('Seleccione repartidor'),
                    onChanged: (dynamic a) => {
                          setState(() {
                            this.repartidor = a;
                          })
                        }),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            CustomInputArea(
              hintText: 'Escribir observacion',
              icono: Icons.ac_unit,
              textController: areaTxtController,
              lines: 10,
            )
          ],
        ),
      ),
    );
  }
}
