import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/services/etapa_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/subetapa_service.dart';
import 'package:verona_app/services/tarea_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class Etapa_Sub_Tarea_Form extends StatelessWidget {
  Etapa_Sub_Tarea_Form({Key? key}) : super(key: key);
  static final routeName = 'tarea_form';

  bool proximos = false;
  bool isDefault = false;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    bool sinObra = arguments['sinObra'] ?? false;
    String? etapaId = arguments['etapaId'];
    String? subetapaId = arguments['subetapaId'];
    int ordenSug = arguments['ordenSug'] ?? 0;
    return GestureDetector(
      onTap: () => Helper.requestFocus(context),
      child: Scaffold(
        bottomNavigationBar: CustomNavigatorFooter(),
        backgroundColor: Helper.brandColors[1],
        body: _Form(
          etapaId: etapaId,
          subetapaId: subetapaId,
          sinObra: sinObra,
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  _Form({
    Key? key,
    this.sinObra = false,
    this.subetapaId = null,
    this.etapaId = null,
  }) : super(key: key);

  String? etapaId;
  String? subetapaId;
  bool sinObra = false;
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  TextEditingController txtTarea = TextEditingController();
  TextEditingController txtOrden = TextEditingController();

  late bool proximos;
  late bool isDefault;

  @override
  void initState() {
    super.initState();
    proximos = false;
    isDefault = false;
  }

  String tipo = 'Tarea';
  bool esSubEtapa = false;
  bool esEtapa = false;

  @override
  Widget build(BuildContext context) {
    if (widget.subetapaId == null) {
      esSubEtapa = true;
      tipo = 'Subetapa';
      if (widget.etapaId == null) {
        esEtapa = true;
        esSubEtapa = false;
        tipo = 'Etapa';
      }
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 38.0),
            child: Text(
              'Nueva ${tipo}'.toUpperCase(),
              style: TextStyle(color: Helper.brandColors[8], fontSize: 30),
            ),
          ),
          CustomInput(
              hintText: 'Descripción',
              icono: Icons.description,
              textController: txtTarea),
              CustomInput(
              hintText: 'Orden/posición',
              icono: Icons.sort,
              textController: txtOrden,
              teclado: TextInputType.number,
              ),
          Visibility(
              visible: !widget.sinObra,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Guardar para próximos proyectos',
                    style:
                        TextStyle(color: Helper.brandColors[8], fontSize: 16),
                  ),
                  Switch(
                      value: proximos,
                      activeColor: Helper.brandColors[3],
                      activeTrackColor: Helper.brandColors[8],
                      inactiveTrackColor: Helper.brandColors[3],
                      onChanged: (value) {
                        proximos = value;
                        !proximos ? isDefault = false : false;
                        setState(() {});
                      }),
                ],
              )),
          Visibility(
            visible: proximos,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Es default para proyectos futuros',
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Helper.brandColors[8],
                      fontSize: 16),
                ),
                Switch(
                    value: isDefault,
                    activeColor: Helper.brandColors[3],
                    activeTrackColor: Helper.brandColors[8],
                    inactiveTrackColor: Helper.brandColors[3],
                    onChanged: (value) {
                      isDefault = value;

                      setState(() {});
                    }),
              ],
            ),
          ),
          Expanded(
              child: Container(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SecondaryButton(
                  onPressed: () => Navigator.pop(context, null),
                  text: 'Cancelar',
                  color: Helper.brandColors[3],
                  width: 120,
                ),
                MainButton(
                  onPressed: () => grabar(),
                  text: 'Grabar',
                  width: 120.0,
                  color: Helper.brandColors[8],
                )
              ],
            ),
          ))
        ]),
      ),
    );
  }

  grabar() {
    if (txtTarea.text.trim().isEmpty) {
      openAlertDialog(context, 'Falta descripción');
      return;
    }

    openDialogConfirmation(context, (context) => grabarElemento(context),
        'Confirmar para grabar $tipo');
  }

  grabarElemento(context) async {
    final toReturn;
    final loading = true;
    openLoadingDialog(context, mensaje: 'Grabando $tipo');
    final _obraService = Provider.of<ObraService>(context, listen: false);
    try {
      final data = {
        "descripcion": txtTarea.text.trim(),
        "isDefault": isDefault,
        "proximos": proximos,
        "obraId": _obraService.obra.id,
        "orden": txtOrden.text,
      };
      if (esEtapa) {
        // ETAPA
        final _service = Provider.of<EtapaService>(context, listen: false);
        final datos = await _service.grabar(data);
        closeLoadingDialog(context);

        if (datos.fallo) {
          openAlertDialog(context, 'Error al grabar $tipo',
              subMensaje: datos.error);
          return;
        }
        final etapa = Etapa.fromJson(datos.data);
        toReturn = etapa;
        _obraService.obra.etapas.add(etapa);
        _obraService.notifyListeners();
      } else if (esSubEtapa) {
        // SUBETAPA
        data.addAll({"etapaId": widget.etapaId!});
        final _service = Provider.of<SubetapaService>(context, listen: false);
        final datos = await _service.grabar(data);
        closeLoadingDialog(context);

        if (datos.fallo) {
          openAlertDialog(context, 'Error al grabar $tipo',
              subMensaje: datos.error);
          return;
        }
        final subetapa = Subetapa.fromJson(datos.data);
        toReturn = subetapa;

        _obraService.obra.etapas
            .singleWhere((etapa) => etapa.id == widget.etapaId)
            .subetapas
            .insert(subetapa.orden-1, subetapa);
        _obraService.notifyListeners();
      } else {
        // TAREA
        data.addAll({"etapaId": widget.etapaId!});
        data.addAll({"subetapaId": widget.subetapaId!});

        final _service = Provider.of<TareaService>(context, listen: false);
        final datos = await _service.grabar(data);
        closeLoadingDialog(context);

        if (datos.fallo) {
          openAlertDialog(context, 'Error al grabar $tipo',
              subMensaje: datos.error);
          return;
        }
        final tarea = Tarea.fromJson(datos.data);
        toReturn = tarea;
        _obraService.obra.etapas
            .singleWhere((etapa) => etapa.id == widget.etapaId)
            .subetapas
            .singleWhere((subetapa) => subetapa.id == widget.subetapaId)
            .tareas
            .add(tarea);
        _obraService.notifyListeners();
      }
      Navigator.pop(context, toReturn);
    } catch (err) {
      loading ? closeLoadingDialog(context) : false;
      openAlertDialog(
        context,
        'Error al grabar $tipo',
      );
    }
  }
}
