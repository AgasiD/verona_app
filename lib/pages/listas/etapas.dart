import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/pages/listas/asigna_etapas_extras.dart';
import 'package:verona_app/pages/listas/subetapas.dart';
import 'package:verona_app/pages/listas/tareas_semanaria.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class EtapasObra extends StatelessWidget {
  EtapasObra({Key? key}) : super(key: key);
  static final routeName = 'EtapasObra';

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    final _pref = new Preferences();
    return Scaffold(
      backgroundColor: Helper.brandColors[1],
      body: Column(
        children: [
          Expanded(child: _Etapas(etapas: _obraService.obra.etapas)),
          _pref.role == 1 || _pref.role == 2 ? MainButton(onPressed: ()=> Navigator.pushNamed(context, TareasSemanarias.routeName, arguments: { 'obras': [_obraService.obra] }), text: 'Resumen semanal' , width: 150, height: 30, color: Helper.brandColors[8], fontSize: 15,) : Container()
        ],
      ),
      floatingActionButton:
          (_pref.role == 1 || _pref.role == 2 || _pref.role == 7)
              ? FloatingActionButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, EtapasExtrasPage.routeName, arguments: {'obra': _obraService.obra}),
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

class _Etapas extends StatelessWidget {
  _Etapas({Key? key, required this.etapas}) : super(key: key);
  List<Etapa> etapas;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 100,
        child: ListView.builder(
          itemCount: etapas.length,
          itemBuilder: (context, index) {
            return _EtapaCard(etapa: etapas[index] as Etapa, index: index);
          },
        ),
      ),
    );
  }
}

class _EtapaCard extends StatelessWidget {
  _EtapaCard({Key? key, required this.etapa, required this.index})
      : super(key: key);

  Etapa etapa;
  int index;

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
          onTap: () => Navigator.pushNamed(context, SubEtapasObra.routeName,
              arguments: {"index": index}),
          leading: Container(
            width: 50,
            child: Center(
              child: Row(
                children: [
                  Icon(
                      etapa.porcentajeRealizado < 99
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
              etapa.descripcion,
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
                  value: etapa.porcentajeRealizado / 100,
                  color: Helper.brandColors[8],
                ),
              ),
              Text(
                '${etapa.porcentajeRealizado} %',
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
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                if (Platform.isAndroid) {
                  return AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text("Confirmar eliminacion de etapa"),
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
                    title: Text('Confirmar eliminacion de etapa'),
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
            await eliminarEtapa(context, _obraService.obra.id, etapa.id);
          },
          background: Container(
            color: Colors.red,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                'Eliminar',
                style: TextStyle(color: Helper.brandColors[4], fontSize: 20),
              ),
            ),
          ),
          key: ValueKey<int>(index),
          child: tile);
    return tile;
  }

  eliminarEtapa(context, obraId, etapaId) async {
    final index =
        _obraService.obra.etapas.indexWhere((element) => element.id == etapaId);
    _obraService.obra.quitarEtapa(etapaId);
    openLoadingDialog(context, mensaje: 'Eliminando etapa...');
    final response = await _obraService.quitarEtapa(etapaId, obraId);
    closeLoadingDialog(context);
    if (response.fallo) {
      openAlertDialog(context, 'Error al eliminar etapa',
          subMensaje: response.error);
    }
  }
}
