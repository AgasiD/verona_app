import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class AgregarPropietariosPage extends StatefulWidget {
  static final routeName = 'addPropietario';

  AgregarPropietariosPage({Key? key}) : super(key: key);

  @override
  State<AgregarPropietariosPage> createState() =>
      _AgregarPropietariosPageState();
}

class _AgregarPropietariosPageState extends State<AgregarPropietariosPage> {
  List<Propietario> agregados = [];
  List<Propietario> propietarios = [];

  //late Obra obra;

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    final _usuarioService = Provider.of<UsuarioService>(context, listen: false);

    return Scaffold(
        appBar: CustomAppBar(
          title: 'Asociar propietario',
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: _usuarioService.obtenerPropietarios(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Loading();
              } else {
                final propietarios = snapshot.data as List<Propietario>;
                return Column(children: [
                  _SearchListView(
                      obra: _obraService.obra, propietarios: propietarios),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: MainButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, ObraPage.routeName,
                              arguments: {'obraId': _obraService.obra.id}),
                          text: 'Aceptar'))
                ]);
              }
            },
          ),
        ));
  }
}

class _CustomListAdded extends StatefulWidget {
  _CustomListAdded(
      {Key? key,
      required this.obra,
      required this.propietarios,
      required this.filtro})
      : super(key: key);

  Obra obra;
  List<Propietario> propietarios;
  String filtro;
  @override
  State<_CustomListAdded> createState() => __CustomListAddedState();
}

class __CustomListAddedState extends State<_CustomListAdded> {
  List<Propietario> propietariosFiltrados = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.propietariosFiltrados = widget.propietarios
        .where((prop) =>
            prop.nombre.toLowerCase().contains(widget.filtro.toLowerCase()))
        .toList();
    List<String> asignados =
        widget.obra.propietarios.map((e) => e.dni).toList();
    return ListView.builder(
        physics:
            NeverScrollableScrollPhysics(), // esto hace que no rebote el gridview al scrollear
        padding: EdgeInsets.only(top: 25),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.propietarios.length,
        itemBuilder: (BuildContext ctx, i) {
          final propietario = widget.propietarios[i];
          final agregado =
              asignados.indexWhere((element) => element == propietario.dni) >
                  -1;
          Icon icono = agregado
              ? Icon(
                  Icons.check,
                  color: Colors.green.shade300,
                )
              : Icon(Icons.add);
          return _customTileAdded(
            asignados: asignados,
            agregado: agregado,
            obra: widget.obra,
            propietario: propietario,
          );
        });
  }
}

class _customTileAdded extends StatefulWidget {
  _customTileAdded({
    Key? key,
    required this.asignados,
    required this.agregado,
    required this.obra,
    required this.propietario,
  }) : super(key: key);

  List<String> asignados;
  bool agregado;
  Obra obra;
  Propietario propietario;
  @override
  State<_customTileAdded> createState() => __customTileAddedState();
}

class __customTileAddedState extends State<_customTileAdded> {
  @override
  Widget build(BuildContext context) {
    final _ObraService = Provider.of<ObraService>(context, listen: false);
    final _UsuarioService = Provider.of<UsuarioService>(context, listen: false);

    Icon icono = widget.agregado
        ? Icon(
            Icons.check,
            color: Colors.green.shade300,
          )
        : Icon(Icons.add);
    return Column(
      children: [
        ListTile(
          onTap: () async {
            String mensaje = '';
            print('PROPIETARIO');

            print(widget.agregado);
            if (widget.agregado) {
              openLoadingDialog(context, mensaje: 'Desasignando propietario');
              mensaje = 'Propietario quitado';
              await _ObraService.quitarUsuario(
                  widget.obra.id, widget.propietario.dni);
              widget.asignados
                  .removeWhere((element) => element == widget.propietario.dni);
              widget.agregado = !widget.agregado;
              widget.obra.quitarPropietario(widget.propietario);
            } else {
              openLoadingDialog(context, mensaje: 'Asociando propietario...');
              mensaje = 'Propietario asignado';
              await _ObraService.agregarUsuario(
                  widget.obra.id, widget.propietario.dni);
              widget.asignados.add(widget.propietario.dni);
              widget.agregado = !widget.agregado;
              widget.obra.sumarPropietario(widget.propietario);
            }
            closeLoadingDialog(context);
            Helper.showSnackBar(context, mensaje, TextStyle(fontSize: 15),
                Duration(milliseconds: 500));
          },
          title: Text(
              '${widget.propietario.nombre} ${widget.propietario.apellido}'),
          subtitle: Text('${widget.propietario.dni}'),
          trailing: icono,
        ),
        Divider(
          height: 1,
        )
      ],
    );
  }
}

class _SearchListView extends StatefulWidget {
  _SearchListView({Key? key, required this.obra, required this.propietarios})
      : super(key: key);
  Obra obra;
  List<Propietario> propietarios;
  @override
  State<_SearchListView> createState() => __SearchListViewState();
}

class __SearchListViewState extends State<_SearchListView> {
  TextEditingController txtPropietarioCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          width: MediaQuery.of(context).size.width * .95,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomInput(
                width: MediaQuery.of(context).size.width * .95,
                hintText: 'Martín...',
                icono: Icons.search,
                textInputAction: TextInputAction.search,
                iconButton: txtPropietarioCtrl.value == ''
                    ? IconButton(
                        icon: Icon(Icons.cancel_outlined),
                        onPressed: () {
                          txtPropietarioCtrl.text = '';
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, PropietarioForm.routeName);
                        },
                      ),
                textController: txtPropietarioCtrl,
                onChange: (text) {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * .62,
          child: SingleChildScrollView(
              child: _CustomListAdded(
                  obra: widget.obra,
                  propietarios: widget.propietarios
                      .where((prop) => prop.nombre
                          .toLowerCase()
                          .contains(txtPropietarioCtrl.text.toLowerCase()))
                      .toList(),
                  filtro: txtPropietarioCtrl.text)),
        ),
      ],
    );
  }
}
