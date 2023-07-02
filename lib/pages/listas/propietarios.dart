import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
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
    final _obraService = Provider.of<ObraService>(context);
    final obra = _obraService.obra as Obra;
    final _pref = new Preferences();

    final dataTile = obra.propietarios.map((e) =>
        Helper.toCustomTile('${e.nombre + ' ' + e.apellido}', e.dni, null));
    return Scaffold(
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: obra.propietarios.length > 0
              ? Column(
                  children: [
                    Expanded(
                      child:
                          CustomListView(padding: 15, data: dataTile.toList()),
                    ),
                    _pref.role == 1
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MainButton(
                                width: 150,
                                height: 20,
                                color: Helper.brandColors[8],
                                onPressed: () {
                                  Navigator.pushNamed(context,
                                      AgregarPropietariosPage.routeName);
                                },
                                text: 'Agregar propietario',
                                fontSize: 15,
                              ),
                            ],
                          )
                        : Container(),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text(
                              'Aún no hay propietarios asignados',
                              style: TextStyle(
                                  fontSize: 18, color: Helper.brandColors[4]),
                            ),
                          )),
                    ),
                    _pref.role == 1
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MainButton(
                                width: 150,
                                height: 20,
                                color: Helper.brandColors[8],
                                onPressed: () {
                                  Navigator.pushNamed(context,
                                      AgregarPropietariosPage.routeName);
                                },
                                text: 'Agregar propietario',
                                fontSize: 15,
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}
