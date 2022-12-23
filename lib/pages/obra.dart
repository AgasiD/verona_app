import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/obra.dart';

import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/imagenes_gallery.dart';
import 'package:verona_app/pages/inactividades.dart';
import 'package:verona_app/pages/listas/equipo.dart';
import 'package:verona_app/pages/listas/etapas.dart';
import 'package:verona_app/pages/listas/pedidos_obra.dart';
import 'package:verona_app/pages/listas/propietarios.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ObraPage extends StatelessWidget {
  static const String routeName = 'obra';

  ObraPage({Key? key}) : super(key: key);
  late SocketService _socketService;
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final _service = Provider.of<ObraService>(context, listen: false);
    final _pref = new Preferences();
    final esDelivery = _pref.role == 6;
    _socketService = Provider.of<SocketService>(context);
    final obra = _service.obra;
    var imagen = obra.imageURL == ''
        ? Helper.imageNetwork(
            'https://www.emsevilla.es/wp-content/uploads/2020/10/no-image-1.png')
        : Helper.imageNetwork(obra.imageURL);

    return Scaffold(
        bottomNavigationBar: CustomNavigatorFooter(),
        body: Container(
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
                      child: ImageFade(
                        width: MediaQuery.of(context).size.width * .43,
                        image: NetworkImage(obra.imageURL),
                        loadingBuilder: (context, progress, chunkEvent) =>
                            Center(
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
                    ),
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
                            !esDelivery
                                ? _DiasView(obra: obra, obraId: obraId)
                                : Container(),
                            !esDelivery
                                ? Container(
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
                                                showNotif: tieneMensajeSinLeer(
                                                    obra.nombre, obra.chatI),
                                              )
                                            : Container(width: 60),
                                        CustomNavigatorButton(
                                          icono: Icons.chat,
                                          accion: () {
                                            _pref.role != 3
                                                ? openDialogConfirmation(
                                                    context, (ctx) {
                                                    Navigator.pushNamed(
                                                        ctx, ChatPage.routeName,
                                                        arguments: {
                                                          'chatId': obra.chatE
                                                        });
                                                  },
                                                    'Abrirá chat con propietarios')
                                                : Navigator.pushNamed(
                                                    context, ChatPage.routeName,
                                                    arguments: {
                                                        'chatId': obra.chatE
                                                      });
                                            ;
                                          },
                                          showNotif: tieneMensajeSinLeer(
                                              obra.nombre, obra.chatE),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            _pref.role == 1
                                ? Container(
                                    margin: EdgeInsets.only(top: 25),
                                    child: TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Color.fromARGB(
                                                        255, 122, 9, 1))),
                                        child: Container(
                                          width: 150,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                'Eliminar obra',
                                                style: TextStyle(
                                                    color:
                                                        Helper.brandColors[5]),
                                              ),
                                              Icon(
                                                Icons.delete,
                                                color: Helper.brandColors[5],
                                              )
                                            ],
                                          ),
                                        ),
                                        onPressed: () {
                                          openDialogConfirmation(context,
                                              (context) async {
                                            // eliminar obra
                                            openLoadingDialog(context,
                                                mensaje: 'Eliminando obra...');
                                            final response = await _service
                                                .eliminarObra(obraId);
                                            closeLoadingDialog(context);
                                            if (response.fallo) {
                                              openAlertDialog(context,
                                                  'Error al elimiar obra',
                                                  subMensaje: response.error);
                                            } else {
                                              openAlertDialog(context,
                                                  'Obra eliminada con éxito');
                                              Timer(
                                                  Duration(milliseconds: 750),
                                                  () => closeLoadingDialog(
                                                      context));
                                              Timer(
                                                  Duration(milliseconds: 750),
                                                  () => Navigator
                                                          .pushReplacementNamed(
                                                        context,
                                                        ObrasPage.routeName,
                                                      ));
                                            }
                                          }, 'Confirmar para eliminar obra');
                                        }),
                                  )
                                : Container()
                          ]),
                        ),
                      );
                    },
                    childCount: 1,
                  ),
                ),
              ],
            )));
  }

  tieneMensajeSinLeer(String obraId, String chatId) {
    {
      final dato = _socketService.novedades.indexWhere((novedad) =>
          novedad['tipo'] == 1 &&
          novedad['chatId'] == chatId &&
          novedad['menu'] == 7);
      return dato >= 0;
    }
  }
}

class _DiasView extends StatefulWidget {
  _DiasView({
    Key? key,
    required this.obra,
    required this.obraId,
  }) : super(key: key);

  final Obra obra;
  final String obraId;

  @override
  State<_DiasView> createState() => _DiasViewState();
}

class _DiasViewState extends State<_DiasView> {
  int diasEstimados = 0;
  int diasInactivos = 0;
  int diasTranscurridos = 0;
  bool ok = true, activeST = true;

  @override
  void dispose() {
    // TODO: implement dispose
    activeST = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _service = Provider.of<ObraService>(context);
    if (ok) {
      ok = false;

      Future.delayed(Duration(milliseconds: 1500), () {
        diasEstimados = widget.obra.diasEstimados;
        diasInactivos = widget.obra.diasInactivos.length;
        diasTranscurridos = widget.obra.diasTranscurridos;
        if (activeST) setState(() {});
      });
    }
    return Container(
      margin: EdgeInsets.only(top: 25),
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              AnimatedFlipCounter(
                wholeDigits: widget.obra.diasEstimados < 100 ? 2 : 3,
                duration: Duration(seconds: 1),
                value: diasEstimados, // pass in a value like 2014
                textStyle: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Helper.brandColors[8]),
              ),
              Text(
                'Días estimados',
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
          // Column(
          //   children: [
          //     AnimatedFlipCounter(
          //       wholeDigits: widget.obra.diasTranscurridos < 10
          //           ? 1
          //           : widget.obra.diasTranscurridos < 100
          //               ? 2
          //               : 3,
          //       duration: Duration(seconds: 1),
          //       value: diasTranscurridos, // pass in a value like 2014
          //       textStyle: TextStyle(
          //           fontSize: 23,
          //           fontWeight: FontWeight.bold,
          //           color: Helper.brandColors[8]),
          //     ),
          //     Text(
          //       'Días transcurridos',
          //       style: TextStyle(
          //           fontSize: 13,
          //           fontWeight: FontWeight.w400,
          //           color: Helper.brandColors[5]),
          //     )
          //   ],
          // ),
          VerticalDivider(
            width: 25,
            color: Colors.black45,
            indent: 15,
            endIndent: 15,
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, InactividadesPage.routeName,
                  arguments: {'obraId': widget.obraId});
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
            ),
            child: Column(children: [
              AnimatedFlipCounter(
                wholeDigits: widget.obra.diasInactivos.length < 10
                    ? 1
                    : widget.obra.diasInactivos.length < 100
                        ? 2
                        : 3,
                duration: Duration(seconds: 1),
                value: diasInactivos, // pass in a value like 2014
                textStyle: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Helper.brandColors[8]),
              ),
              Text(
                'Días inactivos',
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
    final _pref = new Preferences();
    //Desplegable de propietarios
    if (_pref.role != 6) {
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
        icon: Icons.groups_outlined,
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
        icon: Icons.file_copy_outlined,
        list: 3,
        titulo: 'Documentos',
        values: [].toList(),
        accion: () async {
          if (_pref.role == 3) {
            final Uri _url = Uri.parse(
                'https://drive.google.com/drive/u/0/folders/${obra.rootDriveCliente}');
            if (await canLaunchUrl(_url))
              await launchUrl(_url, mode: LaunchMode.externalApplication);
            else
              openAlertDialog(context, 'No se puede visualizar el documento');
          } else {
            Navigator.pushNamed(context, ImgGalleryPage.routeName,
                arguments: {'driveId': obra.driveFolderId});
          }
        },
      );
      items.add(doc);

      final imgs = Item(
        icon: Icons.image_outlined,
        list: 4,
        titulo: 'Galeria de imagenes',
        values: [].toList(),
        accion: () async {
          if (_pref.role == 3) {
            final Uri _url = Uri.parse(
                'https://drive.google.com/drive/u/0/folders/${obra.folderImagesCliente}');
            if (await canLaunchUrl(_url))
              await launchUrl(_url, mode: LaunchMode.externalApplication);
            else
              openAlertDialog(context, 'No se puede visualizar el documento');
          } else {
            Navigator.pushNamed(context, ImgGalleryPage.routeName,
                arguments: {'driveId': obra.folderImages});
          }
        },
      );
      items.add(imgs);

      final status = Item(
        icon: Icons.account_tree_outlined,
        list: 5,
        titulo: 'Control de obra',
        values: [].toList(),
        accion: () => Navigator.pushNamed(context, EtapasObra.routeName),
      );
      items.add(status);

      final certificados = Item(
        icon: Icons.library_add_check_outlined,
        list: 5,
        titulo: 'Certificados de obra',
        values: [].toList(),
        accion: () => {},
      );
      items.add(certificados);

      final pedidos = Item(
        icon: Icons.request_page_outlined,
        list: 6,
        titulo: 'Pedidos',
        values: [].toList(),
        accion: () {
          Navigator.pushNamed(
            context,
            PedidoList.routeName,
          );
        },
      );
      items.add(pedidos);
    } else {
      final pedidos = Item(
        icon: Icons.request_page_outlined,
        list: 6,
        titulo: 'Pedidos',
        values: [].toList(),
        accion: () {
          Navigator.pushNamed(context, PedidoList.routeName,
              arguments: {'deliveryId': _pref.id});
        },
      );
      items.add(pedidos);
    }
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
    List<Widget> children = List.from(widget.data.map((e) => FadeInLeft(
          delay: Duration(milliseconds: e.list * 75),
          child: CaracteristicaButton(
              action: e.accion, text: e.titulo, icon: e.icon, listItem: e.list),
        )));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: children),
    );
  }
}

class CaracteristicaButton extends StatelessWidget {
  CaracteristicaButton(
      {Key? key,
      required this.action,
      required this.text,
      required this.icon,
      required this.listItem})
      : super(key: key);

  String text;
  IconData icon;
  int listItem;
  Function() action;

  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketService>(context);
    final _obraService = Provider.of<ObraService>(context, listen: false);

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
          trailing: Container(
            alignment: Alignment.centerRight,
            width: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                tieneNovedad(_obraService.obra.id, listItem, _socketService)
                    ? Badge(
                        badgeColor: Helper.brandColors[8],
                        badgeContent: Padding(
                          padding: const EdgeInsets.all(0),
                          // child: Text(badgeData.toString()),
                        ),
                      )
                    : Container(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Helper.brandColors[3],
                ),
              ],
            ),
          ),
          title:
              Text(text, style: TextStyle(color: Colors.white, fontSize: 17)),
        ),
      ),
    );
    ;
  }

  tieneNovedad(String obraId, int listItem, SocketService _socketService) {
    final dato = _socketService.novedades.indexWhere((novedad) =>
        novedad['tipo'] == 1 &&
        novedad['obraId'] == obraId &&
        novedad['menu'] == listItem);
    return dato >= 0;
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
          this.descripcion == '' ? 'Sin descripción de obra' : this.descripcion,
          style: TextStyle(color: Helper.brandColors[3], fontSize: 16),
        ),
        SizedBox(
          height: 25,
        )
      ]),
    );
  }
}
