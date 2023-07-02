import 'package:animate_do/animate_do.dart';
import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/anotacion.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';
import 'package:win32/win32.dart';

class AnotacionesGeneralPage extends StatefulWidget {
  AnotacionesGeneralPage({Key? key}) : super(key: key);
  static final routeName = 'anotaciones_general';

  @override
  State<AnotacionesGeneralPage> createState() => _AnotacionesGeneralPageState();
}

class _AnotacionesGeneralPageState extends State<AnotacionesGeneralPage>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;

  int index = 0;

  @override
  Widget build(BuildContext context) {
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.index = index;
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Helper.brandColors[1],
          appBar: AppBar(
            title: Text('Anotaciones'),
            backgroundColor: Helper.brandColors[2],
            bottom: TabBar(
              // controller: _tabCtrl,
              splashFactory: NoSplash.splashFactory,
              dividerColor: Helper.brandColors[8],
              indicatorColor: Helper.brandColors[8],
              tabs: [
                Tab(
                    child: Text(
                  'General',
                  style: TextStyle(color: Helper.brandColors[8]),
                )),
                Tab(
                    child: Text(
                  'Por obras',
                  style: TextStyle(color: Helper.brandColors[8]),
                )),
              ],
            ),
          ),
          body: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SafeArea(
                child: Container(
                  child: TabBarView(
                      //controller: _tabCtrl,
                      children: [
                        AnotacionesGenerales(),
                        AnotacionesPorObra(),
                      ]),
                ),
              )),
          bottomNavigationBar: CustomNavigatorFooter(),
        ));
  }
}

class AnotacionesGenerales extends StatelessWidget {
  AnotacionesGenerales({Key? key}) : super(key: key);
  late Miembro usuario;

  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    final _pref = new Preferences();
    TextEditingController txtTarea = new TextEditingController();

    return FutureBuilder(
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

        return Action_Form(usuario: usuario, txtTarea: txtTarea, obraId: null);
      },
    );
  }
}

class Action_Form extends StatefulWidget {
  Action_Form({
    Key? key,
    required this.usuario,
    required this.txtTarea,
    required this.obraId,
  }) : super(key: key);

  final Miembro usuario;
  final TextEditingController txtTarea;
  String? obraId;

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
    List<Anotacion> anotaciones;
    if ((widget.obraId == '' || widget.obraId == null)) {
      anotaciones = widget.usuario.anotaciones!
          .where((anotacion) => anotacion.obraId == null)
          .toList();
    } else {
      anotaciones = widget.usuario.anotaciones!
          .where((anotacion) => anotacion.obraId == widget.obraId)
          .toList();
    }
    return Column(children: [
      Expanded(
        child: anotaciones == null || anotaciones.isEmpty
            ? Center(
                child: Text('¡Escribí tu primer anotación!',
                    style:
                        TextStyle(fontSize: 20, color: Helper.brandColors[4])))
            : ListView.builder(
                controller: listScrollController,
                itemCount: anotaciones == null ? 0 : anotaciones!.length,
                itemBuilder: (context, index) => AnotacionTile(
                    anota: anotaciones![index], action: eliminarAnotacion),
              ),
      ),
      InputTarea(
          focus: focus, action: agregarAnotacion, txtTarea: widget.txtTarea)
    ]);
  }

  agregarAnotacion() {
    final _pref = new Preferences();
    if (widget.txtTarea.text.isNotEmpty) {
      final anotacion = Anotacion(widget.txtTarea.text,
          id: Uuid().v4(), obraId: widget.obraId);
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
        openAlertDialog(context, 'Error al eliminar anotacion',
            subMensaje: value.error);
        return;
      }
    });
    widget.usuario.eliminarAnotacion(id);
    //  setState(() {});
  }
}

class AnotacionesPorObra extends StatelessWidget {
  AnotacionesPorObra({Key? key}) : super(key: key);
  late Miembro usuario;

  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    final _pref = new Preferences();
    TextEditingController txtTarea = new TextEditingController();

    return FutureBuilder(
      future: _usuarioService.obtenerAnotacionesByObra(_pref.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Loading(mensaje: 'Cargando...');
        final response = snapshot.data as MyResponse;
        if (response.fallo)
          return Center(
            child: Text('Error al cargar datos'),
          );
        final anotaciones_obra = response.data;

        return Action_Obra_Form(anotaciones: anotaciones_obra);
      },
    );
  }
}

class Action_Obra_Form extends StatefulWidget {
  Action_Obra_Form({Key? key, required this.anotaciones}) : super(key: key);

  List anotaciones;

  @override
  State<Action_Obra_Form> createState() => _Action_Obra_FormState();
}

class _Action_Obra_FormState extends State<Action_Obra_Form> {
  FocusNode focus = FocusNode();
  ScrollController listScrollController = ScrollController();
  late UsuarioService _usuarioService;

  @override
  Widget build(BuildContext context) {
    _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    List<Anotacion> anotes_obra = [];
    List<String> obrasId =
        widget.anotaciones.map<String>((e) => e['obraId']).toList();
    obrasId = obrasId.toSet().toList();
    return Column(children: [
      Expanded(
        child: widget.anotaciones.isEmpty
            ? Center(
                child: Text('¡Escribí tu primer anotación!',
                    style:
                        TextStyle(fontSize: 20, color: Helper.brandColors[4])))
            : ListView.builder(
                controller: listScrollController,
                itemCount: obrasId.length,
                itemBuilder: (context, index) {
                  final anotacionesObra = widget.anotaciones
                      .where((anota) => anota['obraId'] == obrasId[index])
                      .toList();
                  final obra = Obra.fromMap(anotacionesObra.first['obra']);
                  return Column(children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Helper.brandColors[9], width: .2),
                        borderRadius: BorderRadius.circular(5),
                        color: Helper.brandColors[0],
                      ),
                      child: ListTile(
                        title: Text(
                            '${obra.nombre.toString().toUpperCase()} | ${obra.barrio.toString().toUpperCase()} | ${obra.lote.toString()} '),
                        textColor: Helper.brandColors[5],
                      ),
                    ),
                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: anotacionesObra.length,
                      itemBuilder: (context, i) => AnotacionTile(
                          anota: Anotacion.fromJson(anotacionesObra[i]),
                          action: eliminarAnotacion),
                    ),
                  ]);
                },
              ),
      ),
    ]);
  }

  eliminarAnotacion(String id) {
    final _pref = new Preferences();
    _usuarioService.eliminarAnotacion(_pref.id, id).then((value) {
      if (value.fallo) {
        openAlertDialog(context, 'Error al eliminar anotacion',
            subMensaje: value.error);
        return;
      }
    });
    // widget.usuario.eliminarAnotacion(id);
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
        minLines: 1,
        focusNode: widget.focus,
        textCapitalization: TextCapitalization.sentences,
        controller: widget.txtTarea,
        maxLines: 5,
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
                  // overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Helper.brandColors[3]),
                ),
                onChanged: (value) => cambiarEstado(value!),
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

  cambiarEstado(bool value) async {
    bool loading = true;
    try {
      final _pref = new Preferences();
      openLoadingDialog(context, mensaje: 'Actualizando...');
      widget.anota.cambioEstado(value);
      final response =
          await _usuarioService.modificarAnotacion(_pref.id, widget.anota);
      closeLoadingDialog(context);
      loading = false;
      if (response.fallo) {
        openAlertDialog(context, 'Error al actualizar tarea',
            subMensaje: response.error);
        return;
      }

      setState(() {});
    } catch (err) {
      loading ? closeLoadingDialog(context) : false;

      await openAlertDialogReturn(context, 'Error al actualizar');
    }
  }
}
