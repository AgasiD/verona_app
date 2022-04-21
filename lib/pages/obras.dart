// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_unnecessary_containers

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/chats.dart';
import 'package:verona_app/pages/form.dart';
import 'package:verona_app/pages/forms/asignar_pedido.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/forms/pedido.dart';
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
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 2000));
    print(' On Refresh! ');
    _obras.obtenerObrasByUser(_pref.id);
    setState(() {});

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    print(' On loading! ');
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  List<Obra> obras = [];
  List<Obra> obrasFiltradas = [];
  @override
  Widget build(BuildContext context) {
    ObraService _obras = Provider.of<ObraService>(context);
    final _socketService = Provider.of<SocketService>(context);
    _socketService.connect(_pref.id);
    final header;
    Platform.isIOS
        ? header = WaterDropHeader()
        : header = MaterialClassicHeader();

    return Scaffold(
        appBar: CustomAppBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, ChatsPage.routeName);
          },
          child: Icon(Icons.chat),
        ),
        body: SafeArea(
            child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: () => _onRefresh(_obras),
                header: header,
                child: FutureBuilder(
                    future: _obras.obtenerObrasByUser(_pref.id),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Loading();
                      } else {
                        obras = snapshot.data as List<Obra>;
                        obrasFiltradas =
                            obras.getRange(0, obras.length).toList();
                        return _SearchListView(obras: obras);
                      }
                    }))));
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
  List<Obra> obrasFiltradas = [];
  @override
  void initState() {
    super.initState();
    this.obrasFiltradas = this.widget.obras;
  }

  @override
  Widget build(BuildContext context) {
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
              hintText: 'Madrid..',
              icono: Icons.search,
              validaError: false,
              iconButton: obrasTxtController.value == ''
                  ? IconButton(
                      icon: Icon(Icons.cancel_outlined),
                      onPressed: () {
                        obrasTxtController.text = '';
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Navigator.pushNamed(context, ObraForm.routeName,
                            arguments: {'formName': ObraForm.routeName});
                      },
                    ),
              textController: obrasTxtController,
              onChange: (text) {
                obrasFiltradas = widget.obras
                    .where((obra) =>
                        obra.nombre.toLowerCase().contains(text.toLowerCase()))
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
    ]));
  }

  Container _obraCard(BuildContext context, Obra obra) {
    final NetworkImage imagen = obra.imageId == ''
        ? NetworkImage(
            'https://www.emsevilla.es/wp-content/uploads/2020/10/no-image-1.png')
        : NetworkImage(
            //        'https://www.bbva.com/wp-content/uploads/2021/04/casas-ecolo%CC%81gicas_apertura-hogar-sostenibilidad-certificado--1024x629.jpg');
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
