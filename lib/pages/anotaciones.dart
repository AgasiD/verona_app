import 'package:animate_do/animate_do.dart';
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
import 'package:win32/win32.dart';

class AnotacionesPage extends StatelessWidget {
  AnotacionesPage({Key? key}) : super(key: key);
  static final routeName = 'anotaciones';
  TextEditingController txtTarea = new TextEditingController();

  late Miembro usuario;



  @override
  Widget build(BuildContext context) {
    final _pref = new Preferences();
    final _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    return Scaffold(
      backgroundColor: Helper.brandColors[1],
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

              return Action_Form(usuario: usuario, txtTarea: txtTarea);
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class Action_Form extends StatefulWidget {
  const Action_Form({
    Key? key,
    required this.usuario,
    required this.txtTarea,
  }) : super(key: key);

  final Miembro usuario;
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
    _usuarioService = Provider.of<UsuarioService>(context);

    return Column(children: [
      Expanded(
        child: widget.usuario.anotaciones == null ||
                widget.usuario.anotaciones!.isEmpty
            ? Center(
                child: Text('¡Escribí tu primer anotación!',
                    style:
                        TextStyle(fontSize: 20, color: Helper.brandColors[4])))
            : ListView.builder(
                controller: listScrollController,
                itemCount: widget.usuario.anotaciones == null
                    ? 0
                    : widget.usuario.anotaciones!.length,
                itemBuilder: (context, index) => AnotacionTile(
                    anota: widget.usuario.anotaciones![index],
                    action: eliminarAnotacion),
              ),
      ),
      InputTarea(
          focus: focus, action: agregarAnotacion, txtTarea: widget.txtTarea)
    ]);
  }

  agregarAnotacion() {
    final _pref = new Preferences();
    if (widget.txtTarea.text.isNotEmpty) {
      final anotacion = Anotacion(widget.txtTarea.text, id: Uuid().v4());
      _usuarioService.agregarAnotacion(_pref.id, anotacion).then((response) {
        if (response.fallo) {
          openAlertDialog(context, 'Error al crear anotacion',
              subMensaje: response.error);
          return;
        }
      });
      widget.usuario.agregarAnotacion(anotacion);
      widget.txtTarea.clear();
      setState(() {});

      ;
    }
    focus.requestFocus();

    Future.delayed(Duration(milliseconds: 100), () {
      listScrollController.animateTo(
        listScrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  eliminarAnotacion(String id) {
    final _pref = new Preferences();
    _usuarioService.eliminarAnotacion(_pref.id, id).then((value) {
      if (value.fallo) {
        openAlertDialog(context, 'Error al eliminar tarea',
            subMensaje: value.error);
        return;
      }
    });
    widget.usuario.eliminarAnotacion(id);
    //  setState(() {});
  }
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
        hintText: 'Escriba descripción...',
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        suffixIcon: this.widget.txtTarea.text.isNotEmpty
            ? IconButton(
                splashColor: Colors.transparent,
                // splashRadius: 12,
                style: ButtonStyle(
                    shadowColor: MaterialStateProperty.all(Colors.transparent)),
                onPressed: () => widget.action(),
                icon: Icon(
                  Icons.send,
                  color: Helper.brandColors[7],
                ))
            : null,
        hintStyle: TextStyle(color: Helper.brandColors[3]),
        errorMaxLines: 1);
    return Container(
      color: Helper.brandColors[2],
      child: TextFormField(
        autofocus: true,
        focusNode: widget.focus,
        textCapitalization: TextCapitalization.sentences,
        controller: widget.txtTarea,
        maxLines: 1,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.send,
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

class AnotacionTile extends StatefulWidget {
  AnotacionTile({Key? key, required this.anota, required this.action})
      : super(key: key);
  Anotacion anota;
  Function action;

  @override
  State<AnotacionTile> createState() => _AnotacionTileState();
}

class _AnotacionTileState extends State<AnotacionTile> {
  late UsuarioService _usuarioService;

  @override
  Widget build(BuildContext context) {
    _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    return FadeInRight(
      duration: Duration(milliseconds: 500),
      child: Dismissible(
        confirmDismiss: (direction) {
          return openDialogConfirmationReturn(context, 'Confirme para borrar');
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
        onDismissed: (direction) => widget.action(widget.anota.id),
        key: Key(widget.anota.id),
        child: Column(
          children: [
            Theme(
              data: ThemeData(unselectedWidgetColor: Helper.brandColors[4]),
              child: CheckboxListTile(
                tileColor: Helper.brandColors[1],
                checkColor: Helper.brandColors[5],
                activeColor: Helper.brandColors[8],
                selectedTileColor: Helper.brandColors[8],
                title: Text(
                  widget.anota.descripcion,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Helper.brandColors[3]),
                ),
                onChanged: (value) => cambiarEstado(value!),
                // onChanged: (value) async {
                //   openLoadingDialog(context, mensaje: 'Actualizando...');
                //   // final response = await _obraService.actualizarTarea(
                //   //     _obraService.obra.id,
                //   //     widget.etapaId,
                //   //     widget.tarea.subetapa,
                //   //     widget.tarea.id,
                //   //     value!,
                //   //     new Preferences().id,
                //   //     DateTime.now().millisecondsSinceEpoch);
                //   closeLoadingDialog(context);
                //   widget.tarea.realizado = value!;
                //   // _obraService.notifyListeners();

                //   if (response.fallo) {
                //     openAlertDialog(context, 'Error al actualizar tarea',
                //         subMensaje: response.error);
                //   }

                //   setState(() {});
                // },
                // value: widget.tarea.realizado,
                value: widget.anota.realizado,
              ),
            ),
            Divider(
              color: Helper.brandColors[8],
            )
          ],
        ),
      ),
    );
  }

  actualizarAnota(Anotacion anota) async {
    // final response = await _usuarioService.actualizarAnotacion();
    // if (response.fallo)
    //   openAlertDialog(context, 'Error al actualizar anotación');
  }

  cambiarEstado(bool value) {
    final _pref = new Preferences();
    widget.anota.cambioEstado(value);
    _usuarioService.modificarAnotacion(_pref.id, widget.anota).then((value) {
      if (value.fallo) {
        openAlertDialog(context, 'Error al actualizar tarea',
            subMensaje: value.error);
        return;
      }
    });
    setState(() {});
  }
}
