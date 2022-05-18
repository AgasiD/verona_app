import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/forms/inactividad.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class InactividadesPage extends StatelessWidget {
  static final routeName = 'inactividades';
  const InactividadesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final _obraService = Provider.of<ObraService>(context);
    final _pref = new Preferences();
    return Scaffold(
      appBar: CustomAppBar(
        muestraBackButton: true,
        title: 'Dias inactivos',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, InactividadesForm.routeName,
              arguments: {'obraId': obraId});
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _obraService.obtenerObra(obraId),
        builder: (_, snapshot) {
          if (snapshot.data == null) {
            return Loading(mensaje: 'Cargando Inactividados');
          } else {
            final obra = (snapshot.data as Obra);

            if (obra.diasInactivos.length == 0) {
              return Container(
                child: Center(
                  child: Text(
                    'Aún no se registraron dias inactivos ',
                    style: TextStyle(fontSize: 17, color: Colors.grey[400]),
                    maxLines: 3,
                  ),
                ),
              );
            }
            obra.diasInactivos = ordenaInactividad(obra.diasInactivos);
            return ListView.builder(
                itemCount: obra.diasInactivos.length,
                itemBuilder: (_, index) {
                  return _InactividadTile(
                      obraId: obraId,
                      inactividad:
                          Inactividad.fromMap(obra.diasInactivos[index]));
                });
          }
        },
      ),
    );
  }
}

ordenaInactividad(diasInactivos) {
  diasInactivos.sort(((a, b) {
    final fechasA = a['fecha'].toString().split('/');
    final fechaA = DateTime(
        int.parse(fechasA[2]), int.parse(fechasA[1]), int.parse(fechasA[0]));
    final fechasB = b['fecha'].toString().split('/');
    final fechaB = DateTime(
        int.parse(fechasB[2]), int.parse(fechasA[1]), int.parse(fechasB[0]));

    return fechaB.compareTo(fechaA);
  }));

  return diasInactivos;
}

class _InactividadTile extends StatefulWidget {
  _InactividadTile({Key? key, required this.inactividad, required this.obraId})
      : super(key: key);
  Inactividad inactividad;
  String obraId;

  @override
  State<_InactividadTile> createState() => __InactividadTileState();
}

class __InactividadTileState extends State<_InactividadTile> {
  final _pref = new Preferences();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('${widget.inactividad.nombre}'),
          subtitle: Text(widget.inactividad.fecha),
          leading: Icon(Icons.work_off_outlined),
          trailing: Icon(Icons.arrow_forward_ios_rounded),
          onTap: () {
            Navigator.pushNamed(context, InactividadesForm.routeName,
                arguments: {
                  'obraId': widget.obraId,
                  'id': widget.inactividad.id
                });
          },
        ),
        Divider(
          height: 1,
        )
      ],
    );
  }
}
