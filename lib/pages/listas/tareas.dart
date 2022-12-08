import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/pages/listas/asigna_tareas_extras.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class TareasCheckList extends StatelessWidget {
  TareasCheckList({Key? key}) : super(key: key);
  static final routeName = 'TareasChecList';

  List<Tarea> tareas = [];

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;

    final subetapaId = arguments['subetapaId'];
    final etapaId = arguments['etapaId'];

    final _obraService = Provider.of<ObraService>(context);
    tareas = _obraService.obra.etapas
        .singleWhere((etapa) => etapa.id == etapaId)
        .subetapas
        .singleWhere((subetapa) => subetapa.id == subetapaId)
        .tareas;

    // tareas = [new Tarea(descripcion: '12332', etapa: '111', isDefault: false)];

    return Scaffold(
      backgroundColor: Helper.brandColors[1],
      body: SingleChildScrollView(
          child: Container(
        height: MediaQuery.of(context).size.height - 100,
        child: ListView.builder(
          itemCount: tareas.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              child: GestureDetector(
                onLongPress: () {
                  openAlertDialog(context, 'Descripción',
                      subMensaje: tareas[index].descripcion);
                },
                child: _TareaTile(
                  tarea: tareas[index],
                  index: index,
                ),
              ),
            );
          },
        ),
      )),
      bottomNavigationBar: CustomNavigatorFooter(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
            context, TareasExtrasPage.routeName,
            arguments: {'etapaId': etapaId}),
        backgroundColor: Helper.brandColors[8],
        mini: true,
        child: Icon(Icons.add),
        splashColor: null,
      ),
    );
  }
}

class _TareaTile extends StatefulWidget {
  _TareaTile({Key? key, required this.tarea, required this.index})
      : super(key: key);

  Tarea tarea;
  int index;

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

    return CheckboxListTile(
      tileColor: Helper.brandColors[2],
      checkColor: Helper.brandColors[5],
      activeColor: Helper.brandColors[8],
      title: Text(
        '${widget.index + 1} - ${widget.tarea.descripcion}',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Helper.brandColors[3]),
      ),
      onChanged: (value) async {
        openLoadingDialog(context, mensaje: 'Actualizando...');
        // final response = await _obraService.actualizarTarea(
        //     _obraService.obra.id,
        //     widget.tarea.subetapa,
        //     widget.tarea.id,
        //     value!,
        //     new Preferences().id,
        //     DateTime.now().millisecondsSinceEpoch);
        closeLoadingDialog(context);
        widget.tarea.realizado = value!;
        _obraService.notifyListeners();

        // if (response.fallo) {
        //   openAlertDialog(context, 'Error al actualizar tarea',
        //       subMensaje: response.error);
        // }

        setState(() {});
      },
      value: widget.tarea.realizado,
    );
  }
}
