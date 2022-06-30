import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/obra.dart';

import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/inactividades.dart';
import 'package:verona_app/pages/listas/equipo.dart';
import 'package:verona_app/pages/listas/propietarios.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ObraPage extends StatelessWidget {
  static const String routeName = 'obra';

  const ObraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final _service = Provider.of<ObraService>(context);
    final _pref = new Preferences();
    return Scaffold(
        bottomNavigationBar: CustomNavigatorFooter(),
        body: FutureBuilder(
            future: _service.obtenerObra(obraId),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Loading(
                  mensaje: 'Cargando Obra',
                );
              } else {
                final obra = snapshot.data as Obra;
                NetworkImage imagen = obra.imageId == ''
                    ? NetworkImage(
                        'https://www.emsevilla.es/wp-content/uploads/2020/10/no-image-1.png')
                    : NetworkImage(
                        'https://drive.google.com/uc?export=view&id=${obra.imageId}');

                return Container(
                    color: Helper.brandColors[1],
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar(
                          automaticallyImplyLeading: false,
                          backgroundColor: Helper.brandColors[2],
                          pinned: false,
                          snap: false,
                          floating: false,
                          expandedHeight: 220.0,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Hero(
                                tag: obra.id,
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
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                child: SingleChildScrollView(
                                  child: Column(children: [
                                    _ObraBigrafy(
                                      nombre: obra.nombre,
                                      barrio: obra.barrio,
                                      descripcion: obra.descripcion,
                                      lote: obra.lote.toString(),
                                      obraId: obraId,
                                    ),
                                    CaracteristicaObra(),
                                    _DiasView(obra: obra, obraId: obraId),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 25.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _pref.role != 3
                                              ? CustomNavigatorButton(
                                                  icono: Icons.groups_outlined,
                                                  accion: () {
                                                    Navigator.pushNamed(context,
                                                        ChatPage.routeName,
                                                        arguments: {
                                                          'chatId': obra.chatI
                                                        });
                                                  },
                                                  showNotif: true,
                                                )
                                              : Container(width: 60),
                                          CustomNavigatorButton(
                                            icono: Icons.chat,
                                            accion: () {
                                              openDialogConfirmation(context,
                                                  (ctx) {
                                                Navigator.pushNamed(
                                                    ctx, ChatPage.routeName,
                                                    arguments: {
                                                      'chatId': obra.chatE
                                                    });
                                              }, 'Abrirá chat con propietarios');
                                            },
                                            showNotif: true,
                                          )
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              );
                            },
                            childCount: 1,
                          ),
                        ),
                      ],
                    ));
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
      margin: EdgeInsets.only(top: 25),
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

    final obra = _service.obra as Obra;
    final _data = _generarItems(obra);
    return _CustomExpansion(
      data: _data,
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
      accion: () {},
    );
    items.add(doc);

    final status = Item(
      icon: Icons.account_tree,
      list: 2,
      titulo: 'Etapas',
      values: [].toList(),
      accion: () {},
    );
    items.add(status);

    final pedidos = Item(
      icon: Icons.request_page_outlined,
      list: 2,
      titulo: 'Pedidos',
      values: [].toList(),
      accion: () {},
    );
    items.add(pedidos);

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
    List<Widget> children =
        List.from(widget.data.map((e) => CaracteristicaButton(
              action: e.accion,
              text: e.titulo,
              icon: e.icon,
            )));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: children),
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

class _ObraBigrafy extends StatelessWidget {
  String nombre;
  String barrio;
  String lote;
  String descripcion;
  String obraId;

  _ObraBigrafy({
    Key? key,
    required this.nombre,
    required this.barrio,
    required this.descripcion,
    required this.lote,
    required this.obraId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _pref = new Preferences();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 21),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Helper.brandColors[8],
                  size: 40,
                ),
                Text(this.barrio,
                    style: TextStyle(
                        color: Helper.brandColors[5],
                        fontSize: 20,
                        fontWeight: FontWeight.w100)),
              ],
            ), // Barrio del proyecto
            _pref.role == 1
                ? IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, ObraForm.routeName,
                          arguments: {'obraId': obraId});
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Helper.brandColors[8],
                      size: 25,
                    ),
                  )
                : Container()
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Helper.textGradient(
                [Helper.brandColors[8], Helper.brandColors[9]], this.nombre,
                fontsize: 42.0),
            // Text(
            //   this.nombre,
            //   style: TextStyle(color: Helper.brandColors[8], fontSize: 42),
            // ), // Nombre del proyecto
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(this.lote,
                  style: TextStyle(color: Helper.brandColors[5], fontSize: 17)),
            ) // Lote del proyecto
          ],
        ),
        Divider(
          color: Helper.brandColors[8],
          thickness: 1,
        ),
        Text(
          this.descripcion,
          style: TextStyle(color: Helper.brandColors[3], fontSize: 16),
        ),
        SizedBox(
          height: 25,
        )
      ]),
    );
  }
}
