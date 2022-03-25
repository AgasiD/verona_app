import 'package:flutter/material.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PedidoForm extends StatefulWidget implements MyForm {
  const PedidoForm({Key? key}) : super(key: key);
  static const String routeName = 'pedido';

  static String nameForm = 'Nuevo pedido';
  static String alertMessage = 'Confirmar nuevo pedido';
  static Function() accion = () {
    // TODO:
  };
  @override
  State<PedidoForm> createState() => _PedidoFormState();
}

class _PedidoFormState extends State<PedidoForm> {
  int prioridad = 1;
  @override
  Widget build(BuildContext context) {
    TextEditingController areaTxtController = new TextEditingController();
    final items = <DropdownMenuItem>[
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
            CustomInputArea(
              hintText: 'Detallar pedido de materiales ',
              icono: Icons.ac_unit,
              textController: areaTxtController,
              lines: 10,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Prioridad'),
                DropdownButton(
                    isDense: false,
                    isExpanded: false,
                    value: this.prioridad,
                    items: items,
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    hint: Text('Seleccione prioridad'),
                    onChanged: (dynamic a) => {
                          setState(() {
                            this.prioridad = a;
                          })
                        }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
