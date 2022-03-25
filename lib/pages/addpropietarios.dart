import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/pages/form.dart';
import 'package:verona_app/pages/forms/obra.dart';
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
  //late Obra obra;
  final propietarios = [];

  TextEditingController txtPropietarioCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Asociar propietario',
      ),
      body: SafeArea(
        child: Column(children: [
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
                                  context, FormPage.routeName, arguments: {
                                'formName': PropietarioForm.routeName
                              });
                            },
                          ),
                    textController: txtPropietarioCtrl),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * .65,
            child: SingleChildScrollView(
                child: _CustomListAdded(obra: _obraService.obra)),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: MainButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, ObraPage.routeName,
                      arguments: {'obraId': _obraService.obra.id}),
                  text: 'Aceptar'))
        ]),
      ),
    );
  }
}

class _CustomListAdded extends StatefulWidget {
  _CustomListAdded({Key? key, required this.obra}) : super(key: key);

  Obra obra;

  @override
  State<_CustomListAdded> createState() => __CustomListAddedState();
}

class __CustomListAddedState extends State<_CustomListAdded> {
  @override
  Widget build(BuildContext context) {
    final _ObraService = Provider.of<ObraService>(context, listen: false);
    final _UsuarioService = Provider.of<UsuarioService>(context, listen: false);
    List<String> asignados =
        widget.obra.propietarios.map((e) => e.dni).toList();

    return FutureBuilder(
        future: _UsuarioService.obtenerPropietarios(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          } else {
            final propietarios = snapshot.data as List<Propietario>;
            return ListView.builder(
                physics:
                    NeverScrollableScrollPhysics(), // esto hace que no rebote el gridview al scrollear
                padding: EdgeInsets.only(top: 25),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: propietarios.length,
                itemBuilder: (BuildContext ctx, i) {
                  final propietario = propietarios[i];

                  final agregado = asignados
                          .indexWhere((element) => element == propietario.dni) >
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
          onTap: () {
            if (widget.agregado) {
              _ObraService.quitarUsuario(widget.obra.id, widget.propietario.dni)
                  .then((value) {
                widget.asignados.removeWhere(
                    (element) => element == widget.propietario.dni);
                widget.agregado = !widget.agregado;
                widget.obra.quitarPropietario(widget.propietario);
                setState(() {});
              });
            } else {
              print(widget.obra.id);
              _ObraService.agregarUsuario(
                      widget.obra.id, widget.propietario.dni)
                  .then((value) {
                widget.asignados.add(widget.propietario.dni);
                widget.agregado = !widget.agregado;
                widget.obra.sumarPropietario(widget.propietario);

                setState(() {});
              });
            }
          },
          title: Text(
              '${widget.propietario.nombre} ${widget.propietario.apellido}'),
          subtitle: Text('${widget.propietario.email}'),
          trailing: icono,
        ),
        Divider(
          height: 1,
        )
      ],
    );
  }
}
