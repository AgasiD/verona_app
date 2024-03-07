import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/anotaciones.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/imagenes_gallery.dart';
import 'package:verona_app/pages/inactividades.dart';
import 'package:verona_app/pages/listas/documentos.dart';
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
  bool esPhone = true;
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final _service = Provider.of<ObraService>(context);
    final _pref = new Preferences();
    final esDelivery = _pref.role == 6;
    _socketService = Provider.of<SocketService>(context);
    final obra = _service.obra;
    var imagen = obra.imageURL == ''
        ? Helper.imageNetwork(
            'https://www.emsevilla.es/wp-content/uploads/2020/10/no-image-1.png')
        : Helper.imageNetwork(obra.imageURL);

    MediaQuery.of(context).size.width > 1000 ? esPhone = false : true;

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
                  expandedHeight: esPhone ? 220.0 : 450.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: obra.id,
                      child: CachedNetworkImage(
                          imageUrl: obra.imageURL,
                          imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.fill),
                                ),
                              ),
                          placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                color: Helper.brandColors[8],
                              )),
                          errorWidget: (context, url, error) => Container(
                                color: Helper.brandColors[8],
                                alignment: Alignment.center,
                                child: Image(
                                    image: AssetImage('assets/image.png')),
                              )),
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
                            _ObraBigrafy(obra: obra),
                            CaracteristicaObra(),
                            !esDelivery && _pref.role != 4
                                ? _DiasView(obra: obra, obraId: obraId)
                                : Container(),
                            !esDelivery && _pref.role != 4
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 25.0),
                                    child: Row(
                                      mainAxisAlignment: _pref.role == 3
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.spaceEvenly,
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
                                            : Container(width: 0),
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
                                          side: MaterialStateProperty.all(
                                            BorderSide(
                                              color: Color.fromARGB(
                                                  255, 164, 11, 0),

                                              width: 1.0, // Ancho del borde
                                            ),
                                          ),
                                        ),
                                        // backgroundColor:
                                        //     MaterialStateProperty.all(
                                        //         Color.fromARGB(
                                        //             255, 122, 9, 1))),
                                        child: Container(
                                          width: 150,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                'Eliminar obra',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 197, 13, 0),
                                                ),
                                              ),
                                              Icon(
                                                Icons.delete,
                                                color: Color.fromARGB(
                                                    255, 164, 11, 0),
                                              )
                                            ],
                                          ),
                                        ),
                                        onPressed: () async {
                                          await eliminarObra(context, obraId);
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

  eliminarObra(context, obraId) async {
    bool loading = true;
    final confirm = await openDialogConfirmationReturn(
        context, 'Confirmar para eliminar obra');
    if (!confirm) {
      loading = false;
      return;
    }
    try {
      final _obraService = Provider.of<ObraService>(context, listen: false);
      openLoadingDialog(context,
          mensaje: 'Eliminando obra... esto puede demorar');
      loading = true;
      final response = await _obraService.eliminarObra(obraId);
      closeLoadingDialog(context);
      loading = false;
      if (response.fallo) {
        openAlertDialog(context, 'Error al elimiar obra',
            subMensaje: response.error);
      } else {
        await openAlertDialogReturn(context, 'Obra eliminada con éxito');
        Navigator.pushReplacementNamed(
          context,
          ObrasPage.routeName,
        );
      }
    } catch (err) {
      loading ? closeLoadingDialog(context) : false;
      openAlertDialog(context, 'Error al eliminar obra',
          subMensaje: err.toString());
    }
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
    final _obraService = Provider.of<ObraService>(context);
    final diasTrans = widget.obra.getDiasTranscurridos();
    if (ok) {
      ok = false;

      Future.delayed(Duration(milliseconds: 1500), () {
        diasEstimados = widget.obra.diasEstimados;
        diasInactivos = widget.obra.cantDiasInactivos;
        diasTranscurridos = widget.obra.getDiasTranscurridos();
        if (activeST) setState(() {});
      });
    } else {
      diasEstimados = widget.obra.diasEstimados;
      diasInactivos = widget.obra.cantDiasInactivos;
      diasTranscurridos = widget.obra.getDiasTranscurridos();
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
                wholeDigits: widget.obra.diasEstimados.toString().length,
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
          Column(
            children: [
              AnimatedFlipCounter(
                wholeDigits: diasTrans.toString().length,
                duration: Duration(seconds: 1),

                value: diasTranscurridos, // pass in a value like 2014
                textStyle: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Helper.brandColors[8]),
              ),
              Text(
                'Días transcurridos',
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
    final _service = Provider.of<ObraService>(context);

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
          rolesAcceso: [1, 2, 3, 7],
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
        rolesAcceso: [1, 2, 3, 7],
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
            Navigator.pushNamed(context, DocumentosPage.routeName,
                arguments: {'driveId': obra.driveFolderId});
          }
        },
      );
      items.add(doc);

      final imgs = Item(
        icon: Icons.image_outlined,
        rolesAcceso: [1, 2, 3, 7],
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
        rolesAcceso: [1, 2, 3, 7],
        values: [].toList(),
        accion: () => Navigator.pushNamed(context, EtapasObra.routeName),
      );
      items.add(status);

      // final certificados = Item(
      //   icon: Icons.library_add_check_outlined,
      //   rolesAcceso: [1, 2, 7],
      //   list: 5,
      //   titulo: 'Certificados de obra',
      //   values: [].toList(),
      //   accion: () => {},
      // );
      // items.add(certificados);

      final certificados = Item(
        icon: Icons.format_list_numbered_outlined,
        rolesAcceso: [1, 2, 3, 4, 5, 6, 7],
        list: 5,
        titulo: 'Artículos de obra',
        values: [].toList(),
        accion: () async {
          if (obra.articulosId == '') {
            openAlertDialog(context, 'No hay documento asignado');
          } else {
            openLoadingDialog(context, mensaje: 'Cargando archivo...');
            final _obraService = Provider.of<ObraService>(context, listen: false);
            final response = await _obraService.obtenerObraArticuloFile(obra.id)
                as MyResponse;
            closeLoadingDialog(context);

            if (response.fallo) {
              openAlertDialog(context, 'Hubo en error al cargar el archivo.',
                  subMensaje: response.error);
              return;
            }
            final file = response.data;
            Uri _url;
            switch (file["mimeType"]) {
              case "application/vnd.google-apps.document":
                _url = Uri.parse(
                    'https://docs.google.com/document/d/${obra.articulosId}');
                break;
              default:
                _url = Uri.parse(
                    'https://docs.google.com/spreadsheets/d/${obra.articulosId}');
                break;
            }
            if (await canLaunchUrl(_url))
              await launchUrl(_url, mode: LaunchMode.externalApplication);
            else
              openAlertDialog(context, 'No se puede visualizar el documento');
          }
        },
      );
      items.add(certificados);

      final pedidos = Item(
        rolesAcceso: [1, 2, 4, 5, 6, 7],
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

      final anotaciones = Item(
        rolesAcceso: [1, 2, 4, 5, 6, 7],
        icon: Icons.edit_note_rounded,
        list: 8,
        titulo: 'Anotaciones',
        values: [].toList(),
        accion: () {
          Navigator.pushNamed(context, AnotacionesPage.routeName,
              arguments: {"obraId": obra.id});
        },
      );
      items.add(anotaciones);
    } else {
      final pedidos = Item(
        rolesAcceso: [1, 2, 7, 6],
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
              roles: e.rolesAcceso,
              action: e.accion,
              text: e.titulo,
              icon: e.icon,
              listItem: e.list),
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
      this.roles = const [1, 2, 3, 4, 5, 6, 7],
      required this.action,
      required this.text,
      required this.icon,
      required this.listItem})
      : super(key: key);

  List<int> roles;
  String text;
  IconData icon;
  int listItem;
  Function() action;

  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketService>(context);
    final _obraService = Provider.of<ObraService>(context, listen: false);
    if (!tieneAcceso()) return Container();

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
                    ? badges.Badge(
                        badgeColor: Helper.brandColors[8],
                        child: Padding(
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
    if (listItem == 6) {
      var a = 1;
    }
    final dato = _socketService.novedades.indexWhere((novedad) =>
        novedad['tipo'] == 1 &&
        novedad['obraId'] == obraId &&
        novedad['menu'] == listItem);

    return dato >= 0;
  }

  bool tieneAcceso() {
    final _pref = new Preferences();
    return roles.contains(_pref.role);
  }
}

class _ObraBigrafy extends StatelessWidget {
  Obra obra;

  _ObraBigrafy({
    Key? key,
    required this.obra,
  }) : super(key: key);

  late ObraService _obraService;

  @override
  Widget build(BuildContext context) {
    _obraService = Provider.of<ObraService>(context);

    final _pref = new Preferences();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 21),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  padding: EdgeInsets.all(0),
                  iconSize: 40,
                  alignment: Alignment.centerLeft,
                  onPressed: () => abrirMap(context),
                  icon: Icon(
                    Icons.location_on_outlined,
                    color: Helper.brandColors[8],
                  ),
                ),
                Text(this.obra.barrio,
                    style: TextStyle(
                        color: Helper.brandColors[5],
                        fontSize: 20,
                        fontWeight: FontWeight.w100)),
              ],
            ),
            _pref.role == 1
                ? IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, ObraForm.routeName,
                          arguments: {'obraId': obra.id});
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
            Helper.textGradient([
              Helper.brandColors[8],
              Helper.brandColors[9]
            ], this.obra.nombre, fontsize: 42.0),

            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(this.obra.lote,
                  style: TextStyle(
                      color: Helper.brandColors[5],
                      fontSize: 20,
                      fontWeight: FontWeight.w100)),
            ) // Lote del proyecto
          ],
        ),
        Divider(
          color: Helper.brandColors[8],
          thickness: 1,
        ),
        Text(
          this.obra.descripcion == ''
              ? 'Sin descripción de obra'
              : this.obra.descripcion,
          style: TextStyle(color: Helper.brandColors[3], fontSize: 16),
        ),
        SizedBox(
          height: 25,
        )
      ]),
    );
  }

  abrirMap(context) async {
    final availableMaps = await MapLauncher.installedMaps;
    if (_obraService.obra.longitud == null) {
      return;
    }

    if (availableMaps.length > 1) {
      var acciones = availableMaps.map((e) {
        return {
          "text": e.mapName,
          "default": true,
          "accion": () async {
            await e.showMarker(
              coords: Coords(
                  _obraService.obra.latitud!, _obraService.obra.longitud!),
              title: obra.nombre,
            );
          }
        };
      }).toList();

      openBottomSheet(
          context, 'Abrir mapa', 'Seleccionar aplicacion', acciones);
    } else {
      await availableMaps.first.showMarker(
        coords: Coords(_obraService.obra.latitud!, _obraService.obra.longitud!),
        title: obra.nombre,
      );
    }
  }
}
