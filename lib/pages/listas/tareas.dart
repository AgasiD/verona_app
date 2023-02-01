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

    // tareas = [new Tarea(descripcion: '12332', etapa: '111', isDefault: false)];

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Tareas'),
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
        height: MediaQuery.of(context).size.height - 100,
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

class ListaTarea extends StatefulWidget {
  ListaTarea({
    Key? key,
    required this.tareas,
    required this.etapaId,
    this.edit = false,
  }) : super(key: key);

  final List<Tarea> tareas;
  final String etapaId;
  bool edit;
  @override
  State<ListaTarea> createState() => _ListaTareaState();
}

class _ListaTareaState extends State<ListaTarea> {
  late ObraService _obraService;
  @override
  Widget build(BuildContext context) {
    _obraService = Provider.of<ObraService>(context, listen: false);

    return ReorderableListView(
      // itemCount: tareas.length,
      // padding: const EdgeInsets.symmetric(horizontal: 40),

      children: [
        for (int index = 0; index < widget.tareas.length; index += 1)
          Container(
            key: Key(widget.tareas[index].id),
            color: Helper.brandColors[2],
            child: _TareaTile(
              etapaId: widget.etapaId,
              tarea: widget.tareas[index],
              index: index,
              edit: widget.edit,
            ),
          )
      ],
      onReorder: (oldIndex, newIndex) async {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final Tarea item = widget.tareas.removeAt(oldIndex);
        widget.tareas.insert(newIndex, item);
        setState(() {});
        final response = await _obraService.actualizarOrdenTareas(
            _obraService.obra.id,
            widget.etapaId,
            widget.tareas[newIndex].subetapa,
            widget.tareas);

        if (response.fallo) {
          openAlertDialog(context, 'Error al ordenar',
              subMensaje: response.error);
          return;
        }
      },
    );
  }
}

class _TareaTile extends StatefulWidget {
  _TareaTile({
    Key? key,
    required this.tarea,
    required this.index,
    required this.etapaId,
    this.edit = true,
  }) : super(key: key);

  Tarea tarea;
  int index;
  String etapaId;
  bool edit;

  @override
  State<_TareaTile> createState() => _TareaTileState();
}

class _TareaTileState extends State<_TareaTile> {
  late ObraService _obraService;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _obraService = Provider.of<ObraService>(context, listen: false);
    final _pref = new Preferences();

    final checkboxTile = Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        child: GestureDetector(
            onLongPress: () {
              openAlertDialog(context, 'Descripción',
                  subMensaje: widget.tarea.descripcion);
            },
            child: widget.edit
                ? ListTile(
                    contentPadding: EdgeInsets.zero,
                    tileColor: Helper.brandColors[2],
                    trailing: ReorderableDragStartListener(
                        index: widget.index,
                        child: Icon(
                          Icons.drag_indicator_outlined,
                          color: Helper.brandColors[8],
                        )),
                    title: Text(
                      '${widget.index + 1} - ${widget.tarea.descripcion}',
                      // overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: Helper.brandColors[3], fontSize: 15),
                    ),
                  )
                : CheckboxListTile(
                    enabled: [1, 2, 7].contains(_pref.role),
                    tileColor: Helper.brandColors[2],
                    checkColor: Helper.brandColors[5],
                    activeColor: Helper.brandColors[8],
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${widget.index + 1} - ${widget.tarea.descripcion}',
                      // overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: Helper.brandColors[3], fontSize: 15),
                    ),
                    onChanged: (value) async {
                      openLoadingDialog(context, mensaje: 'Actualizando...');
                      final response = await _obraService.actualizarTarea(
                          _obraService.obra.id,
                          widget.etapaId,
                          widget.tarea.subetapa,
                          widget.tarea.id,
                          value!,
                          new Preferences().id,
                          DateTime.now().millisecondsSinceEpoch);
                      closeLoadingDialog(context);
                      widget.tarea.realizado = value!;
                      _obraService.notifyListeners();

                      if (response.fallo) {
                        openAlertDialog(context, 'Error al actualizar tarea',
                            subMensaje: response.error);
                      }

                      setState(() {});
                    },
                    value: widget.tarea.realizado,
                  )));

    if (_pref.role == 1)
      return Dismissible(
          confirmDismiss: (DismissDirection direction) async {
            if (ultimaTarea(
                widget.etapaId, widget.tarea.subetapa, widget.tarea.id)) {
              openAlertDialog(context, 'No se puede dejar sin tareas');

              return false;
            }
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                if (Platform.isAndroid) {
                  return AlertDialog(
                    title: const Text("Confirmar"),
                    content: const Text("Confirmar eliminacion de tarea"),
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
                    title: Text('Confirmar eliminacion de tarea'),
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
            await eliminarTarea(context, _obraService.obra.id, widget.etapaId,
                widget.tarea.subetapa, widget.tarea.id);
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
          key: ValueKey<String>(widget.tarea.id),
          child: checkboxTile);

    return checkboxTile;
  }

  eliminarTarea(context, obraId, etapaId, subetapaId, tareaId) async {
    final index =
        _obraService.obra.etapas.indexWhere((etapa) => etapa.id == etapaId);
    final indexSub = _obraService.obra.etapas[index].subetapas
        .indexWhere((subetapa) => subetapa.id == subetapaId);

    final indexTarea = _obraService
        .obra.etapas[index].subetapas[indexSub].tareas
        .indexWhere((tarea) => tarea.id == tareaId);

    if (_obraService.obra.etapas[index].subetapas[indexSub].tareas.length <=
        1) {
      openAlertDialog(context, 'No se puede dejar sin tareas');
      return;
    }

    _obraService.obra.etapas[index].subetapas[indexSub].tareas
        .removeAt(indexTarea);
    openLoadingDialog(context, mensaje: 'Eliminando tarea...');
    final response =
        await _obraService.quitarTarea(etapaId, subetapaId, tareaId, obraId);
    closeLoadingDialog(context);
    if (response.fallo) {
      openAlertDialog(context, 'Error al eliminar tarea',
          subMensaje: response.error);
    }
  }

  bool ultimaTarea(etapaId, subetapaId, tareaId) {
    final index =
        _obraService.obra.etapas.indexWhere((etapa) => etapa.id == etapaId);
    final indexSub = _obraService.obra.etapas[index].subetapas
        .indexWhere((subetapa) => subetapa.id == subetapaId);

    final indexTarea = _obraService
        .obra.etapas[index].subetapas[indexSub].tareas
        .indexWhere((tarea) => tarea.id == tareaId);

    return _obraService.obra.etapas[index].subetapas[indexSub].tareas.length <=
        1;
  }
}
