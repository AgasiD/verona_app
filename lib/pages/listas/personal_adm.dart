import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PersonalADM extends StatelessWidget {
  PersonalADM({Key? key}) : super(key: key);
  static final routeName = 'personal_adm';
  TextEditingController txtBuscador = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context);
    return Scaffold(
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
              future: _usuarioService.obtenerPersonal(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Loading(mensaje: 'Cargando equipo asignado');
                } else {
                  var personal = snapshot.data as List<Miembro>;
                  personal =
                      personal.where((miembro) => miembro.role != 1).toList();
                  if (personal.length > 0) {
                    final dataTile = personal.map((e) => {
                          'title': '${e.nombre + ' ' + e.apellido}',
                          'subtitle': Helper.getProfesion(e.role),
                          'avatar': '${e.nombre[0] + e.apellido[0]}',
                          'id': e.id
                        });

                    return Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height - 150,
                          color: Helper.brandColors[1],
                          child: _CustomSearchListView(
                              txtController: txtBuscador,
                              data: dataTile.toList()),
                        )
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height - 150,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                'Aún no hay personal',
                                style: TextStyle(
                                    fontSize: 18, color: Helper.brandColors[4]),
                              ),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  }
                }
              }),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _CustomSearchListView extends StatefulWidget {
  _CustomSearchListView(
      {Key? key, required this.data, required this.txtController})
      : super(key: key);

  List<dynamic> data;
  TextEditingController txtController;

  @override
  State<_CustomSearchListView> createState() => __CustomSearchListViewState();
}

class __CustomSearchListViewState extends State<_CustomSearchListView> {
  List<dynamic> dataFiltrada = [];
  late SocketService _socketService;
  Preferences _pref = new Preferences();
  String txtBuscar = '';

  @override
  void initState() {
    super.initState();
    dataFiltrada = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomInput(
            width: MediaQuery.of(context).size.width * .95,
            hintText: 'Nombre del personal...',
            icono: Icons.search,
            textInputAction: TextInputAction.search,
            validaError: false,
            iconButton: txtBuscar.length > 0
                ? IconButton(
                    splashColor: null,
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.red.withAlpha(200),
                    ),
                    onPressed: () {
                      widget.txtController.text = '';
                      txtBuscar = '';
                      dataFiltrada = widget.data;
                      setState(() {});
                    },
                  )
                : IconButton(
                    color: Helper.brandColors[4],
                    icon: _pref.role == 1 ? Icon(Icons.add) : Container(),
                    onPressed: null,
                  ),
            textController: widget.txtController,
            onChange: (text) {
              txtBuscar = text;
              dataFiltrada = widget.data
                  .where((dato) =>
                      dato["title"].toLowerCase().contains(text.toLowerCase()))
                  .toList();
              setState(() {});
            },
          ),
          txtBuscar.length > 0 && dataFiltrada.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height - 20,
                  child: Center(
                    child: Text(
                      'No se encontraron usuarios',
                      style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                      maxLines: 3,
                    ),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height - 205,
                  child: ListView.builder(
                      itemCount: dataFiltrada.length,
                      itemBuilder: ((context, index) {
                        final esPar = index % 2 == 0;
                        final arg = {
                          'usuarioId': dataFiltrada[index]['id'],
                        };

                        return CustomListTile(
                          esPar: esPar,
                          title: dataFiltrada[index]['title'],
                          subtitle: dataFiltrada[index]['subtitle'],
                          avatar: dataFiltrada[index]['avatar']
                              .toString()
                              .toUpperCase(),
                          fontSize: 18,
                          onTap: true,
                          actionOnTap: () => Navigator.pushNamed(
                              context, MiembroForm.routeName,
                              arguments: arg),
                        );
                      })),
                )
        ],
      ),
    );
  }
}
