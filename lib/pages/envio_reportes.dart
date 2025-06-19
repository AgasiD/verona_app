import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class EnvioReporteSemanal extends StatelessWidget {
  EnvioReporteSemanal({Key? key}) : super(key: key);

  static final routeName = 'Envio_Reporte_Semanal';
  late ObraService _obraService ;
  List<String> ids = [];
  late List<Obra> obras;
  @override
  Widget build(BuildContext context) {
    _obraService = Provider.of<ObraService>(context);
    return Scaffold(
      backgroundColor: Helper.brandColors[1],
      bottomNavigationBar: CustomNavigatorFooter(),
      body: SafeArea(
        child: FutureBuilder(
          future: _obraService.obtenerObras(),
          builder: (context, snap) {
            if(snap.connectionState != ConnectionState.done){
              return Loading(mensaje: 'Cargando obras...');
            }
             obras = (snap.data as List<Obra>);
      
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  MultiSelect_Obra(obras: obras, onChange: actualiza_ids),
                  Expanded(child: Container()),
                  MainButton(onPressed: ()=> enviar_reporte(context, ids), text: 'Enviar reporte',color: Helper.brandColors[8],)
                  
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  actualiza_ids ( List<String> values ){
    
    ids = obras.where((obra) => values.contains(obra.nombre)).map((e) => e.id).toList();
    
  }

  enviar_reporte(context, ids) async {
    bool loading = false;
    try{
      openLoadingDialog(mensaje:'Enviando reportes, esto puede demorar');
      loading = true;
      final response = await _obraService.enviarReportes(ids);

      closeLoadingDialog();
      await openAlertDialogReturn('Reportes enviados');

      Navigator.pop(context);


    }catch( err ){
      closeLoadingDialog();
      openAlertDialog('Error al cargar obras', subMensaje: err.toString());

    }
  }

}

class MultiSelect_Obra extends StatefulWidget {
  MultiSelect_Obra({Key? key, required this.obras, required this.onChange}) : super(key: key);
  Function(List<String>) onChange;
  List<Obra> obras;

  @override
  State<MultiSelect_Obra> createState() => _MultiSelect_ObraState();
}

class _MultiSelect_ObraState extends State<MultiSelect_Obra> {
  late List<String> values ;
  late List<String> selected ;

  @override
  void initState() {
    super.initState();
    values =   widget.obras.map((e) => e.nombre as String).toList();
    selected = widget.obras.map((e) => e.nombre as String).toList();

  }
  @override
  Widget build(BuildContext context) {
       return DropDownMultiSelect(
          
          decoration: getDecoration(),
          childBuilder: (option) => Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Obras seleccionadas: ${selected.length}/${values.length}',
                textAlign: TextAlign.right,
                style: TextStyle(color: Helper.brandColors[5], fontSize: 17),
              )),
          selectedValuesStyle: TextStyle(color: Colors.white),
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
            widget.onChange(x);
          },
        );
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
}