import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/pages/forms/semanario_message.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class TareasSemanarias extends StatelessWidget {
  static final routeName = 'TareasSemanarias';
  List<Tarea> selectedTask = [];

  TareasSemanarias({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    final _pref = new Preferences();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    List<Obra> obras = args['obras'];
    final esSingle = args['single'] ?? true;
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas realizadas'),
        backgroundColor: Helper.brandColors[1],
      ),
      backgroundColor: Helper.brandColors[2],
      body: SafeArea(
          child: esSingle
              ? _Semanario(
                  obras: obras, selectedTask: selectedTask, esSingle: esSingle)
              : FutureBuilder(
                  future: _obraService.obtenerObrasByUser(_pref.id),
                  builder: (context, snapshot) {
                    try {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Loading(
                          mensaje: 'Cargando obras...',
                        );
                      }
                      final response = snapshot.data as MyResponse;
                      if (response.fallo) {
                        print(response.error);
                        return Container(
                            child:
                                Center(child: Text('Error al buscar obras')));
                      }
                      obras = (response.data as List)
                          .map((json) => Obra.fromMap(json))
                          .toList();
                      return _Semanario(
                          obras: obras,
                          selectedTask: selectedTask,
                          esSingle: esSingle);
                    } catch (err) {
                      return CustomCenterText(text: err.toString());
                    }
                  })),
      floatingActionButton: esSingle
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(
                  context, SemanarioMessageForm.routeName,
                  arguments: {'data': selectedTask}),
              child: Icon(Icons.navigate_next_rounded, size: 40),
              backgroundColor: Helper.brandColors[8],
              mini: true,
            )
          : null,
    );
  }
}

class _Semanario extends StatefulWidget {
  _Semanario(
      {Key? key,
      required this.obras,
      required this.selectedTask,
      this.esSingle = true})
      : super(key: key);
  List<Obra> obras;
  List<Tarea> selectedTask;
  bool esSingle;

  @override
  State<_Semanario> createState() => _SemanarioState();
}

class _SemanarioState extends State<_Semanario> {
  dynamic obrasTareas = [];
  DateTime hasta = DateTime.now();
  late TextEditingController txtCtrlDesde;
  late TextEditingController txtCtrlHasta;
  late UsuarioService _usuarioService;
  DateTime desde = DateTime.now().subtract(Duration(days: 5));
  StreamController<List> _tareasStream = new StreamController<List>();
  Stream<List> get tareasStream => _tareasStream.stream;
  List<DropdownMenuItem<String>> personal = <DropdownMenuItem<String>>[];

  @override
  void initState() {
    super.initState();
    _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    buscarTareas(widget.obras, '1', '1',
        paramDesde: desde, paramHasta: hasta, listener: false);
    setFechas();
  }

  void setFechas() {
    txtCtrlDesde = new TextEditingController(
        text: Helper.getFechaFromTS(desde.millisecondsSinceEpoch,
            format: 'dd/MM/yyyy'));
    txtCtrlHasta = new TextEditingController(
        text: Helper.getFechaFromTS(hasta.millisecondsSinceEpoch,
            format: 'dd/MM/yyyy'));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _usuarioService.obtenerPersonal(roles: [1, 2]),
        builder: (context, snapshot) {
          try {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading(
                mensaje: 'Cargando usuarios...',
              );
            }
            final response = snapshot.data as List<Miembro>;
            personal.clear();
            personal.add(
              DropdownMenuItem(
                value: '1',
                child: AutoSizeText(
                  '--Todo el personal--'.toUpperCase(),
                  maxFontSize: 20,
                  minFontSize: 10,
                ),
              ),
            );
            response.sort((a, b) {
              return a.nombre.compareTo(b.nombre);
            });
            response.forEach((miembro) => personal.add(
                  DropdownMenuItem(
                      value: miembro.id,
                      child: AutoSizeText(
                        '${miembro.nombre} ${miembro.apellido}'.toUpperCase(),
                        maxFontSize: 20,
                        minFontSize: 10,
                      )),
                ));

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        FilterBar(
                            desde: desde,
                            txtCtrlDesde: txtCtrlDesde,
                            hasta: hasta,
                            txtCtrlHasta: txtCtrlHasta,
                            personal: personal,
                            obras: widget.obras,
                            esSingle: widget.esSingle,
                            action: buscarTareas),
                        _ListTask(
                          obras: obrasTareas,
                          tareasStream: tareasStream,
                          selectedTask: widget.selectedTask,
                          esSingle: widget.esSingle,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          } catch (err) {
            return CustomCenterText(text: 'Hubo un error inesperado');
          }
        });
  }

  buscarTareas(List<Obra> obras, String idUsuario, String idObra,
      {DateTime? paramDesde = null,
      DateTime? paramHasta = null,
      listener = true}) async {

    openLoadingDialog(context, mensaje: 'Buscando tareas...');

    obrasTareas.clear();

    DateFormat formato = DateFormat('dd/MM/yyyy');
    if (paramDesde == null && paramHasta == null) {
      desde = formato.parse(txtCtrlDesde.text);
      hasta = formato.parse(txtCtrlHasta.text);
    } else {
      desde = paramDesde!;
      hasta = paramHasta!;
    }

    //Obtengo las tareas desde las obras

    if (idObra != '1') {
      if (!widget.esSingle) {
        obras.forEach((obra) {
          if (idObra == obra.id)
            obrasTareas.add(obra.obtenerTareasRealizadasDesdeHasta(
                desde, hasta.add(Duration(days: 1))));
        });
      }
    } else {
      obras.forEach((obra) {
        obrasTareas.add(obra.obtenerTareasRealizadasDesdeHasta(
            desde, hasta.add(Duration(days: 1))));
      });
    }

    // Filtro de usuario
    if (!widget.esSingle) {
      if (idUsuario != '1') {
        obrasTareas = obrasTareas as List;

        obrasTareas.forEach((obra) {
          (obra['subetapas'] as List).forEach((subetapas) {
            subetapas['tareas'] = (subetapas['tareas'] as List<Tarea>)
                .where((t) => t.idUsuario == idUsuario)
                .toList();
          });
        });
      }
    }

    // quito las subetapas que no tengan tareas
    (obrasTareas as List).forEach((obra) {
      obra['subetapas'] = (obra['subetapas'] as List)
          .where((subetapa) => subetapa['tareas'].length > 0)
          .toList();
    });

    obrasTareas = (obrasTareas as List)
        .where((obra) => (obra['subetapas'] as List).length > 0)
        .toList();

    final usuarios = await _usuarioService.obtenerTodosUsuarios();

    _matchWithName(usuarios);
    if (widget.esSingle) {
      _asignarTareas(obrasTareas);
    }
    closeLoadingDialog(context);
    _tareasStream.add(obrasTareas);
    // setState(() {});
    
  }

  void _matchWithName(List<Miembro> usuarios) {
    //Hago el match con los idUsuario para mostrar nombre
    (obrasTareas as List).forEach((obra) {
      obra['subetapas'].forEach((subetapa) {
        subetapa['tareas'].forEach((tarea) {
          tarea.nombreSubetapa = subetapa['subetapa'];
          if (tarea.idUsuario == '' || tarea.idUsuario == null) {
            tarea.nombreUsuario = '';
          } else {
            final usuario = usuarios
                .singleWhere((usuario) => usuario.id == tarea.idUsuario);
            tarea.nombreUsuario = '${usuario.nombre} ${usuario.apellido}';
          }
        });
      });
    });
  }

  _asignarTareas(List obras) {
    widget.selectedTask.clear();

    obras.forEach((obra) {
      (obra['subetapas'] as List).forEach((subetapa) {
        widget.selectedTask.addAll((subetapa['tareas'] as List).map((e) => e));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tareasStream.close();
  }
}

class FilterBar extends StatefulWidget {
  FilterBar(
      {Key? key,
      required this.desde,
      required this.txtCtrlDesde,
      required this.hasta,
      required this.txtCtrlHasta,
      required this.personal,
      required this.action,
      required this.esSingle,
      required this.obras})
      : super(key: key);

  final Function(List<Obra>, String, String) action;
  final DateTime desde;
  final TextEditingController txtCtrlDesde;
  final DateTime hasta;
  final TextEditingController txtCtrlHasta;
  final List<DropdownMenuItem<String>> personal;
  final List<Obra> obras;
  final esSingle;

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  String userSelected = '1';
  String obraSelected = '';

  List<DropdownMenuItem<String>> obrasItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final initValueObra = '1';
    obrasItems = widget.obras
        .map((e) => DropdownMenuItem(
              child: Text(e.nombre.toUpperCase()),
              value: e.id,
            ))
        .toList();
    obrasItems.insert(
        0,
        DropdownMenuItem(
          child: Text(
            '--TODOS LOS PROYECTOS--',
          ),
          value: initValueObra,
        ));
    obraSelected = initValueObra;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Helper.brandColors[2],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 20),
                  width: 90,
                  child: Text('Desde',
                      style: TextStyle(color: Helper.brandColors[4]))),
              CalendarInput(
                habilitaEdicion: true,
                selectedDate: widget.desde,
                txtCtrlFecha: widget.txtCtrlDesde,
              ),
            ],
          ),
          Row(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 20),
                  width: 90,
                  child: Text('Hasta',
                      style: TextStyle(color: Helper.brandColors[4]))),
              CalendarInput(
                habilitaEdicion: true,
                selectedDate: widget.hasta,
                txtCtrlFecha: widget.txtCtrlHasta,
              )
            ],
          ),
          widget.esSingle
              ? Container()
              : Row(
                  children: [
                    Container(
                        padding: EdgeInsets.only(left: 20),
                        width: 90,
                        child: Text('Personal',
                            style: TextStyle(color: Helper.brandColors[4]))),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: SizedBox(
                          height: 80,
                          child: DropdownButtonFormField2(
                              value: userSelected,
                              items: widget.personal,
                              style: TextStyle(
                                  color: Helper.brandColors[5], fontSize: 16),
                              iconSize: 30,
                              buttonHeight: 60,
                              buttonPadding:
                                  EdgeInsets.only(left: 20, right: 5),
                              decoration: Helper.getDecoration(),
                              hint: FittedBox(
                                child: Text(
                                  'Todo el personal',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Helper.brandColors[3]),
                                ),
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Helper.brandColors[3],
                              ),
                              dropdownMaxHeight:
                                  MediaQuery.of(context).size.height * .4,
                              dropdownWidth: 300,
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Helper.brandColors[2],
                              ),
                              onChanged: (value) {
                                userSelected = value as String;
                              }),
                        ),
                      ),
                    )
                  ],
                ),
          widget.esSingle
              ? Container()
              : Row(
                  children: [
                    Container(
                        padding: EdgeInsets.only(left: 20),
                        width: 90,
                        child: Text('Proyecto',
                            style: TextStyle(color: Helper.brandColors[4]))),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: SizedBox(
                          height: 80,
                          child: DropdownButtonFormField2(
                              value: obraSelected,
                              items: obrasItems,
                              style: TextStyle(
                                  color: Helper.brandColors[5], fontSize: 16),
                              iconSize: 30,
                              buttonHeight: 60,
                              buttonPadding:
                                  EdgeInsets.only(left: 20, right: 10),
                              decoration: Helper.getDecoration(),
                              hint: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  '--TODOS LOS PROYECTOS--',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Helper.brandColors[3]),
                                ),
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Helper.brandColors[3],
                              ),
                              dropdownMaxHeight:
                                  MediaQuery.of(context).size.height * .4,
                              dropdownWidth: 250,
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Helper.brandColors[2],
                              ),
                              onChanged: (value) {
                                obraSelected = value as String;
                              }),
                        ),
                      ),
                    )
                  ],
                ),
          SizedBox(
            height: 10,
          ),
          MainButton(
            onPressed: () =>
                this.widget.action(widget.obras, userSelected, obraSelected),
            text: 'Buscar tareas',
            width: 100,
            color: Helper.brandColors[8],
            fontSize: 15,
            height: 25,
          )
        ],
      ),
    );
  }
}

class _ListTask extends StatefulWidget {
  _ListTask(
      {Key? key,
      required this.obras,
      required this.tareasStream,
      required this.selectedTask,
      required this.esSingle})
      : super(key: key);

  final List<dynamic> obras;
  List<Tarea> selectedTask;
  Stream<List> tareasStream;
  bool esSingle;
  @override
  State<_ListTask> createState() => __ListTaskState();
}

class __ListTaskState extends State<_ListTask> {
  late ObraService _obraService;
  List usuarios = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: [],
        stream: widget.tareasStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active && !snapshot.hasData) {
            return Loading(mensaje: 'Cargando tareas...');
          }

          if (!tieneTareas((snapshot.data as List))) {
            return Container(
              height: 300,
              child: Center(
                child: Text(
                  'No hay tareas realizadas entre fechas',
                  style: TextStyle(fontSize: 18, color: Helper.brandColors[4]),
                ),
              ),
            );
          }

          final obras = snapshot.data as List;

          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 50),
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: obras.length,
              itemBuilder: (context, index) {
                final obra = obras[index];
                final subetapas = obra['subetapas'];
                return Column(
                  children: [
                    Visibility(
                      visible: !widget.esSingle,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Helper.brandColors[9], width: .2),
                          borderRadius: BorderRadius.circular(5),
                          color: Helper.brandColors[8],
                        ),
                        child: ListTile(
                          title: Text(obra['obra'].toUpperCase(),
                              style: TextStyle(
                                  color: Helper.brandColors[4],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                              textAlign: TextAlign.center),
                          textColor: Helper.brandColors[5],
                        ),
                      ),
                    ),
                    ListView.builder(
                      itemCount: subetapas.length,
                      padding: const EdgeInsets.only(bottom: 50),
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final subetapa = subetapas[index];
                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Helper.brandColors[9], width: .2),
                                borderRadius: BorderRadius.circular(5),
                                color: Helper.brandColors[0],
                              ),
                              child: ListTile(
                                title: Text(subetapa['subetapa']),
                                textColor: Helper.brandColors[5],
                              ),
                            ),
                            ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: subetapa['tareas'].length,
                                itemBuilder: (context, i) {
                                  return Container(
                                    color: Helper.brandColors[2],
                                    child: _TaskTile(
                                      edit: widget.esSingle,
                                      etapaId: '',
                                      tarea: subetapa['tareas'][i],
                                      index: i,
                                      onCheck: addTask,
                                      checkToMessage: checkToMessage,
                                    ),
                                  );
                                })
                          ],
                        );
                      },
                    ),
                  ],
                );
              });
        });
  }

  addTask(Tarea task) {
    if (checkToMessage(task)) {
      widget.selectedTask.removeWhere((t) => t.id == task.id);
    } else {
      widget.selectedTask.add(task);
    }
    setState(() {});
  }

  checkToMessage(Tarea task) {
    return widget.selectedTask.contains(task);
  }

  bool tieneTareas(List data) {
    bool tiene = false;
    data.forEach((obra) {
      if ((obra['subetapas'] as List).length > 0) {
        tiene = true;
        ;
      }
    });
    return tiene;
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
      required this.checkToMessage})
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
            child: widget.edit
                ? CheckboxListTile(
                    enabled: [1, 2, 7].contains(_pref.role),
                    tileColor: Helper.brandColors[2],
                    checkColor: (widget.tarea.iniciado && !widget.tarea.realizado) ?  Helper.brandColors[8] : Helper.brandColors[5] ,
                    activeColor: (widget.tarea.iniciado && !widget.tarea.realizado) ?  Helper.brandColors[5] : Helper.brandColors[8] ,
                    contentPadding: EdgeInsets.zero,
                    title: Wrap(children: [
                      Text(
                        '${widget.index + 1} - ${widget.tarea.descripcion}',
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Helper.brandColors[3], fontSize: 15),
                      ),
                      widget.tarea.idUsuario.isNotEmpty
                          ? Text(
                              'Realizado por: ${widget.tarea.nombreUsuario} |',
                              // overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )
                          : Container(),
                      widget.tarea.idUsuario.isNotEmpty
                          ? Text(
                              '${Helper.getFechaHoraFromTS(widget.tarea.tsRealizado)}',
                              // overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )
                          : Container(),
                    ]),
                    onChanged: (value) async {
                      widget.onCheck(widget.tarea);

                      final tareasSemanales = true;
                      if (tareasSemanales) {
                        return;
                      }
                    },
                    value: widget.checkToMessage(widget.tarea),
                  )
                : ListTile(
                    enabled: [1, 2, 7].contains(_pref.role) && !widget.edit,
                    tileColor: Helper.brandColors[2],
                    contentPadding: EdgeInsets.zero,
                    title: Wrap(children: [
                      Text(
                        '${widget.index + 1} - ${widget.tarea.descripcion}',
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Helper.brandColors[3], fontSize: 15),
                      ),
                      widget.tarea.idUsuario.isNotEmpty
                          ? Text(
                              'Realizado por: ${widget.tarea.nombreUsuario} |',
                              // overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )
                          : Container(),
                      widget.tarea.idUsuario.isNotEmpty
                          ? Text(
                              '${Helper.getFechaHoraFromTS(widget.tarea.tsRealizado)}',
                              // overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )
                          : Container(),
                    ]),
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
        false,
        new Preferences().id,
        0,
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
