import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/pages/listas/asigna_tareas_extras.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class TareasCheckList extends StatefulWidget {
  TareasCheckList({Key? key}) : super(key: key);
  static final routeName = 'TareasCheckList';

  @override
  State<TareasCheckList> createState() => _TareasCheckListState();
}

class _TareasCheckListState extends State<TareasCheckList> {
  bool editOrder = false;

  List<Tarea> tareas = [];

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final subetapaId = arguments['subetapaId'];
    final etapaId = arguments['etapaId'];
    final _pref = new Preferences();
    final _obraService = Provider.of<ObraService>(context);
    tareas = _obraService.obra.etapas
        .singleWhere((etapa) => etapa.id == etapaId)
        .subetapas
        .singleWhere((subetapa) => subetapa.id == subetapaId)
        .tareas;

    return Scaffold(
      // appBar: AppBar(title: Text('${_obraService.obra.nombre} - ${_obraService.obra.barrio}${_obraService.obra.lote}'), backgroundColor: Helper.brandColors[2], automaticallyImplyLeading: false),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
          backgroundColor: Helper.brandColors[2],
          title: Text('${_obraService.obra.nombre} - ${_obraService.obra.barrio}${_obraService.obra.lote}'),
          automaticallyImplyLeading: false,
          actions: [
            _pref.role == 1 || _pref.role == 2 || _pref.role == 7
                ? IconButton(
                    onPressed: () {
                      editOrder = !editOrder;
                      setState(() {});
                    },
                    icon: Icon(Icons.sort))
                : Container()
          ]),
      backgroundColor: Helper.brandColors[1],
      body: Container(
        //height: MediaQuery.of(context).size.height - 100,
        child: tareas.length > 0
            ? ListaTarea(
                tareas: tareas,
                etapaId: etapaId,
                edit: editOrder,
              )
            : Center(
                child: Text(
                  'Aún no hay tareas ',
                  style: TextStyle(fontSize: 20, color: Helper.brandColors[4]),
                ),
              ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
      floatingActionButton: (_pref.role == 1 ||
              _pref.role == 2 ||
              _pref.role == 7)
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(
                  context, TareasExtrasPage.routeName,
                  arguments: {'etapaId': etapaId, 'subetapaId': subetapaId}),
              backgroundColor: Helper.brandColors[8],
              mini: true,
              child: Icon(Icons.add),
              splashColor: null,
            )
          : null,
    );
  }
}
