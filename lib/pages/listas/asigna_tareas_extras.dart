import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/tarea_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class TareasExtrasPage extends StatelessWidget {
  TareasExtrasPage({Key? key}) : super(key: key);
  static final routeName = 'tareas_extras';
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final etapaId = arguments['etapaId'];
    final _tareaService = Provider.of<TareaService>(context, listen: false);
    final _obraService = Provider.of<ObraService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas extras'),
        backgroundColor: Helper.brandColors[1],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
            future: _tareaService.obtenerTareasExtras(etapaId),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Loading(
                  mensaje: 'Cargando tareas...',
                );
              } else {
                final response = snapshot.data as MyResponse;
                final lista = response.data as List<dynamic>;
                final tareas = lista.map((e) => Tarea.fromJson(e)).toList();
                final index = _obraService.obra.etapas
                    .indexWhere((etapa) => etapa.id == etapaId);
                final tareasAsignadas = _obraService.obra.etapas[index].tareas;

                return _SearchListGroupView(
                    tareas: tareas, tareasAsignadas: tareasAsignadas);
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _SearchListGroupView extends StatefulWidget {
  _SearchListGroupView({
    Key? key,
    required this.tareas,
    required this.tareasAsignadas,
  }) : super(key: key);

  List<Tarea> tareas;
  List<Tarea> tareasAsignadas;
  @override
  State<_SearchListGroupView> createState() => __SearchListGroupViewState();
}

TextEditingController _txtPersonalCtrl = TextEditingController();

class __SearchListGroupViewState extends State<_SearchListGroupView> {
  List<String> asignados = [];
  @override
  Widget build(BuildContext context) {
    asignados = widget.tareasAsignadas.map((e) => e.id).toList();
    return widget.tareas.length > 0
        ? Container(
            child: SingleChildScrollView(
                child: Container(
              child: Column(children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        itemCount: widget.tareas.length,
                        itemBuilder: (context, index) {
                          final asignado =
                              asignados.contains(widget.tareas[index].id);
                          return Container(
                            child: Column(children: [
                              _CustomAddListTile(
                                tarea: widget.tareas[index],
                                asignado: asignado,
                              ),
                              Divider(
                                color: Helper.brandColors[3],
                                height: 4,
                              ),
                            ]),
                          );
                        })),
              ]),
            )),
          )
        : SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: Text('No hay tareas para agregar',
                    style: TextStyle(fontSize: 20, color: Colors.grey[400]))));
  }

  @override
  void dispose() {
    _txtPersonalCtrl.text = '';
    super.dispose();
  }
}

class _CustomAddListTile extends StatefulWidget {
  _CustomAddListTile({Key? key, required this.tarea, this.asignado = false})
      : super(key: key);

  final Tarea tarea;
  bool asignado;

  @override
  State<_CustomAddListTile> createState() => _CustomAddListTileState();
}

class _CustomAddListTileState extends State<_CustomAddListTile> {
  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);

    String snackText = 'Se ha quitado la tarea';
    Icon icono = widget.asignado
        ? Icon(
            Icons.check,
            color: Colors.green.shade300,
          )
        : Icon(
            Icons.add,
            color: Helper.brandColors[3],
          );
    return ListTile(
        title: Text(
          '${widget.tarea.descripcion}',
          style: TextStyle(color: Helper.brandColors[4]),
        ),
        subtitle: Text('', style: TextStyle(color: Helper.brandColors[3])),
        trailing: icono,
        onTap: () async {
          if (!widget.asignado) {
            // Agregar tarea
            openLoadingDialog(context, mensaje: 'Adjuntando tarea...');
            final response = await _obraService.asignarTarea(
                widget.tarea.etapa, widget.tarea.id, _obraService.obra.id);
            if (response.fallo) {
              closeLoadingDialog(context);
              openAlertDialog(context, 'Error al asignar tarea',
                  subMensaje: response.error);
            } else {
              _obraService.obra.sumarTarea(widget.tarea.etapa, widget.tarea);
              widget.asignado = true;
              closeLoadingDialog(context);
              snackText = 'Tarea asignada';
              Helper.showSnackBar(
                  context, snackText, null, Duration(milliseconds: 700), null);
            }
          } else {
            //Quitar tarea
            openLoadingDialog(context, mensaje: 'Quitando tarea...');

            final response = await _obraService.quitarTarea(
                widget.tarea.etapa, widget.tarea.id, _obraService.obra.id);

            if (response.fallo) {
              closeLoadingDialog(context);
              openAlertDialog(context, 'Error al quitar tarea',
                  subMensaje: response.error);
            } else {
              _obraService.obra.quitarTarea(widget.tarea.etapa, widget.tarea);
              widget.asignado = false;
              closeLoadingDialog(context);
              Helper.showSnackBar(
                  context, snackText, null, Duration(milliseconds: 700), null);
            }
          }

          setState(
            () {},
          );
        });
  }

  tareaAsingada(String id) {
    return false;
  }
}
