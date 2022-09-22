import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/asignar_equipo.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class EquipoList extends StatelessWidget {
  const EquipoList({Key? key}) : super(key: key);
  static final routeName = 'equipo_list';

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final _obraService = Provider.of<ObraService>(context, listen: false);
    return Scaffold(
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
              future: _obraService.obtenerObra(obraId),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Loading(mensaje: 'Cargando equipo asignado');
                } else {
                  final obra = snapshot.data as Obra;
                  final _pref = new Preferences();
                  if (obra.equipo.length > 0) {
                    final dataTile = obra.equipo.map((e) => Helper.toCustomTile(
                        '${e.nombre + ' ' + e.apellido}',
                        Helper.getProfesion(e.role),
                        '${e.nombre[0] + e.apellido[0]}'));
                    return Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height - 220,
                          color: Helper.brandColors[1],
                          child: CustomListView(
                              padding: 15, data: dataTile.toList()),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        _pref.role == 1
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  MainButton(
                                    width: 150,
                                    height: 20,
                                    color: Helper.brandColors[8],
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AsignarEquipoPage.routeName);
                                    },
                                    text: 'Modificar equipo',
                                    fontSize: 15,
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height - 210,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                'Aún no hay integrantes en el equipo',
                                style: TextStyle(
                                    fontSize: 18, color: Helper.brandColors[4]),
                              ),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        _pref.role == 1
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  MainButton(
                                    width: 150,
                                    height: 20,
                                    color: Helper.brandColors[8],
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AsignarEquipoPage.routeName);
                                    },
                                    text: 'Modificar equipo',
                                    fontSize: 15,
                                  ),
                                ],
                              )
                            : Container(),
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
