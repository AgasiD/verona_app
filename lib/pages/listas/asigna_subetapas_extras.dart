import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/pages/forms/Etapa_Sub_Tarea.dart';
import 'package:verona_app/services/etapa_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/subetapa_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class SubetapasExtrasPage extends StatelessWidget {
  SubetapasExtrasPage({Key? key}) : super(key: key);
  static final routeName = 'subetapas_extras';
  @override
  Widget build(BuildContext context) {
    final arguements = ModalRoute.of(context)!.settings.arguments as Map;
    final etapaId = arguements['etapaId'];
    final _subetapasService =
        Provider.of<SubetapaService>(context, listen: false);
    final _obraService = Provider.of<ObraService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Subetapas extras'),
        backgroundColor: Helper.brandColors[1],
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
            context, Etapa_Sub_Tarea_Form.routeName,
            arguments: {
              'etapaId': etapaId,
            }),
        backgroundColor: Helper.brandColors[8],
        mini: true,
        child: Icon(Icons.add),
        splashColor: null,
      ),
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
            future: _subetapasService.obtenerExtras(etapaId),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Loading(
                  mensaje: 'Cargando subetapas...',
                );
              } else {
                final response = snapshot.data as MyResponse;
                final lista = response.data as List<dynamic>;
                final subetapas =
                    lista.map((e) => Subetapa.fromJson(e)).toList();
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
                    etapasAsignadas: subetapasAsignadas);
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
    required this.etapaId,
    required this.subetapas,
    required this.etapasAsignadas,
  }) : super(key: key);

  List<Subetapa> subetapas;
  List<String> etapasAsignadas;
  String etapaId;
  @override
  State<_SearchListGroupView> createState() => __SearchListGroupViewState();
}

TextEditingController _txtPersonalCtrl = TextEditingController();

class __SearchListGroupViewState extends State<_SearchListGroupView> {
  List<String> asignados = [];
  @override
  Widget build(BuildContext context) {
    asignados = widget.etapasAsignadas;
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
                                subetapa: widget.subetapas[index],
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
                child: Text('No hay subetapas para agregar',
                    style: TextStyle(fontSize: 20, color: Colors.grey[400]))));
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
      required this.subetapa,
      this.asignado = false})
      : super(key: key);

  final Subetapa subetapa;
  bool asignado;
  String etapaId;

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
          '${widget.subetapa.descripcion}',
          style: TextStyle(color: Helper.brandColors[4]),
        ),
        subtitle: Text('', style: TextStyle(color: Helper.brandColors[3])),
        trailing: icono,
        onTap: () async {
          if (!widget.asignado) {
            // Agregar tarea
            openLoadingDialog(context, mensaje: 'Adjuntando subetapa...');
            final response = await _obraService.asignarSubEtapa(
                widget.etapaId, widget.subetapa.id, _obraService.obra.id);
            if (response.fallo) {
              closeLoadingDialog(context);
              openAlertDialog(context, 'Error al asignar subetapa',
                  subMensaje: response.error);
            } else {
              final indexEtapa = _obraService.obra.etapas
                  .indexWhere((element) => element.id == widget.etapaId);
              _obraService.obra.etapas[indexEtapa]
                  .sumarSubetapa(Subetapa.fromJson(response.data));
              widget.asignado = true;
              closeLoadingDialog(context);
              snackText = 'Subetapa asignada';
              Helper.showSnackBar(
                  context, snackText, null, Duration(milliseconds: 700), null);
            }
          } else {
            //Quitar tarea
            openLoadingDialog(context, mensaje: 'Quitando etapa...');

            final response = await _obraService.quitarSubetapa(
                widget.etapaId, widget.subetapa.id, _obraService.obra.id);

            if (response.fallo) {
              closeLoadingDialog(context);
              openAlertDialog(context, 'Error al quitar etapa',
                  subMensaje: response.error);
            } else {
              final indexEtapa = _obraService.obra.etapas
                  .indexWhere((element) => element.id == widget.etapaId);
              _obraService.obra.etapas[indexEtapa]
                  .quitarSubEtapa(widget.subetapa.id);
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
