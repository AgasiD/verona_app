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
        appBar: CustomAppBar(
          muestraBackButton: true,
        ),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // IconButton(
                                //   onPressed: () {},
                                //   icon: Icon(Icons.edit),
                                //   splashColor: null,
                                //   splashRadius: 0.1,
                                // ),
                                // IconButton(
                                //   onPressed: () {},
                                //   icon: Icon(Icons.delete),
                                //   splashRadius: 0.1,
                                // )
                              ],
                            )
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
                              color: Colors.grey[50],
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
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     ElevatedButton(
                              //         child: Text('Pedido de materiales'),
                              //         onPressed: () {
                              //           Navigator.pushNamed(
                              //               context, PedidosPage.routeName,
                              //               arguments: {'obraId': obraId});
                              //         })
                              //   ],
                              // )
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
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              Text(
                'Dias estimados',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
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
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              Text(
                'Dias transcurridos',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
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
                    color: Colors.black,
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Dias inactivos',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w300),
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
        titulo: 'Propietarios',
        route: AgregarPropietariosPage.routeName,
        accion: () {
          Navigator.pushReplacementNamed(
              context, AgregarPropietariosPage.routeName);
        },
        values: obra.propietarios
            .map((e) => {
                  'id': e.dni,
                  'nombre': e.nombre + ' ' + e.apellido,
                  'telefono': e.telefono
                })
            .toList());
    items.add(propietarios);

    //Desplegable de equipo
    final team = Item(
      list: 2,
      titulo: 'Equipo',
      values: obra.equipo
          .map((e) => {
                'id': e.dni,
                'nombre': e.nombre + ' ' + e.apellido,
                'telefono': e.telefono,
                'role': e.role
              })
          .toList(),
      accion: () {
        Navigator.pushReplacementNamed(context, AsignarEquipoPage.routeName);
      },
    );
    items.add(team);
    //Desplegable de

    //Desplegable de documentacion

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
    return ExpansionPanelList(
      expandedHeaderPadding: EdgeInsets.symmetric(vertical: 0),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          widget.data[index].isExpanded = !isExpanded;
        });
      },
      elevation: 4,
      children: widget.data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Container(
                padding: EdgeInsets.only(left: 15),
                alignment: Alignment.centerLeft,
                child: ListTile(
                    trailing: item.addButton && _pref.role == 1
                        ? IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              item.accion();
                            })
                        : null,
                    title: Text(
                      item.titulo,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )));
          },
          body: SingleChildScrollView(
              child: Column(children: [
            item.values.length > 0
                ? ListView.builder(
                    physics:
                        NeverScrollableScrollPhysics(), // esto hace que no rebote el gridview al scrollear
                    shrinkWrap: true,
                    itemCount: item.values.length,
                    itemBuilder: (_, i) {
                      bool esEquipo = item.list == 2;
                      return Column(children: [
                        Dismissible(
                            key: Key(item.values[i]['id']),
                            direction: DismissDirection.endToStart,
                            onDismissed: (id) {
                              item.values.remove(item.values.singleWhere(
                                  (element) => element['id'] == id));
                            },
                            background: Container(
                              padding: EdgeInsets.only(left: 5),
                              color: Colors.red,
                              child: const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                            child: ListTile(
                                trailing: esEquipo
                                    ? Chip(
                                        padding: EdgeInsets.all(0),
                                        label: Text(
                                            Helper.getProfesion(
                                                item.values[i]['role']),
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14)),
                                      )
                                    : Container(
                                        width: 1,
                                        height: 1,
                                      ),
                                title: Text(item.values[i]['nombre']),
                                subtitle:
                                    Text(item.values[i]['telefono'] ?? ''),
                                //trailing: const Icon(Icons.delete),
                                onTap: () {}))
                      ]);
                    },
                  )
                : Container(),
          ])),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
