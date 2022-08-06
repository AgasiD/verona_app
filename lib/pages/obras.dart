// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_unnecessary_containers

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ObrasPage extends StatefulWidget {
  ObrasPage({Key? key}) : super(key: key);
  static const String routeName = 'obras';

  @override
  State<ObrasPage> createState() => _ObrasPageState();
}

class _ObrasPageState extends State<ObrasPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _pref = new Preferences();

  void _onRefresh(ObraService _obras) async {
    final response = await _obras.obtenerObrasByUser(_pref.id);
    if (response.fallo) {
      _refreshController.loadFailed();
      openAlertDialog(context, 'Error al actualizar obras');
    } else {
      this.obras =
          (response.data as List<dynamic>).map((e) => Obra.fromMap(e)).toList();
      this.obrasFiltradas = obras;
    }
    setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _obras.notifyListeners();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    final _socketService = Provider.of<SocketService>(context, listen: false);
    final _pref = new Preferences();
    // _socketService.connect(_pref.id);
  }

  List<Obra> obras = [];
  List<Obra> obrasFiltradas = [];
  int cant = 0;
  @override
  Widget build(BuildContext context) {
    ObraService _obras = Provider.of<ObraService>(context);
    final _socketService = Provider.of<SocketService>(context, listen: false);
    _socketService.connect(_pref.id);
    final header;
    Platform.isIOS
        ? header = WaterDropHeader()
        : header = MaterialClassicHeader();
    final textStyle = TextStyle(fontSize: 16, color: Colors.grey[600]);
    final menu = [
      {'name': 'Nuevo propietario', 'route': PropietarioForm.routeName},
      {'name': 'Nuevo personal', 'route': MiembroForm.routeName},
    ];

    return Scaffold(
      drawer: CustomDrawer(textStyle: textStyle, menu: menu),
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
            child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: () => _onRefresh(_obras),
                header: header,
                child: _SearchListView(obras: obras))),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }

  Padding _obraCard(BuildContext context, Obra obra) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, ObraPage.routeName,
            arguments: {'nameForm': PedidoForm.routeName, 'obraId': obra.id}),
        child: Card(
          elevation: 5,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                // child: Hero(
                //   tag: 'obra',
                child: FadeInImage(
                    width: MediaQuery.of(context).size.width * .47,
                    image: AssetImage(
                        'assets/image.png'), //NetworkImage(obra.imagen),
                    placeholder: AssetImage('assets/image.png')),
                // ),
              ),
              ListTile(
                title: Text(obra.nombre),
                subtitle: Text(
                    'Tareas preliminares'), //obra.estadios.last.descripcion
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchListView extends StatefulWidget {
  _SearchListView({Key? key, required this.obras}) : super(key: key);
  List<Obra> obras;

  @override
  State<_SearchListView> createState() => __SearchListViewState();
}

TextEditingController obrasTxtController = new TextEditingController();

class __SearchListViewState extends State<_SearchListView> {
  late List<Obra> obras;
  late List<Obra> obrasFiltradas;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _obras = Provider.of<ObraService>(context);
    final _pref = new Preferences();
    return SingleChildScrollView(
        child: FutureBuilder(
            future: _obras.obtenerObrasByUser(_pref.id),
            builder: ((context, snapshot) {
              if (snapshot.data == null) {
                return Loading(mensaje: 'Recuperando obras');
              } else {
                final response = snapshot.data as MyResponse;

                if (!response.fallo) {
                  obras = (response.data as List<dynamic>)
                      .map((e) => Obra.fromMap(e))
                      .toList();
                  obrasFiltradas = obras;
                  return _CustomObras(
                    obras: obras,
                    obrasFiltradas: obras,
                  );
                } else {
                  return Container(
                    child: Text(
                      response.error,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                  openAlertDialog(context, response.error);
                }
              }
            })));
  }
}

class _CustomObras extends StatefulWidget {
  List<Obra> obras;
  List<Obra> obrasFiltradas;
  _CustomObras({Key? key, required this.obras, required this.obrasFiltradas})
      : super(key: key);

  @override
  State<_CustomObras> createState() => _CustomObrasState();
}

class _CustomObrasState extends State<_CustomObras> {
  final _pref = new Preferences();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        margin: EdgeInsets.only(top: 20),
        width: MediaQuery.of(context).size.width * .95,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomInput(
              width: MediaQuery.of(context).size.width * .95,
              hintText: 'Madrid...',
              icono: Icons.search,
              textInputAction: TextInputAction.search,
              validaError: false,
              iconButton: obrasTxtController.text != ''
                  ? IconButton(
                      splashColor: null,
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: Colors.red.withAlpha(200),
                      ),
                      onPressed: () {
                        obrasTxtController.text = '';
                        widget.obrasFiltradas = widget.obras;
                        setState(() {});
                      },
                    )
                  : IconButton(
                      color: Helper.brandColors[4],
                      icon: _pref.role == 1 ? Icon(Icons.add) : Container(),
                      onPressed: _pref.role == 1
                          ? () {
                              Navigator.pushNamed(context, ObraForm.routeName,
                                  arguments: {'formName': ObraForm.routeName});
                            }
                          : null,
                    ),
              textController: obrasTxtController,
              onChange: (text) {
                widget.obrasFiltradas = widget.obras
                    .where((obra) =>
                        obra.nombre.toLowerCase().contains(text.toLowerCase()))
                    .toList();
                setState(() {});
              },
            ),
          ],
        ),
      ),
      widget.obras.length > 0
          ? ListView.builder(
              physics:
                  NeverScrollableScrollPhysics(), // esto hace que no rebote el gridview al scrollear
              padding: EdgeInsets.only(top: 25),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: widget.obrasFiltradas.length,
              itemBuilder: (BuildContext ctx, index) {
                return _obraCard(context, widget.obrasFiltradas[index]);
              })
          : Center(
              child: Text(
                'Aún no hay obras asignadas ',
                style: TextStyle(fontSize: 20, color: Colors.grey[400]),
              ),
            ),
    ]);
  }
}

Container _obraCard(BuildContext context, Obra obra) {
  var imagen = obra.imageId == ''
      ? Helper.imageNetwork(
          'https://www.emsevilla.es/wp-content/uploads/2020/10/no-image-1.png')
      : Helper.imageNetwork(
          'https://drive.google.com/uc?export=view&id=${obra.imageId}',
        );
  final porcent = (Random().nextDouble() * 100).round();
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    child: GestureDetector(
        onTap: (() => Navigator.pushNamed(context, ObraPage.routeName,
            arguments: {'obraId': obra.id})),
        child: Container(
          child: Card(
            elevation: 10,
            color: Helper.brandColors[2],
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .4,
                  child: Column(children: [
                    Text(obra.nombre,
                        style: TextStyle(
                            color: Helper.brandColors[3],
                            fontSize: 21,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 5,
                    ),
                    Text(obra.lote,
                        style: TextStyle(
                            fontSize: 18,
                            color: Helper.brandColors[8],
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Text('${porcent.toString()}%',
                              style: TextStyle(
                                  color: Helper.brandColors[3],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 3),
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: LinearProgressIndicator(
                              value: porcent.toDouble() / 100,
                              semanticsLabel: 'HoLA',
                              backgroundColor: Helper.brandColors[3],
                              color: Helper.brandColors[8],
                            ),
                          ),
                          // Text('${porcent.toString()}%',
                          //     style: TextStyle(
                          //         color: Helper.brandColors[3],
                          //         fontSize: 12,
                          //         fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text('Tareas preliminares',
                        style: TextStyle(color: Helper.brandColors[3])),
                  ]),
                ),
                Hero(
                  tag: obra.id,
                  child: FadeInImage(
                      width: MediaQuery.of(context).size.width * .47,
                      image: imagen,
                      imageErrorBuilder: (_, obj, st) {
                        return Container(
                            child: Image(
                                width: MediaQuery.of(context).size.width * .47,
                                image: AssetImage('assets/image.png')));
                      },
                      placeholder: AssetImage('assets/loading-image.gif')),
                ),
              ],
            ),
          ),
        )),
  );
}

NetworkImage _CustomNetworkImage(String imageId) {
  return NetworkImage('https://drive.google.com/uc?id=$imageId');
}

/*Stack(
        children: [
          Positioned(
              top: 0,
              right: 10,
              left: 10,
              height: 235,
              child: Container(
                child: ClipRRect(
                  //borderRadius: BorderRadius.all(Radius.circular(40)),
                  child: Hero(
                    tag: obra.nombre,
                    child: FadeInImage(
                        height: 190,
                        image: imagen,
                        imageErrorBuilder: (_, obj, st) {
                          return Container(
                              child:
                                  Image(image: AssetImage('assets/image.png')));
                        },
                        placeholder: AssetImage('assets/loading-image.gif')),
                  ),
                ),
              )),
          Positioned(
              top: 195,
              left: 75,
              right: 75,
              height: 75,
              child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(obra.nombre,
                          style: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold)),
                      Text('Tareas preliminares')
                    ]),
                width: 100,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black45,
                          blurRadius: 5,
                          offset: Offset(0, 3))
                    ],
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              )),
        ],
      ),
    */
