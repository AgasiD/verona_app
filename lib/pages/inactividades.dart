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
      floatingActionButton: CustomNavigatorButton(
        accion: () => Navigator.pushNamed(context, InactividadesForm.routeName,
            arguments: {'obraId': obraId}),
        icono: Icons.add,
        showNotif: false,
      ),
      body: Container(
        color: Helper.brandColors[1],
        child: FutureBuilder(
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
                        index: index,
                        obraId: obraId,
                        inactividad:
                            Inactividad.fromMap(obra.diasInactivos[index]));
                  });
            }
          },
        ),
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
  _InactividadTile(
      {Key? key,
      required this.inactividad,
      required this.obraId,
      required this.index})
      : super(key: key);
  Inactividad inactividad;
  String obraId;
  int index;

  @override
  State<_InactividadTile> createState() => __InactividadTileState();
}

class __InactividadTileState extends State<_InactividadTile> {
  final _pref = new Preferences();
  bool esPar = false;

  @override
  void initState() {
    super.initState();
    if (widget.index % 2 == 0) {
      esPar = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _color = esPar ? Helper.brandColors[2] : Helper.brandColors[1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                  color: _color, borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: !esPar ? Helper.brandColors[9] : null,
                      borderRadius: BorderRadius.circular(100)),
                  child: CircleAvatar(
                    backgroundColor: Helper.brandColors[0],
                    child: Icon(Icons.work_off_outlined),
                  ),
                ),
                title: Text('${widget.inactividad.nombre}',
                    style: TextStyle(
                      color: Helper.brandColors[5],
                    )),
                subtitle: Text(
                  widget.inactividad.fecha,
                  style:
                      TextStyle(color: Helper.brandColors[9].withOpacity(.99)),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Helper.brandColors[3],
                ),
                onTap: () {
                  Navigator.pushNamed(context, InactividadesForm.routeName,
                      arguments: {
                        'obraId': widget.obraId,
                        'id': widget.inactividad.id
                      });
                },
              )),
        ],
      ),
    );
  }
}
