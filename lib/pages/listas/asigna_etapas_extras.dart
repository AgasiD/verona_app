import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/pages/forms/Etapa_Sub_Tarea.dart';
import 'package:verona_app/services/etapa_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class EtapasExtrasPage extends StatelessWidget {
  EtapasExtrasPage({Key? key}) : super(key: key);
  static final routeName = 'etapas_extras';
  @override
  Widget build(BuildContext context) {
    final _etapasService = Provider.of<EtapaService>(context, listen: false);
    final _obraService = Provider.of<ObraService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Etapas extras'),
        backgroundColor: Helper.brandColors[1],
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
            context, Etapa_Sub_Tarea_Form.routeName,
            arguments: {}),
        backgroundColor: Helper.brandColors[8],
        mini: true,
        child: Icon(Icons.add),
        splashColor: null,
      ),
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
            future: _etapasService.obtenerEtapasExtras(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Loading(
                  mensaje: 'Cargando etapas...',
                );
              } else {
                final response = snapshot.data as MyResponse;
                final lista = response.data as List<dynamic>;
                final etapas = lista.map((e) => Etapa.fromJson(e)).toList();
                final etapasAsignadas =
                    _obraService.obra.etapas.map((etapa) => etapa.id).toList();

                return _SearchListGroupView(
                    etapas: etapas, etapasAsignadas: etapasAsignadas);
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
    required this.etapas,
    required this.etapasAsignadas,
  }) : super(key: key);

  List<Etapa> etapas;
  List<String> etapasAsignadas;
  @override
  State<_SearchListGroupView> createState() => __SearchListGroupViewState();
}

TextEditingController _txtPersonalCtrl = TextEditingController();

class __SearchListGroupViewState extends State<_SearchListGroupView> {
  List<String> asignados = [];
  @override
  Widget build(BuildContext context) {
    asignados = widget.etapasAsignadas;
    return widget.etapas.length > 0
        ? Container(
            child: SingleChildScrollView(
                child: Container(
              child: Column(children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        itemCount: widget.etapas.length,
                        itemBuilder: (context, index) {
                          final asignado =
                              asignados.contains(widget.etapas[index].id);
                          return Container(
                            child: Column(children: [
                              _CustomAddListTile(
                                etapa: widget.etapas[index],
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
                child: Text('No hay etapas para agregar',
                    style: TextStyle(fontSize: 20, color: Colors.grey[400]))));
  }

  @override
  void dispose() {
    _txtPersonalCtrl.text = '';
    super.dispose();
  }
}

class _CustomAddListTile extends StatefulWidget {
  _CustomAddListTile({Key? key, required this.etapa, this.asignado = false})
      : super(key: key);

  final Etapa etapa;
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
          '${widget.etapa.descripcion}',
          style: TextStyle(color: Helper.brandColors[4]),
        ),
        subtitle: Text('', style: TextStyle(color: Helper.brandColors[3])),
        trailing: icono,
        onTap: () async {
          if (!widget.asignado) {
            // Agregar tarea
            openLoadingDialog(context, mensaje: 'Adjuntando etapa...');
            final response = await _obraService.asignarEtapa(
                widget.etapa.id, _obraService.obra.id);
            if (response.fallo) {
              closeLoadingDialog(context);
              openAlertDialog(context, 'Error al asignar etapa',
                  subMensaje: response.error);
            } else {
              _obraService.obra.sumarEtapa(Etapa.fromJson(response.data));
              widget.asignado = true;
              closeLoadingDialog(context);
              snackText = 'Tarea asignada';
              Helper.showSnackBar(
                  context, snackText, null, Duration(milliseconds: 700), null);
            }
          } else {
            //Quitar tarea
            openLoadingDialog(context, mensaje: 'Quitando etapa...');

            final response = await _obraService.quitarEtapa(
                widget.etapa.id, _obraService.obra.id);

            if (response.fallo) {
              closeLoadingDialog(context);
              openAlertDialog(context, 'Error al quitar etapa',
                  subMensaje: response.error);
            } else {
              _obraService.obra.quitarEtapa(widget.etapa.id);
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
