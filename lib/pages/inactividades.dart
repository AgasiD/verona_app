import 'package:flutter/material.dart';
import 'package:verona_app/pages/forms/inactividad.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class InactividadesPage extends StatelessWidget {
  static final routeName = 'inactividades';
  const InactividadesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    return Scaffold(
      appBar: CustomAppBar(
        muestraBackButton: true,
        title: 'Dias inactivos',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'inactividadesForm',
              arguments: {'obraId': obraId});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
