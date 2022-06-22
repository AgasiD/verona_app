import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PropietariosList extends StatelessWidget {
  const PropietariosList({Key? key}) : super(key: key);
  static final routeName = 'propietario_list';

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    print(obraId);
    final _obraService = Provider.of<ObraService>(context, listen: false);
    return Scaffold(
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
              future: _obraService.obtenerObra(obraId),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Loading(mensaje: 'Cargando propietarios');
                } else {
                  final obra = snapshot.data as Obra;
                  if (obra.propietarios.length > 0) {
                    final dataTile = obra.propietarios.map((e) =>
                        Helper.toCustomTile('${e.nombre + ' ' + e.apellido}',
                            e.dni, '${e.nombre[0] + e.apellido[0]}'));
                    return Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height - 200,
                          color: Helper.brandColors[1],
                          child: CustomListView(
                              padding: 15, data: dataTile.toList()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MainButton(
                              width: 150,
                              height: 20,
                              color: Helper.brandColors[8],
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AgregarPropietariosPage.routeName);
                              },
                              text: 'Agregar propietario',
                              fontSize: 15,
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height - 200,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                'Aún no hay propietarios asignados',
                                style: TextStyle(
                                    fontSize: 18, color: Helper.brandColors[4]),
                              ),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MainButton(
                              width: 150,
                              height: 20,
                              color: Helper.brandColors[8],
                              onPressed: () {},
                              text: 'Agregar propietario',
                              fontSize: 15,
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                }
              }),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}
