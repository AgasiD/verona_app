import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/anotacion.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class AnotacionForm extends StatelessWidget {
  AnotacionForm({Key? key}) : super(key: key);
  static final routeName = 'AnotacionForm';
  TextEditingController txtTarea = new TextEditingController();

  late Miembro usuario;
  late String obraId;
  late Anotacion anotacion;
  late UsuarioService _usuarioService;
  String text = '';
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings;
    final _pref = new Preferences();
    _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    bool is_new = true;
    final data = args.arguments as Map;
    if (data['anotacion'] != null) {
      is_new = false;
      anotacion = data['anotacion'];
      txtTarea.text = anotacion.descripcion;
    } else {
      obraId = data['obraId'];
      anotacion = new Anotacion('', obraId: obraId);
    }

    return GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: WillPopScope(
          onWillPop: () async {
            is_new
                ? await nueva_anotacion(
                    context, txtTarea.text, anotacion.realizado)
                : await modifica_anotacion(context, txtTarea.text, anotacion);
            return true;
          },
          child: Scaffold(
            backgroundColor: Helper.brandColors[1],
            appBar: CheckAppBar(anotacion: anotacion),
            body: SafeArea(
              child: Container(
                  child: FutureBuilder(
                future: _usuarioService.obtenerUsuario(_pref.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Loading(mensaje: 'Cargando...');
                  final response = snapshot.data as MyResponse;
                  if (response.fallo)
                    return Center(
                      child: Text('Error al cargar datos'),
                    );
                  usuario = Miembro.fromJson(response.data);
                  return Action_Form(
                    txtTarea: txtTarea,
                  );
                },
              )),
            ),
            bottomNavigationBar: CustomNavigatorFooter(),
          ),
        ));
  }

  modifica_anotacion(context, String descripcion, Anotacion anotacion) async {
    bool loading = false;
    final _pref = new Preferences();
    try {
      if (descripcion.isEmpty) return;
      anotacion.descripcion = descripcion;
      openLoadingDialog(context, mensaje: 'Grabando anotación...');
      await _usuarioService.modificarAnotacion(_pref.id, anotacion);
      loading = true;
      usuario.actualizarAnotacion(anotacion);
      loading = true;

      closeLoadingDialog(context);
    } catch (err) {
      loading ? closeLoadingDialog(context) : false;
      openAlertDialog(context, 'Error al grabar', subMensaje: err.toString());
    }
  }

  nueva_anotacion(context, String text, realizado) async {
    bool loading = false;
    final _pref = new Preferences();
    try {
      if (text.isEmpty) return;
      // if (widget.txtTarea.text.isNotEmpty) {
      final anotacion = Anotacion(text,
          id: Uuid().v4(),
          obraId: obraId,
          realizado: realizado,
          tsGenerado: DateTime.now().millisecondsSinceEpoch);
      openLoadingDialog(context, mensaje: 'Grabando anotación...');
      await _usuarioService.agregarAnotacion(_pref.id, anotacion);
      loading = true;
      usuario.agregarAnotacion(anotacion);
      closeLoadingDialog(context);
    } catch (err) {
      loading ? closeLoadingDialog(context) : false;
      openAlertDialog(context, 'Error al grabar', subMensaje: err.toString());
    }
  }
}

class CheckAppBar extends StatefulWidget implements PreferredSizeWidget {
  CheckAppBar({
    Key? key,
    required this.anotacion,
  }) : super(key: key);
  Anotacion anotacion;

  @override
  State<CheckAppBar> createState() => _CheckAppBarState();

  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(50);
}

class _CheckAppBarState extends State<CheckAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text('Anotación'),
        backgroundColor: Helper.brandColors[1],
        actions: [
          IconButton(
            icon: Icon(
                widget.anotacion.realizado
                    ? Icons.check_box
                    : Icons.check_box_outline_blank_rounded,
                color: Helper.brandColors[8]),
            onPressed: () {
              cambiarAnotacion();
            },
          )
        ]);
  }

  cambiarAnotacion() {
    widget.anotacion.realizado = !widget.anotacion.realizado;
    setState(() {});
  }
}

class Action_Form extends StatefulWidget {
  Action_Form({
    Key? key,
    required this.txtTarea,
  }) : super(key: key);

  final TextEditingController txtTarea;

  @override
  State<Action_Form> createState() => _Action_FormState();
}

class _Action_FormState extends State<Action_Form> {
  FocusNode focus = FocusNode();
  ScrollController listScrollController = ScrollController();
  late UsuarioService _usuarioService;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        InputTarea(
            focus: focus, action: agregarAnotacion, txtTarea: widget.txtTarea),
        Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              '*La anotación se guardará al salir de la pantalla',
              style: TextStyle(color: Helper.brandColors[3]),
              textAlign: TextAlign.start,
            ))
      ]),
    );
  }

  agregarAnotacion() {}
}

class InputTarea extends StatefulWidget {
  InputTarea({
    Key? key,
    required this.focus,
    required this.txtTarea,
    required this.action,
  }) : super(key: key);

  Function action;
  FocusNode focus;
  final TextEditingController txtTarea;

  @override
  State<InputTarea> createState() => _InputTareaState();
}

class _InputTareaState extends State<InputTarea> {
  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        hintText: 'Escribí la anotación',
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        hintStyle: TextStyle(color: Helper.brandColors[3]),
        errorMaxLines: 1);
    return Container(
      color: Helper.brandColors[2],
      child: TextFormField(
        autofocus: true,
        minLines: 30,
        focusNode: widget.focus,
        textCapitalization: TextCapitalization.sentences,
        controller: widget.txtTarea,
        maxLines: 30,
        autocorrect: false,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        keyboardAppearance: Brightness.dark,
        decoration: inputDecoration,
        style: TextStyle(color: Helper.brandColors[5]),
        onChanged: (value) => {
          if (widget.txtTarea.text.isEmpty || widget.txtTarea.text.length == 1)
            setState(() {})
        },
        onFieldSubmitted: (a) => widget.action(),
      ),
    );
  }
}
