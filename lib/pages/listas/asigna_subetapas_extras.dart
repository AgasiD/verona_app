import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';

import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/pages/error.dart';
import 'package:verona_app/pages/forms/Etapa_Sub_Tarea.dart';
import 'package:verona_app/services/etapa_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/subetapa_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class SubetapasExtrasPage extends StatelessWidget {
  SubetapasExtrasPage({Key? key}) : super(key: key);
  static final routeName = 'subetapas_extras';
  late List<Subetapa> subetapas;
  int ordenSug = 1;
  @override
  Widget build(BuildContext context) {
    final arguements = ModalRoute.of(context)!.settings.arguments as Map;
    final etapaId = arguements['etapaId'];
    final _subetapasService = Provider.of<SubetapaService>(context);
    final _obraService = Provider.of<ObraService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Subetapas extras'),
        backgroundColor: Helper.brandColors[1],
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
            context, Etapa_Sub_Tarea_Form.routeName,
            arguments: {'etapaId': etapaId, 'ordenSug': ordenSug}),
        backgroundColor: Helper.brandColors[8],
        mini: true,
        child: Icon(Icons.add),
        splashColor: null,
      ),
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
            future:
                _subetapasService.obtenerExtras(etapaId, _obraService.obra.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Loading(
                  mensaje: 'Recuperando subetapas...',
                );
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasError) {
                return ErrorPage(
                  errorMsg: snapshot.error.toString(),
                );
              }
              final lista = snapshot.data as List<dynamic>;
              subetapas = lista.map((e) => Subetapa.fromJson(e)).toList();
              subetapas
                  .sort(((a, b) => a.descripcion.compareTo(b.descripcion)));
              ordenSug = subetapas.length;
              final indexEtapa = _obraService.obra.etapas
                  .indexWhere((element) => element.id == etapaId);
              _obraService.obra.etapas[indexEtapa];
              final subetapasAsignadas = _obraService
                  .obra.etapas[indexEtapa].subetapas
                  .map((etapa) => etapa.id)
                  .toList();

              return _SearchListGroupView(
                  etapaId: etapaId,
                  subetapas: subetapas,
                  subetapasAsignadas: subetapasAsignadas);
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
    required this.etapaId,
    required this.subetapas,
    required this.subetapasAsignadas,
  }) : super(key: key);

  List<Subetapa> subetapas;
  List<String> subetapasAsignadas;
  String etapaId;
  @override
  State<_SearchListGroupView> createState() => __SearchListGroupViewState();
}

TextEditingController _txtPersonalCtrl = TextEditingController();

class __SearchListGroupViewState extends State<_SearchListGroupView> {
  List<String> asignados = [];
  late ObraService _obraService;
  @override
  Widget build(BuildContext context) {
    _obraService = Provider.of<ObraService>(context);
    asignados = widget.subetapasAsignadas;
    return widget.subetapas.length > 0
        ? Container(
            child: SingleChildScrollView(
                child: Container(
              child: Column(children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        itemCount: widget.subetapas.length,
                        itemBuilder: (context, index) {
                          final asignado =
                              asignados.contains(widget.subetapas[index].id);
                          return Container(
                            child: Column(children: [
                              _CustomAddListTile(
                                etapaId: widget.etapaId,
                                subetapas: widget.subetapas,
                                index: index,
                                asignado: asignado,
                                eliminarSubetapa:
                                    (obraId, etapaId, subetapaId, index) =>
                                        eliminarSubetapa(
                                            obraId, etapaId, subetapaId, index),
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
                child: Text('No hay subetapas para agregar',
                    style: TextStyle(fontSize: 20, color: Colors.grey[400]))));
  }

  eliminarSubetapa(obraId, etapaId, subetapaId, index) async {
    final _subetapasService =
        Provider.of<SubetapaService>(context, listen: false);
    openLoadingDialog(mensaje: 'Eliminando subetapa...');
    final subetapa = widget.subetapas[index];
    try {
      final response = await _subetapasService.eliminarSubetapa(subetapaId);
      widget.subetapas.removeAt(index);
      closeLoadingDialog();

      setState(() {});
    } catch (err) {
      closeLoadingDialog();

      openAlertDialog('Error al eliminar subetapa', subMensaje: err.toString());
    }
  }

  @override
  void dispose() {
    _txtPersonalCtrl.text = '';
    super.dispose();
  }
}

class _CustomAddListTile extends StatefulWidget {
  _CustomAddListTile(
      {Key? key,
      required this.etapaId,
      required this.subetapas,
      required this.index,
      required this.eliminarSubetapa,
      this.asignado = false})
      : super(key: key);

  List<Subetapa> subetapas;
  bool asignado;
  int index;
  String etapaId;
  Function eliminarSubetapa;

  @override
  State<_CustomAddListTile> createState() => _CustomAddListTileState();
}

class _CustomAddListTileState extends State<_CustomAddListTile> {
  late ObraService _obraService;
  late Subetapa subetapa;

  @override
  Widget build(BuildContext context) {
    _obraService = Provider.of<ObraService>(context);
    final _pref = new Preferences();
    subetapa = widget.subetapas[widget.index];
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

    var tile = ListTile(
        title: Text(
          '${subetapa.descripcion}',
          style: TextStyle(color: Helper.brandColors[4]),
        ),
        trailing: icono,
        onTap: () => asignar(snackText));

    return Dismissible(
        confirmDismiss: (direction) {
          return openDialogConfirmationReturn('Confirme para borrar',
              subMensaje: 'Se borrará permanentemente de la base de datos');
        },
        background: Container(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Eliminar',
                  style: TextStyle(color: Helper.brandColors[5]),
                )),
            color: Colors.red[400]),
        onDismissed: (direction) async {
          await widget.eliminarSubetapa(
              _obraService.obra.id, widget.etapaId, subetapa.id, widget.index);
        },
        key: Key(subetapa.id),
        child: tile);
  }

  asignar(snackText) async {
    if (!widget.asignado) {
      // Agregar tarea
      openLoadingDialog(mensaje: 'Adjuntando subetapa...');
      try {
        final response = await _obraService.asignarSubEtapa(
            widget.etapaId, subetapa.id, _obraService.obra.id);

        final indexEtapa = _obraService.obra.etapas
            .indexWhere((element) => element.id == widget.etapaId);
        _obraService.obra.etapas[indexEtapa]
            .sumarSubetapa(Subetapa.fromJson(response.data));
        widget.asignado = true;
        closeLoadingDialog();
        snackText = 'Subetapa asignada';
        Helper.showSnackBar(
            context, snackText, null, Duration(milliseconds: 700), null);

        return;
      } catch (err) {
        closeLoadingDialog();
        openAlertDialog('Error al asignar subetapa', subMensaje: err.toString());
      }
    }
    //Quitar tarea
    openLoadingDialog(mensaje: 'Quitando etapa...');

    try {
      final response = await _obraService.quitarSubetapa(
          widget.etapaId, subetapa.id, _obraService.obra.id);

      final indexEtapa = _obraService.obra.etapas
          .indexWhere((element) => element.id == widget.etapaId);
      _obraService.obra.etapas[indexEtapa].quitarSubEtapa(subetapa.id);
      widget.asignado = false;
      closeLoadingDialog();
      Helper.showSnackBar(
          context, snackText, null, Duration(milliseconds: 700), null);
    } catch (err) {
      closeLoadingDialog();
      openAlertDialog('Error al quitar etapa', subMensaje: err.toString());
    }

    // setState(() {});
  }

  tareaAsingada(String id) {
    return false;
  }
}
