// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_unnecessary_containers

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/listas/personal_adm.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/pages/perfil.dart';
import 'package:verona_app/services/notifications_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/services/usuario_service.dart';
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

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (NotificationService.initMessage != null) {
        final notif = NotificationService.initMessage;
        NotificationService.initMessage = null;

        final type = notif!.data['type'];
        switch (type) {
          case 'message':
            Navigator.pushNamed(context, ChatPage.routeName, arguments: {
              "chatId": notif.data["chatId"],
              "chatName": notif.data["chatName"]
            });
            break;
          case 'new-obra':
            //Si es una nueva obra
            if (notif.data["type"] == 'new-obra') {
              final _obraService =
                  Provider.of<ObraService>(context, listen: false);
              _obraService.notifyListeners();
            }
            Navigator.pushNamed(context, ObraPage.routeName,
                arguments: {"obraId": notif.data["obraId"]});
            break;

          case 'pedido':
            final _obraService =
                Provider.of<ObraService>(context, listen: false);
            if (_obraService.obra.id == '') {
              // final obra = await _obraService.obtenerObra(notif.data['obraId']);
              // _obraService.obra = obra;
            }
            Navigator.pushNamed(context, PedidoForm.routeName, arguments: {
              'pedidoId': notif.data['pedidoId'],
              'obraId': notif.data['obraId'],
            });
            break;
        }
      }
    });
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
    final textStyle = TextStyle(fontSize: 16, color: Helper.brandColors[4]);
    final menu = [
      {
        'icon': Icons.person_pin_rounded,
        'name': 'Mi perfil',
        'route': PerfilPage.routeName,
        'args': {'usuarioId': _pref.id}
      },
      {
        'icon': Icons.person_add_alt_sharp,
        'name': 'Nuevo propietario',
        'route': PropietarioForm.routeName
      },
      {
        'icon': Icons.group_sharp,
        'name': 'Personal',
        'route': PersonalADM.routeName
      },
    ];
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

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
  Widget build(BuildContext context) {
    final _obras = Provider.of<ObraService>(context);
    final _pref = new Preferences();
    return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              hintText: 'Nombre de proyecto',
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
      Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 17, top: 10, bottom: 10),
            child: Text(
              '¡Hola, ${(_pref.nombre.split(' ')[0])}!',
              style: TextStyle(
                  fontSize: 18,
                  color: Helper.brandColors[8],
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
      widget.obras.length > 0
          ? ListView.builder(
              physics:
                  NeverScrollableScrollPhysics(), // esto hace que no rebote el gridview al scrollear
              padding: EdgeInsets.only(top: 5),
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
  var imagen = obra.imageURL == ''
      ? Helper.imageNetwork(
          'https://www.emsevilla.es/wp-content/uploads/2020/10/no-image-1.png')
      : Helper.imageNetwork(obra.imageURL
          // 'https://drive.google.com/uc?export=view&id=${obra.imageId}',
          );
  final _socketService = Provider.of<SocketService>(context);

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 15),
    child: GestureDetector(
        onTap: (() => Navigator.pushNamed(context, ObraPage.routeName,
            arguments: {'obraId': obra.id})),
        child: Container(
          child: Card(
            elevation: 10,
            color: Helper.brandColors[2],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: MediaQuery.of(context).size.width * .47,
                  child: Stack(children: [
                    tieneNovedad(obra.id, _socketService)
                        ? Positioned(
                            top: 10,
                            left: 10,
                            child: Badge(
                              badgeColor: Helper.brandColors[8],
                              badgeContent: Padding(
                                padding: const EdgeInsets.all(0),
                                // child: Text(badgeData.toString()),
                              ),
                            ))
                        : Container(),
                    Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(obra.nombre,
                                  style: TextStyle(
                                      color: Helper.brandColors[3],
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(obra.lote,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Helper.brandColors[8],
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            // alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: [
                                Text(
                                    '${(obra.porcentajeRealizado).toString()}%',
                                    style: TextStyle(
                                        color: Helper.brandColors[3],
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 3),
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  child: LinearProgressIndicator(
                                    value: obra.porcentajeRealizado / 100,
                                    semanticsLabel: 'HoLA',
                                    backgroundColor: Helper.brandColors[3],
                                    color: Helper.brandColors[8],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Text('', style: TextStyle(color: Helper.brandColors[3])),
                        ]),
                  ]),
                ),
                // Hero(
                //   tag: obra.id,
                //   child:
                // Image(image: image, loadingBuilder: ),
                ImageFade(
                  width: MediaQuery.of(context).size.width * .43,
                  height: 120,
                  image: NetworkImage(obra.imageURL),
                  loadingBuilder: (context, progress, chunkEvent) => Center(
                      child: CircularProgressIndicator(
                    value: progress,
                    color: Helper.brandColors[8],
                  )),

                  // displayed when an error occurs:
                  errorBuilder: (context, error) => Container(
                    color: Helper.brandColors[8],
                    alignment: Alignment.center,
                    child: Image(image: AssetImage('assets/image.png')),
                  ),
                ),
              ],
            ),
          ),
        )),
  );
}

tieneNovedad(String obraId, SocketService _socketService) {
  final dato = _socketService.novedades.indexWhere(
      (novedad) => novedad['tipo'] == 1 && novedad['obraId'] == obraId);
  return dato >= 0;
}

NetworkImage _CustomNetworkImage(String url) {
  return NetworkImage(url);
}
