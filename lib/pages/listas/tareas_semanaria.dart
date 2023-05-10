import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/pages/forms/semanario_message.dart';
import 'package:verona_app/pages/listas/tareas.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class TareasSemanarias extends StatelessWidget {
  static final routeName = 'TareasSemanarias';
  List<Tarea> selectedTask = [];

  TareasSemanarias({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
          title: Text('Tareas realizadas'),
          backgroundColor: Helper.brandColors[1],
          
        ),
        backgroundColor: Helper.brandColors[1],
        body: SafeArea(
      
      child: _Semanario(selectedTask: selectedTask)),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, SemanarioMessageForm.routeName, arguments: {'data': selectedTask}),
          child: Icon(Icons.navigate_next_rounded, size: 40),
          backgroundColor: Helper.brandColors[8],
          mini: true,
        ),
      
    );
  }
}

class _Semanario extends StatelessWidget {
  _Semanario({Key? key, required this.selectedTask }) : super(key: key);

  List<Tarea> selectedTask;

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    final tareas = _obraService.obra.obtenerTareasRealizadasByDias(dias: 30);
    asignarTareas(tareas);
    final hasta = DateTime.now();
    final desde = DateTime.now().subtract(Duration(days: 5));

    TextEditingController txtCtrlDesde = new TextEditingController(text:Helper.getFechaFromTS(hasta.millisecondsSinceEpoch));
    TextEditingController txtCtrlHasta = new TextEditingController(text:Helper.getFechaFromTS(desde.millisecondsSinceEpoch));

    return  Column(
          
          children: [
          //  Container(
                
          //        margin: EdgeInsets.symmetric(vertical: 10),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //         Row(children: [Text('Desde'),CalendarInput(habilitaEdicion: true, selectedDate: [hasta], txtCtrlFecha: txtCtrlDesde,), ],),
          //         Row(children: [Text('Hasta'),CalendarInput(habilitaEdicion: true, selectedDate: [desde], txtCtrlFecha: txtCtrlHasta,)],)
          //       ],),
          
          //   ), 
           _ListTask(
                    etapaId: '', tareas: tareas, tareasSemanales: false, selectedTask:selectedTask),
            

          ],

   );
  }

  asignarTareas(List tareas){
    tareas.forEach((element) 
    {
      selectedTask.addAll((element['tareas'] as List).map((e) => e));
     });
  }
  
}

class _ListTask extends StatefulWidget {
  _ListTask(
      {Key? key,
      required this.tareas,
      required this.etapaId,
      this.tareasSemanales = false,
      required this.selectedTask
      })
      : super(key: key);

  final List<dynamic> tareas;
  final String etapaId;
  bool tareasSemanales;
    List<Tarea> selectedTask;

  @override
  State<_ListTask> createState() => __ListTaskState();
}

class __ListTaskState extends State<_ListTask> {
  late ObraService _obraService;
  @override
  Widget build(BuildContext context) {
    _obraService = Provider.of<ObraService>(context, listen: false);

    return Expanded(
      child: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: widget.tareas.length,
            padding: const EdgeInsets.only(bottom: 50),
            itemBuilder: (context, index) {
    
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Helper.brandColors[9], width: .2),
                    borderRadius: BorderRadius.circular(5),
                    color: Helper.brandColors[0],
                  ),
                  child: ListTile(
                    title: Text(widget.tareas[index]['subetapa']),
                    textColor: Helper.brandColors[5],
                  ),
                ),
    
           
                    ListView.builder(
                       physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                    itemCount: widget.tareas[index]['tareas'].length,
                  itemBuilder: (context, i) {
                      return Container(
                      color: Helper.brandColors[2],
                      child: _TaskTile(
                        etapaId: widget.etapaId,
                        tarea: widget.tareas[index]['tareas'][i],
                        index: i,
                        onCheck: addTask,
                        checkToMessage: checkToMessage,
                      ),
                    
                    );})
               
                
              ],
            );
            },
          )),
        ],
      ),
    );
  }
  addTask(Tarea task){
    if(checkToMessage(task)){
      widget.selectedTask.removeWhere((t) => t.id == task.id);
     
    }else{

    widget.selectedTask.add(task);
    }
    setState(() {
      
    });
  }

  checkToMessage(Tarea task){
    return widget.selectedTask.contains(task);
  }
}

class _TaskTile extends StatefulWidget {
  _TaskTile(
      {Key? key,
      required this.tarea,
      required this.index,
      required this.etapaId,
      this.edit = true,
      this.tareasSemanales = false, 
      required this.onCheck,
      required this.checkToMessage
      })
      : super(key: key);

  Tarea tarea;
  int index;
  String etapaId;
  bool edit, tareasSemanales;
  Function(Tarea) onCheck;
  Function(Tarea) checkToMessage;
  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> {
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
            child: CheckboxListTile(
              enabled: [1, 2, 7].contains(_pref.role),
              tileColor: Helper.brandColors[2],
              checkColor: Helper.brandColors[5],
              activeColor: Helper.brandColors[8],
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${widget.index + 1} - ${widget.tarea.descripcion}',
                // overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Helper.brandColors[3], fontSize: 15),
              ),
              onChanged: (value) async {
                  widget.onCheck(widget.tarea);

                final tareasSemanales = true;
                if (tareasSemanales) {
                  return;
                }
              },
              value: widget.checkToMessage(widget.tarea),
            )));

    if (_pref.role == 1 && !widget.tarea.realizado)
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

  Future<void> actualizaTareaBD(BuildContext context, bool? value) async {
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

