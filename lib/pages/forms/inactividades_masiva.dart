import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multiselect/multiselect.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/inactividadBD.dart';
import 'package:verona_app/services/inactividad_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class InactividadesMasivaForm extends StatelessWidget {
  static final routeName = 'InactividadesMasivaForm';
  const InactividadesMasivaForm({Key? key}) : super(key: key);

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
  String textAction = 'Nueva inactividad masiva';
  bool edit = false;
  bool esPrivado = false;

  late InactividadService _inactividadService;
  late ObraService _obraService;
  late String obraId;
  late Function(List<String>, String, String) submitAction;
  late Inactividad inactividad;
  late String selectedInactividad;
  late int index;

  @override
  void initState() {
    super.initState();
    _inactividadService =
        Provider.of<InactividadService>(context, listen: false);
    final _pref = new Preferences();
  }

  late List<InactividadBD> inactividades;

  @override
  Widget build(BuildContext context) {


    
    //NUEVA INACTIVIDAD
    _obraService = Provider.of<ObraService>(context);
    Color colorHint = Helper.brandColors[3];
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    final obras = arg['obras'];

    submitAction = (idsObras, idInactividad, selectedFecha) async {
      final confirm = await openDialogConfirmationReturn(
          context, '¿Seguro que desea generar la inactividad?');

      if (!confirm) return;

      openLoadingDialog(context,
          mensaje: 'Guardando inactividad... Esta acción puede demorar');

      final inactividad = new Inactividad(
        nombre: idInactividad == '0000000'
            ? txtCtrlName.text
            : inactividades.firstWhere((i) => i.id == idInactividad).nombre,
        diasInactivos: int.parse(txtCtrlDias.text),
        fecha: selectedFecha,
        usuarioId: _pref.id,
      );

      MyResponse response;
      response =
          await _obraService.grabarInactividades(idsObras, inactividad.toMap());
      closeLoadingDialog(context);

      if (response.fallo) {
        openAlertDialog(context, 'No se pudo grabar la inactividad',
            subMensaje: response.error);
      } else {
        await openAlertDialogReturn(context, 'Inactividad generada');
        Navigator.pop(context, true);
      }
    };

    DateTime selectedDate = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(35.0),
      child: FutureBuilder(
        future: _inactividadService.obtenerInactividades(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Loading(
              mensaje: "Obteniendo información...",
            );

          final response = snapshot.data as MyResponse;
          if (response.fallo)
            return Center(
              child: Text(response.error),
            );

          inactividades = (response.data as List)
              .map((i) => InactividadBD.fromMap(i))
              .toList();
          inactividades.add(new InactividadBD(
              nombre: 'Otro', diasInactivos: 1, id: '0000000'));

          final inactividadesItems = inactividades
              .map((i) => DropdownMenuItem(value: i.id, child: Text(i.nombre)))
              .toList();

          setInactividad(inactividades.first.id);

          return SingleChildScrollView(
            child: _Formulario(
                textAction: textAction,
                selectedInactividad: selectedInactividad,
                inactividadesItems: inactividadesItems,
                colorHint: colorHint,
                txtCtrlName: txtCtrlName,
                txtCtrlDias: txtCtrlDias,
                pref: _pref,
                submitAction: submitAction,
                inactividades: inactividades,
                obras: obras),
          );
        },
      ),
    );
  }

  void setInactividad(String idInatividad) {
    final inactividad = inactividades.firstWhere((i) => i.id == idInatividad);
    selectedInactividad = idInatividad;
    txtCtrlDias.text = inactividad.diasInactivos.toString();
  }
}

class _Formulario extends StatefulWidget {
  _Formulario({
    Key? key,
    required this.inactividades,
    required this.textAction,
    required this.selectedInactividad,
    required this.inactividadesItems,
    required this.colorHint,
    required this.txtCtrlName,
    required this.txtCtrlDias,
    required Preferences pref,
    required this.submitAction,
    required this.obras,
  })  : _pref = pref,
        super(key: key);

  final String textAction;
  String selectedInactividad;
  final List<DropdownMenuItem<String>> inactividadesItems;
  final List<InactividadBD> inactividades;
  final Color colorHint;
  final TextEditingController txtCtrlName;
  final TextEditingController txtCtrlDias;
  final Preferences _pref;
  final Function(List<String>, String, String) submitAction;
  final List<Map<String, dynamic>> obras;
  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  List<String> selected = [];
  List<String> values = ['a'];
  TextEditingController txtCtrlDate = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    values = widget.obras.map((e) => e['nombre'] as String).toList();
    selected = widget.obras.map((e) => e['nombre'] as String).toList();
    ;
     DateTime now = DateTime.now();

    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    txtCtrlDate.text = formattedDate.toString();
  }
DateTime selectedDate = DateTime.now();
  

  @override
  Widget build(BuildContext context) {
   
    return Column(
      children: [
        Logo(),
        SizedBox(
          height: 40,
        ),
        Text(
          widget.textAction.toUpperCase(),
          style: TextStyle(
              foreground: Paint()
                ..shader = Helper.getGradient(
                    [Helper.brandColors[8], Helper.brandColors[9]]),
              fontSize: 23),
        ),
        SizedBox(
          height: 40,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 15),
          child: Theme(
              data: Theme.of(context)
                  .copyWith(disabledColor: Helper.brandColors[3]),
              child: DropdownButtonFormField2(
                  value: widget.selectedInactividad,
                  items: widget.inactividadesItems,
                  style: TextStyle(color: Helper.brandColors[5], fontSize: 16),
                  iconSize: 30,
                  buttonHeight: 60,
                  buttonPadding: EdgeInsets.only(left: 20, right: 10),
                  decoration: getDecoration(),
                  hint: Text(
                    'Seleccione inactividad',
                    style: TextStyle(fontSize: 16, color: widget.colorHint),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: widget.colorHint,
                  ),
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Helper.brandColors[2],
                  ),
                  onChanged: (value) {
                    setState(() {
                      setInactividad(value as String);
                    });
                  })),
        ),
        Visibility(
          visible: widget.selectedInactividad == '0000000',
          child: CustomInput(
              hintText: 'NOMBRE',
              icono: Icons.more_horiz,
              textController: widget.txtCtrlName),
        ),
        CustomInput(
            hintText: 'DIAS DE INACTIVIDAD',
            icono: Icons.work_history_sharp,
            teclado: TextInputType.number,
            readOnly: widget.selectedInactividad != '0000000',
            textController: widget.txtCtrlDias),
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
        DropDownMultiSelect(
          
          decoration: getDecoration(),
          childBuilder: (option) => Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Obras seleccionadas: ${selected.length}/${values.length}',
                textAlign: TextAlign.right,
                style: TextStyle(color: Helper.brandColors[5], fontSize: 17),
              )),
          selected_values_style: TextStyle(color: Colors.white),
          options: values,
          selectedValues: selected,
          whenEmpty: 'Sin obras seleccionadas',
          icon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_drop_down_outlined,
              size: 35,
              color: Helper.brandColors[3],
            ),
          ),
          onChanged: (List<String> x) {
            setState(() {
              selected = x;
            });
          },
        ),
        SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: widget._pref.role == 1 || widget._pref.role == 2,
              child: MainButton(
                color: Helper.brandColors[8],
                onPressed: () {
                  widget.submitAction(
                      convertNombreToId(selected), widget.selectedInactividad, txtCtrlDate.text);
                },
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

  void setInactividad(String idInatividad) {
    final inactividad =
        widget.inactividades.firstWhere((i) => i.id == idInatividad);
    widget.selectedInactividad = idInatividad;
    widget.txtCtrlDias.text = inactividad.diasInactivos.toString();
  }

  List<String> convertNombreToId(List<String> selecciondas) {
    final data = widget.obras
        .where((obra) => selecciondas.contains(obra['nombre']))
        .map((e) => e['id'] as String)
        .toList();
    return data;
  }
}

getDecoration() {
  return InputDecoration(
      focusColor: Helper.brandColors[9],
      contentPadding: EdgeInsets.zero,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Helper.brandColors[9], width: .2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Helper.brandColors[9], width: .5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Helper.brandColors[9], width: 2.0),
      ),
      fillColor: Helper.brandColors[1],
      filled: true);
}
