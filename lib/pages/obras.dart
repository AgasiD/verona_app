// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_unnecessary_containers

import 'dart:async';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/chats.dart';
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
    this.obrasFiltradas = await _obras.obtenerObrasByUser(_pref.id);
    setState(() {});
    // if failed,use refreshFailed()
    print('obras filtradas ' + this.obrasFiltradas.length.toString());
    _refreshController.refreshCompleted();
    // _obras.notifyListeners();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    print(' On loading! ');
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    final _socketService = Provider.of<SocketService>(context, listen: false);
    _socketService.connect(_pref.id);
    super.initState();
  }

  List<Obra> obras = [];
  List<Obra> obrasFiltradas = [];
  int cant = 0;
  @override
  Widget build(BuildContext context) {
    ObraService _obras = Provider.of<ObraService>(context);
    final _socketService = Provider.of<SocketService>(context, listen: false);
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
        appBar: CustomAppBar(),
        floatingActionButton: Badge(
            showBadge: cant > 0,
            badgeContent: Text(
              cant.toString(),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            badgeColor: Colors.blue.shade200,
            animationDuration: Duration(seconds: 1),
            animationType: BadgeAnimationType.slide,
            child: FloatingActionButton(
              backgroundColor: Colors.grey[400],
              onPressed: () {
                Navigator.pushNamed(context, ChatsPage.routeName);
                //cant++;
                setState(() {});
              },
              child: Icon(
                Icons.chat,
                color: Colors.white,
              ),
            )),
        body: SafeArea(
            child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: () => _onRefresh(_obras),
                header: header,
                child: _SearchListView(obras: obras))));
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
                obras = snapshot.data as List<Obra>;
                obrasFiltradas = obras;
                if (obras.length > 0) {
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
                            hintText: 'Madrid..',
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
                                      setState(() {});
                                    },
                                  )
                                : IconButton(
                                    icon: _pref.role == 1
                                        ? Icon(Icons.add)
                                        : Container(),
                                    onPressed: _pref.role == 1
                                        ? () {
                                            Navigator.pushNamed(
                                                context, ObraForm.routeName,
                                                arguments: {
                                                  'formName': ObraForm.routeName
                                                });
                                          }
                                        : null,
                                  ),
                            textController: obrasTxtController,
                            onChange: (text) {
                              obrasFiltradas = widget.obras
                                  .where((obra) => obra.nombre
                                      .toLowerCase()
                                      .contains(text.toLowerCase()))
                                  .toList();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                        physics:
                            NeverScrollableScrollPhysics(), // esto hace que no rebote el gridview al scrollear
                        padding: EdgeInsets.only(top: 25),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: obrasFiltradas.length,
                        itemBuilder: (BuildContext ctx, index) {
                          return _obraCard(context, obrasFiltradas[index]);
                        })
                  ]);
                } else {
                  return Container(
                    margin: EdgeInsets.only(top: 300),
                    child: Center(
                      child: Text(
                        'Aún no hay obras asignadas ',
                        style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                      ),
                    ),
                  );
                }
              }
            })));
  }

  Container _obraCard(BuildContext context, Obra obra) {
    final NetworkImage imagen = obra.imageId != ''
        ? NetworkImage(
            'https://www.emsevilla.es/wp-content/uploads/2020/10/no-image-1.png')
        : NetworkImage(
            'https://drive.google.com/uc?export=view&id=${obra.imageId}');
    return Container(
      height: 300,
      width: 300,
      child: GestureDetector(
        onTap: (() => Navigator.pushNamed(context, ObraPage.routeName,
            arguments: {'obraId': obra.id})),
        child: Stack(
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
                                child: Image(
                                    image: AssetImage('assets/image.png')));
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
      ),
    );
  }

  NetworkImage _CustomNetworkImage(String imageId) {
    return NetworkImage('https://drive.google.com/uc?id=$imageId');
  }
}
