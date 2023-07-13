import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class InactividadesForm extends StatelessWidget {
  static final routeName = 'inactividadesForm';
  const InactividadesForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Helper.brandColors[1],
      body: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child:_Form(),
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
  TextEditingController txtCtrlFile = new TextEditingController();
  TextEditingController txtCtrlDate = new TextEditingController();
  DateTime now = DateTime.now();
  Preferences _pref = new Preferences();
  String inactividadId = '';
  String textAction = 'Nueva inactividad';
  bool edit = false;
  bool esPrivado = false;

  late ObraService _obraService;
  late String obraId;
  late Function() submitAction;
  late Inactividad inactividad;
  late int index;
  @override
  void initState() {
    super.initState();
    _obraService = Provider.of<ObraService>(context, listen: false);
    final _pref = new Preferences();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    obraId = arguments['obraId'];
    if (arguments.containsKey('id')) {
      //Edita INACTIVIDAD
      inactividadId = arguments['id'];
      edit = true;
      textAction = 'Editar inactividad';
      index = _obraService.obra.diasInactivos
          .indexWhere((element) => element["id"] == inactividadId);
      inactividad = Inactividad.fromMap(_obraService.obra.diasInactivos[index]);
      txtCtrlName.text = inactividad.nombre;
      txtCtrlFile.text = inactividad.fileName;
      txtCtrlDate.text = inactividad.fecha;

      //Accion al grabar
      submitAction = () async {
        late bool loading ;
        try{
        inactividad.fecha = txtCtrlDate.text;
        inactividad.nombre = txtCtrlName.text;
        bool confirm = await openDialogConfirmationReturn(context, '¿Seguro que desea actualizar la inactividad?');
        if(!confirm) return;
        openLoadingDialog(context, mensaje: 'Actualizando inactividad...');
        loading = true;
          MyResponse response;
          response = await _obraService.editInactividad(obraId, inactividad);
          closeLoadingDialog(context);
        loading = false;
          if (response.fallo) {
            openAlertDialog(context, 'No se pudo grabar la inactividad',
                subMensaje: response.error);
          } else {
            _obraService.obra.diasInactivos[index] = inactividad.toMap();
           await openAlertDialogReturn(context, 'Inactividad actualizada');
           Navigator.pop(context);
          }
        }catch ( err ){
          loading ? closeLoadingDialog(context) : false;
          openAlertDialog(context, 'Error al grabar inactividad', subMensaje: err.toString());
        }
      };
      // fin accion al grabar
    } else {
      //NUEVA INACTIVIDAD
      late bool loading;
      try{

     String formattedDate = DateFormat('dd/MM/yyyy').format(now);
      txtCtrlDate.text = formattedDate.toString();
      submitAction = () async {
        openDialogConfirmation(context, (context) async {
          openLoadingDialog(context, mensaje: 'Guardando inactividad...');
          loading = true;

          final inactividad = new Inactividad(
              nombre: txtCtrlName.text,
              fecha: txtCtrlDate.text,
              fileName: txtCtrlFile.text,
              usuarioId: _pref.id,
              privado: esPrivado);
          MyResponse response;
          response = await _obraService.nuevaInactividad(obraId, inactividad);
          closeLoadingDialog(context);
            loading = false;
          if (response.fallo) {
            openAlertDialog(context, 'No se pudo grabar la inactividad',
                subMensaje: response.error);
          } else {
            openAlertDialog(context, 'Inactividad generada');
          }
        }, '¿Seguro que desea generar la inactividad?');
      }; }catch ( err ){
          loading ? closeLoadingDialog(context) : false;
          openAlertDialog(context, 'Error al grabar inactividad', subMensaje: err.toString());
        }
    }

    DateTime selectedDate = DateTime.now();

    return  Padding(
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
                CustomFormInput(
                  // enable: edit,
                  hintText: ('Fecha').toUpperCase(),
                  icono: Icons.abc,
                  textController: txtCtrlDate,
                  iconButton: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        selectDate(
                          context,
                          txtCtrlDate,
                          selectedDate,
                        );
                      }),
                ),
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
 void selectDate(context, txtCtrlDate, selectedDate) async {
    double width = MediaQuery.of(context).size.width * .8;
    double height = MediaQuery.of(context).size.height * .5;

    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        selectedDayHighlightColor: Helper.brandColors[8],
        calendarType: CalendarDatePicker2Type.single,
        closeDialogOnCancelTapped: true,
        
      ),
      dialogSize: Size(width, height),
      initialValue: [selectedDate],
      borderRadius: BorderRadius.circular(5),
    );

    if (results != null) {
      final date = results![0];
      String formattedDate = DateFormat('dd/MM/yyyy').format(date!);

      txtCtrlDate.text = formattedDate.toString();
      selectedDate = date;
    }

  }
}


