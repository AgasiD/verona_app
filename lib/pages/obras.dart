// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_unnecessary_containers

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/form.dart';
import 'package:verona_app/pages/forms/asignar_pedido.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/obra_service.dart';
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

  void _onRefresh(ObraService _obras) async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    print(' On Refresh! ');
    _obras.obtenerObras();
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

  @override
  Widget build(BuildContext context) {
    ObraService _obras = Provider.of<ObraService>(context);
    List<Obra> obras = [];
    List<Obra> obrasFiltradas = [];
    TextEditingController obrasTxtController = new TextEditingController();
    final header;
    Platform.isIOS
        ? header = WaterDropHeader()
        : header = MaterialClassicHeader();
    return Scaffold(
        appBar: CustomAppBar(),
        body: SafeArea(
            child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: () => _onRefresh(_obras),
                header: header,
                child: SingleChildScrollView(
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
                          hintText: 'Alaska...',
                          icono: Icons.search,
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
                                    Navigator.pushNamed(
                                        context, FormPage.routeName,
                                        arguments: {
                                          'formName': ObraForm.routeName
                                        });
                                  },
                                ),
                          textController: obrasTxtController,
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                      future: _obras.obtenerObras(),
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Container();
                        } else {
                          obras = snapshot.data as List<Obra>;
                          obrasFiltradas =
                              obras.getRange(0, obras.length).toList();

                          return ListView.builder(
                              physics:
                                  NeverScrollableScrollPhysics(), // esto hace que no rebote el gridview al scrollear
                              padding: EdgeInsets.only(top: 25),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: obrasFiltradas.length,
                              itemBuilder: (BuildContext ctx, index) {
                                return _obraCard(
                                    context, obrasFiltradas[index]);
                              });
                        }
                        ;
                      }),
                ])))));
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
