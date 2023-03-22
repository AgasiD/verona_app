import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/inactividadBD.dart';
import 'package:verona_app/services/inactividad_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class InactividadesBDForm extends StatelessWidget {
  static final routeName = 'inactividadesBDForm';
  const InactividadesBDForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Helper.brandColors[1],
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: _Form(),
        ),
        bottomNavigationBar: CustomNavigatorFooter());
  }
}

class _Form extends StatefulWidget {
  _Form({Key? key}) : super(key: key);

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  TextEditingController txtCtrlName = new TextEditingController();
  TextEditingController txtCtrlDias = new TextEditingController();
  Preferences _pref = new Preferences();
  String inactividadId = '';
  String textAction = 'Nueva inactividad';
  bool edit = false;
  bool esPrivado = false;

  late InactividadService _inactividadService;
  late String obraId;
  late Function() submitAction;
  late Inactividad inactividad;
  late int index;
  @override
  void initState() {
    super.initState();
    _inactividadService =
        Provider.of<InactividadService>(context, listen: false);
    final _pref = new Preferences();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (arguments.containsKey('id')) {
      //NUEVA INACTIVIDAD
      inactividadId = arguments['id'];
      edit = true;
      textAction = 'Editar inactividad';

      // inactividad = InactividadBD.fromMap(_obraService.obra.diasInactivos[index]);
      txtCtrlName.text = inactividad.nombre;
      // txtCtrlDate.text = inactividad.diasInactivos;

      //Accion al grabar
      submitAction = () async {
        // inactividad.dias = txtCtrlDate.text;
        inactividad.nombre = txtCtrlName.text;
        bool confirm = await openDialogConfirmationReturn(
            context, '¿Seguro que desea actualizar la inactividad?');
        if (!confirm) return;
        openLoadingDialog(context, mensaje: 'Actualizando inactividad...');
        MyResponse response;
        response = await _inactividadService.grabar(inactividad.toMap());
        closeLoadingDialog(context);

        if (response.fallo) {
          openAlertDialog(context, 'No se pudo grabar la inactividad',
              subMensaje: response.error);
        } else {
          await openAlertDialogReturn(context, 'Inactividad actualizada');
          Navigator.pop(context);
        }
      };
      // fin accion al grabar
    } else {
      //NUEVA INACTIVIDAD

      submitAction = () async {
        final confirm = await openDialogConfirmationReturn(
            context, '¿Seguro que desea generar la inactividad?');
        if (!confirm) return;

        openLoadingDialog(context, mensaje: 'Guardando inactividad...');

        final inactividad = new InactividadBD(
            nombre: txtCtrlName.text,
            diasInactivos: int.parse(txtCtrlDias.text),
            fecha: '');
        MyResponse response;
        response = await _inactividadService.grabar(inactividad.toMap());
        closeLoadingDialog(context);

        if (response.fallo) {
          openAlertDialog(context, 'No se pudo grabar la inactividad',
              subMensaje: response.error);
        } else {
          await openAlertDialogReturn(context, 'Inactividad generada');
          Navigator.pop(context, InactividadBD.fromMap(response.data));
        }
      };
    }

    DateTime selectedDate = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(35.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Logo(),
            SizedBox(
              height: 40,
            ),
            Text(
              textAction.toUpperCase(),
              style: TextStyle(
                  foreground: Paint()
                    ..shader = Helper.getGradient(
                        [Helper.brandColors[8], Helper.brandColors[9]]),
                  fontSize: 23),
            ),
            SizedBox(
              height: 40,
            ),
            CustomInput(
                hintText: 'NOMBRE',
                icono: Icons.more_horiz,
                textController: txtCtrlName),
            CustomInput(
                hintText: 'DIAS DE INACTIVIDAD',
                icono: Icons.work_history_sharp,
                teclado: TextInputType.number,
                textController: txtCtrlDias),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: _pref.role == 1 || _pref.role == 2,
                  child: MainButton(
                    color: Helper.brandColors[8],
                    onPressed: submitAction,
                    text: 'Guardar',
                    width: 100,
                  ),
                ),
                SecondaryButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Cancelar',
                    width: 100,
                    color: Helper.brandColors[2]),
              ],
            )
          ],
        ),
      ),
    );
  }
}
