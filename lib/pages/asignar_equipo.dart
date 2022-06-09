import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/models/propietario.dart';
import 'package:verona_app/pages/form.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

import '../helpers/Preferences.dart';

class AsignarEquipoPage extends StatefulWidget {
  static final routeName = 'asignarequipo';

  AsignarEquipoPage({Key? key}) : super(key: key);

  @override
  State<AsignarEquipoPage> createState() => _AgregarPropietariosPageState();
}

TextEditingController txtPersonalCtrl = TextEditingController();

class _AgregarPropietariosPageState extends State<AsignarEquipoPage> {
  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context, listen: false);

    return Scaffold(
        appBar: CustomAppBar(
          title: 'Asignar equipo',
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: _usuarioService.obtenerPersonal(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Loading();
              } else {
                final profesionales = snapshot.data as List<Miembro>;
                Map<String, List<Miembro>> profesiones;

                final arq = profesionales.where((e) => e.role == 2).toList();
                final obreros =
                    profesionales.where((e) => e.role == 4).toList();
                final comp = profesionales.where((e) => e.role == 5).toList();
                final delivery =
                    profesionales.where((e) => e.role == 6).toList();

                profesiones = {
                  'Arquitectos': arq,
                  'Obreros': obreros,
                  'Compradores': comp,
                  'Repartidor': delivery
                };

                final grupos = [
                  'Arquitectos',
                  'Obreros',
                  'Compradores',
                  'Repartidor'
                ];

                final icons = {
                  'Arquitectos': Icons.architecture_rounded,
                  'Obreros': Icons.construction_outlined,
                  'Compradores': Icons.card_travel,
                  'Repartidor': Icons.delivery_dining_rounded,
                };

                return _SearchListGroupView(
                    grupos: grupos, datos: profesiones, icons: icons);
              }
            },
          ),
        ));
  }
}

class _SearchListGroupView extends StatefulWidget {
  _SearchListGroupView(
      {Key? key,
      required this.grupos,
      required this.datos,
      required this.icons})
      : super(key: key);
  List<String> grupos;
  Map<String, IconData> icons;
  Map<String, List<dynamic>> datos;
  @override
  State<_SearchListGroupView> createState() => __SearchListGroupViewState();
}

class __SearchListGroupViewState extends State<_SearchListGroupView> {
  List<Miembro> asignados = [];
  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    return SingleChildScrollView(
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
              textInputAction: TextInputAction.search,
              icono: Icons.search,
              iconButton: txtPersonalCtrl.value == ''
                  ? IconButton(
                      icon: Icon(Icons.cancel_outlined),
                      onPressed: () {
                        txtPersonalCtrl.text = '';
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, MiembroForm.routeName);
                      },
                    ),
              textController: txtPersonalCtrl,
              onChange: (text) {
                setState(() {});
              },
            ),
          ],
        ),
      ),
      SizedBox(
        height: MediaQuery.of(context).size.height * .65,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemCount: widget.grupos.length,
          itemBuilder: (context, index) {
            var miembros = widget.datos[widget.grupos[index]]!.map((e) {
              return Container(
                child: Column(children: [
                  _CustomAddListTile(personal: e),
                  Divider(
                    height: 0,
                  ),
                ]),
              );
            }).toList();
            if (miembros.length == 0) {
              miembros.add(Container(
                  child: ListTile(
                      title: Text(
                'Sin personal',
              ))));
            }

            final cab = Container(
              color: Color.fromARGB(255, 235, 234, 234),
              alignment: Alignment.centerLeft,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Icon(
                      widget.icons[widget.grupos[index]]!,
                      color: Helper.primaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        widget.datos.keys.toList()[index],
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              margin: EdgeInsets.all(5),
            );
            miembros.insert(0, cab);
            return Column(
              children: miembros,
            );
          },
        ),
      ),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: MainButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, ObraPage.routeName,
                  arguments: {'obraId': _obraService.obra.id}),
              text: 'Aceptar'))
    ]));
  }
}

class _CustomAddListTile extends StatefulWidget {
  const _CustomAddListTile({Key? key, required this.personal})
      : super(key: key);

  final Miembro personal;

  @override
  State<_CustomAddListTile> createState() => _CustomAddListTileState();
}

class _CustomAddListTileState extends State<_CustomAddListTile> {
  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    final _socketService = Provider.of<SocketService>(context, listen: false);

    bool asignado = _obraService.obra.equipo
            .where((element) => element.dni == widget.personal.dni)
            .length >
        0;
    String snackText =
        '${widget.personal.nombre} ${widget.personal.apellido} fue quitado del equipo';
    Icon icono = asignado
        ? Icon(
            Icons.check,
            color: Colors.green.shade300,
          )
        : Icon(Icons.add);
    return ListTile(
        title: Text('${widget.personal.nombre} ${widget.personal.apellido} '),
        subtitle: Text('DNI: ${widget.personal.dni}'),
        trailing: icono,
        onTap: () async {
          if (!asignado) {
            openLoadingDialog(context, mensaje: 'Asignando usuario...');

            await _socketService.agregarUsuario(
                _obraService.obra.id, widget.personal.dni);
            _obraService.obra.sumarPersonal(widget.personal);
            snackText =
                '${widget.personal.nombre} ${widget.personal.apellido} fue asignado al equipo';
          } else {
            openLoadingDialog(context, mensaje: 'Desasociando...');

            await _socketService.quitarUsuario(
                _obraService.obra.id, widget.personal.dni);
            _obraService.obra.quitarPersonal(widget.personal);
          }
          closeLoadingDialog(context);
          Helper.showSnackBar(
            context,
            snackText,
            null,
            Duration(milliseconds: 700),
          );
          setState(
            () {},
          );
        });
  }
}
