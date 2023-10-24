import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/perfil.dart';
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
                  return Loading(mensaje: 'Cargando personal...');
                } else {
                  var personal = snapshot.data as List<Miembro>;
                  personal =
                      personal.where((miembro) => miembro.role != 1).toList();
                  if (personal.length > 0) {
                    final dataTile = personal.map((e) => {
                          'title': '${e.nombre + ' ' + e.apellido}',
                          'subtitle': Helper.getProfesion(e.role),
                          'avatar': '${e.profileURL}',
                          'id': e.id
                        });

                    return Column(
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height - 160,
                            color: Helper.brandColors[1],
                            child: _CustomSearchListView(
                              txtController: txtBuscador,
                              data: dataTile.toList(),
                              dataFiltrada: dataTile.toList(),
                            ),
                          ),
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
      {Key? key,
      required this.data,
      required this.dataFiltrada,
      required this.txtController})
      : super(key: key);

  List<dynamic> data;
  List<dynamic> dataFiltrada = [];

  TextEditingController txtController;

  @override
  State<_CustomSearchListView> createState() => __CustomSearchListViewState();
}

class __CustomSearchListViewState extends State<_CustomSearchListView> {
  late SocketService _socketService;
  Preferences _pref = new Preferences();
  String txtBuscar = '';

  @override
  void initState() {
    widget.dataFiltrada = widget.data;
    super.initState();
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
                      widget.dataFiltrada = widget.data;

                      setState(() {});
                    },
                  )
                : IconButton(
                    color: Helper.brandColors[4],
                    icon: _pref.role == 1 ? Icon(Icons.add) : Container(),
                    onPressed: () => Navigator.pushNamed(
                        context, MiembroForm.routeName,
                        arguments: {}),
                  ),
            textController: widget.txtController,
            onChange: (text) {
              widget.dataFiltrada = widget.data;
              txtBuscar = text;
              widget.dataFiltrada = widget.dataFiltrada
                  .where((dato) =>
                      dato["title"].toLowerCase().contains(text.toLowerCase()))
                  .toList();
              setState(() {});
            },
          ),
          txtBuscar.length > 0 && widget.dataFiltrada.length == 0
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
                      itemCount: widget.dataFiltrada.length,
                      itemBuilder: ((context, index) {
                        final esPar = index % 2 == 0;
                        final arg = {
                          'usuarioId': widget.dataFiltrada[index]['id'],
                        };
                        return FadeInRight(
                          delay: Duration(milliseconds: index * 50),
                          child: CustomListTile(
                            esPar: esPar,
                            title: widget.dataFiltrada[index]['title'],
                            subtitle: widget.dataFiltrada[index]['subtitle'],
                            avatar:
                                widget.dataFiltrada[index]['avatar'].toString(),
                            fontSize: 18,
                            onTap: true,
                            actionOnTap: () => Navigator.pushNamed(
                                context, PerfilPage.routeName,
                                arguments: arg),
                          ),
                        );
                      })),
                )
        ],
      ),
    );
  }
}
