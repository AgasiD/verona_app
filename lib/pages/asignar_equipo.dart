import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class AsignarEquipoPage extends StatelessWidget {
  AsignarEquipoPage({Key? key}) : super(key: key);
  static final routeName = 'asignarequipo';
  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context, listen: false);

    return Scaffold(
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
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
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
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

TextEditingController _txtPersonalCtrl = TextEditingController();

class __SearchListGroupViewState extends State<_SearchListGroupView> {
  List<Miembro> asignados = [];
  List<Miembro> miembrosFiltrados = [];
  @override
  Widget build(BuildContext context) {
    print('build searchlist ');
    final _obraService = Provider.of<ObraService>(context, listen: false);

    var miembros = miembrosFiltrados!.map((e) {
      return Container(
        child: Column(children: [
          // Text(e.dni),
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
        'No se encontró personal',
        style: TextStyle(color: Helper.brandColors[3]),
      ))));
    }
    ;

    return Container(
      child: SingleChildScrollView(
          child: Container(
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
                  iconButton: _txtPersonalCtrl.value == ''
                      ? IconButton(
                          icon: Icon(Icons.cancel_outlined),
                          onPressed: () {
                            _txtPersonalCtrl.text = '';
                          },
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Helper.brandColors[3],
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, MiembroForm.routeName,
                                arguments: {"usuarioId": null});
                          },
                        ),
                  textController: _txtPersonalCtrl,
                  onChange: (text) {
                    miembrosFiltrados.clear();
                    widget.grupos.forEach((element) {
                      final miembros = widget.datos[element];
                      miembrosFiltrados.addAll(miembros!
                          .where((element) => element.nombre
                              .toString()
                              .toLowerCase()
                              .contains(text.toLowerCase()))
                          .toList() as List<Miembro>);
                    });
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          _txtPersonalCtrl.text == ''
              ? SizedBox(
                  height: MediaQuery.of(context).size.height - 280,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    itemCount: widget.grupos.length,
                    itemBuilder: (context, index) {
                      var miembros =
                          widget.datos[widget.grupos[index]]!.map((e) {
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
                          style: TextStyle(color: Helper.brandColors[3]),
                        ))));
                      }

                      final cab = Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Helper.brandColors[9], width: .2),
                          borderRadius: BorderRadius.circular(7),
                          color: Helper.brandColors[0],
                          boxShadow: [
                            BoxShadow(
                                color: Helper.brandColors[0],
                                blurRadius: 4,
                                offset: Offset(10, 8))
                          ],
                        ),
                        alignment: Alignment.centerLeft,
                        height: 50,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                widget.icons[widget.grupos[index]]!,
                                color: Helper.brandColors[8],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  widget.datos.keys.toList()[index],
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Helper.brandColors[3]),
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
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height - 280,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: miembros,
                    ),
                  ),
                ),
          Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: MainButton(
                  color: Helper.brandColors[0],
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, ObraPage.routeName,
                      arguments: {'obraId': _obraService.obra.id}),
                  text: 'Aceptar'))
        ]),
      )),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _txtPersonalCtrl.text = '';
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
        : Icon(
            Icons.add,
            color: Helper.brandColors[3],
          );
    return ListTile(
        title: Text(
          '${widget.personal.nombre} ${widget.personal.apellido}',
          style: TextStyle(
              color: Helper.brandColors[4], fontWeight: FontWeight.bold),
        ),
        subtitle: Text('DNI: ${widget.personal.dni}',
            style: TextStyle(color: Helper.brandColors[3])),
        trailing: icono,
        onTap: () async {
          if (!asignado) {
            // ASOCIAR PERSONAL
            openLoadingDialog(context, mensaje: 'Asignando usuario...');

            final response = await _obraService.agregarUsuario(
                _obraService.obra.id, widget.personal.dni);
            if (response.fallo) {
              closeLoadingDialog(context);
              openAlertDialog(context, 'Error al agregar personal',
                  subMensaje: response.error);
            } else {
              closeLoadingDialog(context);
              _obraService.obra.sumarPersonal(widget.personal);
              snackText =
                  '${widget.personal.nombre} ${widget.personal.apellido} fue asignado al equipo';
            }
          } else {
            //DESASOCIAR PERSONAL
            openLoadingDialog(context, mensaje: 'Desasociando...');

            final response = await _obraService.quitarUsuario(
                _obraService.obra.id, widget.personal.dni);
            if (response.fallo) {
              closeLoadingDialog(context);
              openAlertDialog(context, 'Error al quitar personal',
                  subMensaje: response.error);
            } else {
              _obraService.obra.quitarPersonal(widget.personal);
              closeLoadingDialog(context);
              Helper.showSnackBar(
                  context, snackText, null, Duration(milliseconds: 700), null);
            }
          }

          setState(
            () {},
          );
        });
  }
}
