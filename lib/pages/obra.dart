import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/asignar_equipo.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/form.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/inactividades.dart';
import 'package:verona_app/pages/listas/equipo.dart';
import 'package:verona_app/pages/listas/propietarios.dart';
import 'package:verona_app/pages/pedidos.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ObraPage extends StatelessWidget {
  static const String routeName = 'obra';

  const ObraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final _service = Provider.of<ObraService>(context, listen: false);
    final _pref = new Preferences();
    return Scaffold(
        bottomNavigationBar: CustomNavigatorFooter(),
        body: FutureBuilder(
            future: _service.obtenerObra(obraId),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Loading();
              } else {
                final obra = snapshot.data as Obra;
                NetworkImage imagen = obra.imageId == ''
                    ? NetworkImage(
                        'https://www.emsevilla.es/wp-content/uploads/2020/10/no-image-1.png')
                    : NetworkImage(
                        'https://drive.google.com/uc?export=view&id=${obra.imageId}');

                return Container(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: [
                            Hero(
                                tag: obra.nombre,
                                child: FadeInImage(
                                  image: imagen,
                                  // height: 250,
                                  width: MediaQuery.of(context).size.width,
                                  placeholder:
                                      AssetImage('assets/loading-image.gif'),
                                  imageErrorBuilder: (_, obj, st) {
                                    return Container(
                                        child: Image(
                                            image: AssetImage(
                                                'assets/image.png')));
                                  },
                                )),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 200,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Helper.brandColors[2],
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 15,
                                    offset: Offset(0, 0))
                              ],
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(30))),
                          child: SingleChildScrollView(
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 18.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _pref.role != 3
                                        ? CircleAvatar(
                                            backgroundColor: Colors.grey[50],
                                            minRadius: 30,
                                            foregroundColor:
                                                Helper.primaryColor,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.groups_outlined,
                                                size: 35,
                                              ),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                    context, ChatPage.routeName,
                                                    arguments: {
                                                      'chatId': obra.chatI
                                                    });
                                              },
                                            ),
                                          )
                                        : Container(width: 60),
                                    Column(
                                      children: [
                                        Text(
                                          obra.nombre,
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          obra.barrio,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Helper.primaryColor),
                                        ),
                                        // Text(
                                        //   'Tareas preliminares ',
                                        //   style: TextStyle(fontSize: 15),
                                        // )
                                      ],
                                    ),
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[50],
                                      minRadius: 30,
                                      foregroundColor: Helper.primaryColor,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.chat,
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          openDialogConfirmation(context,
                                              (ctx) {
                                            Navigator.pushNamed(
                                                ctx, ChatPage.routeName,
                                                arguments: {
                                                  'chatId': obra.chatE
                                                });
                                          }, 'Abrirá chat con propietarios');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _DiasView(obra: obra, obraId: obraId),
                              CaracteristicaObra(),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }));
  }
}

class _DiasView extends StatelessWidget {
  const _DiasView({
    Key? key,
    required this.obra,
    required this.obraId,
  }) : super(key: key);

  final Obra obra;
  final String obraId;

  @override
  Widget build(BuildContext context) {
    final _service = Provider.of<ObraService>(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 25),
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                obra.diasEstimados.toString(),
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Helper.brandColors[8]),
              ),
              Text(
                'Dias estimados',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Helper.brandColors[5]),
              )
            ],
          ),
          VerticalDivider(
            width: 25,
            color: Colors.black45,
            indent: 15,
            endIndent: 15,
          ),
          Column(
            children: [
              Text(
                obra.diasTranscurridos.toString(),
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Helper.brandColors[8]),
              ),
              Text(
                'Dias transcurridos',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Helper.brandColors[5]),
              )
            ],
          ),
          VerticalDivider(
            width: 25,
            color: Colors.black45,
            indent: 15,
            endIndent: 15,
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, InactividadesPage.routeName,
                  arguments: {'obraId': obraId});
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
            ),
            child: Column(children: [
              Text(
                obra.diasInactivos.length.toString(),
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Helper.brandColors[8]),
              ),
              Text(
                'Dias inactivos',
                style: TextStyle(
                    color: Helper.brandColors[5],
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
              )
            ]),
          )
        ],
      ),
    );
  }
}

class CaracteristicaObra extends StatefulWidget {
  const CaracteristicaObra({Key? key}) : super(key: key);

  @override
  State<CaracteristicaObra> createState() => _CaracteristicaObraState();
}

class _CaracteristicaObraState extends State<CaracteristicaObra> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final _service = Provider.of<ObraService>(context, listen: false);

    return FutureBuilder(
      future: _service.obtenerObra(obraId),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(
              child: SpinKitDualRing(
            size: 20,
            color: Helper.primaryColor!,
          ));
          ;
        } else {
          final obra = snapshot.data as Obra;
          final _data = _generarItems(obra);
          return _CustomExpansion(
            data: _data,
          );
        }
      },
    );
  }

  List<Item> _generarItems(Obra obra) {
    List<Item> items = [];
    //Desplegable de propietarios
    final propietarios = Item(
        icon: Icons.key,
        titulo: 'Propietarios',
        route: PropietariosList.routeName,
        accion: () {
          Navigator.pushNamed(context, PropietariosList.routeName,
              arguments: {'obraId': obra.id});
          return 1;
        },
        values: [].toList());
    items.add(propietarios);

    //Desplegable de equipo
    final team = Item(
      icon: Icons.groups_rounded,
      list: 2,
      titulo: 'Equipo',
      values: [].toList(),
      accion: () {
        Navigator.pushNamed(context, EquipoList.routeName,
            arguments: {'obraId': obra.id});
        return 1;
      },
    );
    items.add(team);

    //Desplegable de docs
    final doc = Item(
      icon: Icons.file_copy,
      list: 2,
      titulo: 'Documentos',
      values: [].toList(),
      accion: () {
        Navigator.pushNamed(context, EquipoList.routeName,
            arguments: {'obraId': obra.id});
        return 1;
      },
    );
    items.add(doc);

    final status = Item(
      icon: Icons.account_tree,
      list: 2,
      titulo: 'Etapas',
      values: [].toList(),
      accion: () {
        Navigator.pushNamed(context, EquipoList.routeName,
            arguments: {'obraId': obra.id});
        return 1;
      },
    );
    items.add(status);

    return items;
  }
}

class _CustomExpansion extends StatefulWidget {
  _CustomExpansion({Key? key, required this.data}) : super(key: key);
  List<Item> data;

  @override
  State<_CustomExpansion> createState() => _CustomExpansionState();
}

class _CustomExpansionState extends State<_CustomExpansion> {
  final _pref = new Preferences();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: widget.data
            .map((e) => CaracteristicaButton(
                  action: e.accion,
                  text: e.titulo,
                  icon: e.icon,
                ))
            .toList(),
      ),
    );
  }
}

class CaracteristicaButton extends StatelessWidget {
  CaracteristicaButton(
      {Key? key, required this.action, required this.text, required this.icon})
      : super(key: key);

  String text;
  IconData icon;
  Function() action;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Helper.brandColors[8], width: 1),
        borderRadius: BorderRadius.circular(8),
        color: Helper.brandColors[1],
        boxShadow: [
          BoxShadow(
              color: Helper.brandColors[0],
              blurRadius: 4,
              offset: Offset(15, 12))
        ],
      ),
      child: ElevatedButton(
        onPressed: this.action,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Helper.brandColors[1]),
          shadowColor: MaterialStateProperty.all(Helper.brandColors[1]),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            this.icon,
            color: Helper.brandColors[8],
            size: 28,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Helper.brandColors[3],
          ),
          title:
              Text(text, style: TextStyle(color: Colors.white, fontSize: 17)),
        ),
      ),
    );
    ;
  }
}
