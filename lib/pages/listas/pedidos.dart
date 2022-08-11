import 'package:flutter/material.dart';
import 'package:verona_app/pages/forms/inactividad.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PedidosPage extends StatelessWidget {
  static final routeName = 'Pedidos';
  const PedidosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomPainterAppBar(
        muestraBackButton: true,
        title: 'Pedidos de obra',
      ),
      floatingActionButton: CustomNavigatorButton(
        accion: () => Navigator.pushNamed(context, PedidoForm.routeName,
            arguments: {'obraId': obraId}),
        icono: Icons.add,
        showNotif: false,
      ),
    );
  }
}
