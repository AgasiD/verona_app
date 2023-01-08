import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/pages/listas/asigna_subetapas_extras.dart';
import 'package:verona_app/pages/listas/tareas.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class SubEtapasObra extends StatelessWidget {
  SubEtapasObra({Key? key}) : super(key: key);
  static final routeName = 'SubEtapasObra';

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final index = arguments['index'];
    final _pref = new Preferences();
    return Scaffold(
      backgroundColor: Helper.brandColors[1],
      body: _SubEtapas(
          etapaId: _obraService.obra.etapas[index].id,
          subetapas: _obraService.obra.etapas[index].subetapas),
      floatingActionButton: !(_pref == 1 || _pref == 2 || _pref == 7)
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(
                  context, SubetapasExtrasPage.routeName,
                  arguments: {'etapaId': _obraService.obra.etapas[index].id}),
              backgroundColor: Helper.brandColors[8],
              mini: true,
              child: Icon(Icons.add),
              splashColor: null,
            )
          : null,
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _SubEtapas extends StatelessWidget {
  _SubEtapas({Key? key, required this.etapaId, required this.subetapas})
      : super(key: key);
  List<Subetapa> subetapas;
  String etapaId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 100,
        child: ListView.builder(
          itemCount: subetapas.length,
          itemBuilder: (context, index) {
            return _SubEtapaCard(
                etapaId: etapaId, subetapa: subetapas[index] as Subetapa);
          },
        ),
      ),
    );
  }
}

class _SubEtapaCard extends StatelessWidget {
  _SubEtapaCard({Key? key, required this.etapaId, required this.subetapa})
      : super(key: key);

  Subetapa subetapa;
  String etapaId;
  late ObraService _obraService;

  @override
  Widget build(BuildContext context) {
    final _pref = new Preferences();
    _obraService = Provider.of<ObraService>(context, listen: false);

    final tile = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Helper.brandColors[2],
        boxShadow: [
          BoxShadow(
              color: Helper.brandColors[0],
              blurRadius: 4,
              offset: Offset(10, 8))
        ],
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: ListTile(
          onTap: () => Navigator.pushNamed(context, TareasCheckList.routeName,
              arguments: {"etapaId": etapaId, "subetapaId": subetapa.id}),
          leading: Container(
            width: 50,
            child: Center(
              child: Row(
                children: [
                  Icon(
                      subetapa.porcentajeRealizado < 99
                          ? Icons.check_box_outline_blank_outlined
                          : Icons.check_box,
                      color: Helper.brandColors[3]),
                ],
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.0),
            child: Text(
              subetapa.descripcion,
              style: TextStyle(color: Helper.brandColors[4], fontSize: 18),
            ),
          ),
          subtitle: Row(
            // mainAxisAlignment: MainAxisAlignment.,
            children: [
              Container(
                margin: EdgeInsets.only(right: 15),
                width: 100,
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: subetapa.porcentajeRealizado / 100,
                  color: Helper.brandColors[8],
                ),
              ),
              Text(
                '${subetapa.porcentajeRealizado} %',
                style: TextStyle(color: Helper.brandColors[4]),
              ),
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              color: Helper.brandColors[8]),
        ),
      ),
    );

    if (_pref.role == 1)
      return Dismissible(
          confirmDismiss: (DismissDirection direction) async {
            if (ultimaSubetapa(etapaId, subetapa.id)) {
              openAlertDialog(context, 'No se puede dejar sin subetapas');

              return false;
            }
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                if (Platform.isAndroid) {
                  return AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text("Confirmar eliminacion de subetapa"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Confirmar')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancelar',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  );
                } else {
                  return CupertinoAlertDialog(
                    title: Text('Confirmar eliminacion de subetapa'),
                    actions: [
                      CupertinoDialogAction(
                          child: Text('Confirmar'),
                          onPressed: () async => Navigator.pop(context, true)),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        child: Text('Cancelar'),
                        onPressed: () => Navigator.pop(context, false),
                      )
                    ],
                  );
                }
              },
            );
          },
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            await eliminarSubetapa(
                context, _obraService.obra.id, etapaId, subetapa.id);
          },
          background: Container(
            color: Colors.red,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Eliminar',
                  style: TextStyle(color: Helper.brandColors[4], fontSize: 20),
                ),
              ),
            ),
          ),
          key: ValueKey<String>(subetapa.id),
          child: tile);

    return tile;
  }

  eliminarSubetapa(context, obraId, etapaId, subetapaId) async {
    final index =
        _obraService.obra.etapas.indexWhere((etapa) => etapa.id == etapaId);
    final indexSub = _obraService.obra.etapas[index].subetapas
        .indexWhere((subetapa) => subetapa.id == subetapaId);

    openLoadingDialog(context, mensaje: 'Eliminando subetapa...');
    final response =
        await _obraService.quitarSubetapa(etapaId, subetapaId, obraId);
    closeLoadingDialog(context);
    if (response.fallo) {
      openAlertDialog(context, 'Error al eliminar subetapa',
          subMensaje: response.error);
      return;
    }
    _obraService.obra.etapas[index].subetapas.removeAt(indexSub);
  }

  bool ultimaSubetapa(etapaId, subetapaId) {
    final index =
        _obraService.obra.etapas.indexWhere((etapa) => etapa.id == etapaId);
    final indexSub = _obraService.obra.etapas[index].subetapas
        .indexWhere((subetapa) => subetapa.id == subetapaId);
    return _obraService.obra.etapas[index].subetapas.length <= 1;
  }
}
