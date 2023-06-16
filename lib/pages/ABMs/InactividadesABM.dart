import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/inactividadBD.dart';
import 'package:verona_app/pages/forms/inactividadesBD.dart';
import 'package:verona_app/pages/forms/inactividades_masiva.dart';
import 'package:verona_app/pages/obra.dart';
import 'package:verona_app/services/inactividad_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';
import 'package:badges/badges.dart' as badges;

class InactividadesABM extends StatefulWidget {
  InactividadesABM({Key? key}) : super(key: key);
  static final routeName = 'InactividadesABM';

  @override
  State<InactividadesABM> createState() => _InactividadesABMState();
}

class _InactividadesABMState extends State<InactividadesABM>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;

  int index = 0;

  @override
  Widget build(BuildContext context) {
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.index = index;
    final _pref = new Preferences();
    final _obraService = Provider.of<ObraService>(context);
    final _inactividadService = Provider.of<InactividadService>(context);
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Helper.brandColors[1],
          appBar: AppBar(
            title: Text('Control de inactividades'),
            backgroundColor: Helper.brandColors[2],
            bottom: TabBar(
              controller: _tabCtrl,
              splashFactory: NoSplash.splashFactory,
              dividerColor: Helper.brandColors[8],
              indicatorColor: Helper.brandColors[8],
              tabs: [
                Tab(
                    child: Text(
                  'Por obras',
                  style: TextStyle(color: Helper.brandColors[8]),
                )),
                Tab(
                    child: Text(
                  'Inactividades',
                  style: TextStyle(color: Helper.brandColors[8]),
                )),
              ],
            ),
          ),
          body: FutureBuilder(
              future: _obraService.obtenerControlInactividades(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Loading(mensaje: 'Cargando obras...');

                final response = snapshot.data as MyResponse;
                if (response.fallo)
                  return Center(
                    child: Text(response.error),
                  );

                final obras = response.data;
                (obras as List)
                    .sort((a, b) => a['nombre'].compareTo(b['nombre']));
                return TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _InactividadesView(
                      obras: obras,
                    ),
                    FutureBuilder(
                        future: _inactividadService.obtenerInactividades(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Loading(
                              mensaje: "Cargando información...",
                            );
                          }
                          final response = snapshot.data as MyResponse;
                          if (response.fallo)
                            return ErrorWidget(response.error);

                          final obras = (response.data as List)
                              .map((a) => InactividadBD.fromMap(a))
                              .toList();
                          // return Container();
                          return _InactividadesBDView(
                            inactividades: obras,
                          );
                        })
                  ],
                );
              }),
        ));
  }
}

class _InactividadesView extends StatefulWidget {
  _InactividadesView({Key? key, required this.obras}) : super(key: key);

  List<dynamic> obras;
  @override
  State<_InactividadesView> createState() => _PendientesViewState();
}

class _PendientesViewState extends State<_InactividadesView> {
  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context, listen: false);

    return widget.obras.length > 0
        ? Scaffold(
            backgroundColor: Helper.brandColors[1],
            body: ListView.builder(
                itemCount: widget.obras.length,
                itemBuilder: (context, i) {
                  final obra = widget.obras[i];
                  int cantTotalDias = 0;
                  (obra['inactividades'] as List).forEach((element) {
                    cantTotalDias += element['diasInactivos'] == null ? 1 : element['diasInactivos'] as int ;
                  });
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Helper.brandColors[9], width: .2),
                          borderRadius: BorderRadius.circular(5),
                          color: Helper.brandColors[0],
                        ),
                        child: ListTile(
                          onTap: () {
                            
                            //  Navigator.pushNamed(context, ObraPage.routeName, arguments: {"obraId": obra['id']});
                          },
                          title: Text(
                              '${obra['nombre'].toString().toUpperCase()} | ${obra['barrio'].toString().toUpperCase()} '),
                          trailing: Text(
                            cantTotalDias.toString(),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          textColor: Helper.brandColors[5],
                        ),
                      ),
                      obra['inactividades'].length > 0
                          ? ListView.builder(
                              itemCount: obra['inactividades'].length,
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                final esPar = index % 2 == 0;
                                final arg = {
                                  'id': obra['inactividades'][index]['id'],
                                  'obraId': obra['id']
                                };
                                final txtFecha =
                                    'Fecha ${obra['inactividades'][index]['fecha']}';

                                return Column(
                                  children: [
                                    _CustomListTile(
                                      esPar: false,
                                      title:
                                          "${obra['inactividades'][index]['nombre'].toString().toUpperCase()}",
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            txtFecha.toUpperCase(),
                                            style: TextStyle(
                                                color: Helper.brandColors[8]
                                                    .withOpacity(.8)),
                                          ),
                                           Text(
                                            obra['inactividades'][index]['nombreUsuario'],
                                            style: TextStyle(
                                                color: Helper.brandColors[8]
                                                    .withOpacity(.8)),
                                          ),
                                        ],
                                      ),
                                      avatar: "1",
                                      fontSize: 18,
                                      trailing: Text(
                                        (obra["inactividades"][index]['diasInactivos'] == null ? 1 : obra["inactividades"][index]['diasInactivos'] )


                                            .toString(),
                                        style: TextStyle(
                                            color: Helper.brandColors[3],
                                            fontSize: 17),
                                      ),
                                      // onTap: true,
                                      // actionOnTap: () => Navigator.pushNamed(
                                      //     context, InactividadesForm.routeName,
                                      //     arguments: arg),
                                    ),
                                    index != obra['inactividades'].length - 1
                                        ? Divider(
                                            color: Helper.brandColors[8],
                                          )
                                        : Container()
                                  ],
                                );
                              })
                          : ListTile(
                              title: Text(
                                'No hay inactividades',
                                style: TextStyle(
                                    color: Helper.brandColors[3], fontSize: 19),
                              ),
                            )
                    ],
                  );
                }),
            floatingActionButton: 
            CustomNavigatorButton(
            accion: () {
                Navigator.pushNamed(context, InactividadesMasivaForm.routeName,
                    arguments: {
                      "obras": widget.obras
                          .map((e) => {"nombre": e['nombre'], "id": e['id']})
                          .toList()
                    });
              },
            icono: Icons.add,
            showNotif: false,
          )
            
          
          )
        : Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Text(
                'No hay inactividades',
                style: TextStyle(color: Helper.brandColors[3], fontSize: 19),
              ),
            ),
          );
  }
}

class _CustomListTile extends StatelessWidget {
  bool esPar;
  String title;
  Widget subtitle;
  String avatar;
  bool onTap;
  bool textAvatar;
  bool esNovedad;
  double padding;
  double fontSize;
  IconData iconAvatar;
  Widget? trailing;

  Function()? actionOnTap;
  _CustomListTile(
      {Key? key,
      required this.esPar,
      required this.title,
      required this.subtitle,
      required this.avatar,
      this.esNovedad = false,
      this.textAvatar = true,
      this.iconAvatar = Icons.abc,
      this.padding = 0,
      this.onTap = false,
      this.fontSize = 10,
      this.trailing = null,
      this.actionOnTap = null})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = esPar ? Helper.brandColors[2] : Helper.brandColors[1];
    Color colorPrioridad = Colors.green.shade100;
    ;
    switch (int.parse(avatar)) {
      case 1:
        colorPrioridad = Colors.green.shade200;
        break;
      case 2:
        colorPrioridad = Colors.yellow.shade200;
        break;
      case 3:
        colorPrioridad = Colors.red.shade200;
        break;
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: _color, borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(title,
                  style: TextStyle(
                      color: Helper.brandColors[5], fontSize: fontSize)),
              subtitle: subtitle,
              trailing: onTap
                  ? Container(
                      alignment: Alignment.centerRight,
                      width: 55,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          esNovedad
                              ? badges.Badge(
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
                      ))
                  : trailing != null
                      ? trailing
                      : null,
              onTap: actionOnTap,
              leading: Icon(
                Icons.work_off_outlined,
                color: Helper.brandColors[3],
              ),
            ),
          ),
        ],
      ),
    );
    ;
  }
}

class _InactividadesBDView extends StatefulWidget {
  _InactividadesBDView({Key? key, required this.inactividades})
      : super(key: key);

  List<InactividadBD> inactividades;

  @override
  State<_InactividadesBDView> createState() => _InactividadesBDViewState();
}

class _InactividadesBDViewState extends State<_InactividadesBDView> {
  bool editar = false;
  late InactividadService _inactividadService;
  @override
  Widget build(BuildContext context) {
    _inactividadService = Provider.of<InactividadService>(context);

    final _pref = new Preferences();

    Map<int, FlexColumnWidth> columnWidths = _pref.role == 2 ? {
      0: FlexColumnWidth(3),
      1: FlexColumnWidth(1),
      2: FlexColumnWidth(1),
    } : 
    { 0: FlexColumnWidth(3),
      1: FlexColumnWidth(1),};

    var textTitleStyle = TextStyle(
        color: Helper.brandColors[5],
        fontWeight: FontWeight.bold,
        fontSize: 12);
    List<TableRow> datos = [
      TableRow(
          decoration: BoxDecoration(
            color: Helper.brandColors[1],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Descripción',
                style: textTitleStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Dias',
                style: textTitleStyle,
              ),
            ),
            Visibility(
              visible: _pref.role == 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  editar ? 'Guardar' : 'Borrar',
                  style: textTitleStyle,
                ),
              ),
            )
          ])
    ];
    var controllers = [];
    for (int i = 0; i < widget.inactividades.length; i++) {
      var txtDescri = TextEditingController(
          text: widget.inactividades[i].nombre.toString());
      var txtOrden = TextEditingController(
          text: widget.inactividades[i].diasInactivos.toString());

      var row = TableRow(
          decoration: BoxDecoration(color: Helper.brandColors[2]),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextField(
                controller: txtDescri,
                style: TextStyle(color: Helper.brandColors[3]),
                onEditingComplete: () => print('lostFocus'),
                onChanged: (text) => widget.inactividades[i].nombre = text,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              expands: false,
              controller: txtOrden,
              style: TextStyle(color: Helper.brandColors[3]),
              onEditingComplete: () => print('lostFocus'),
              onChanged: (text) => widget.inactividades[i].nombre = text,
              decoration: InputDecoration(border: InputBorder.none),
            ),
            
             _pref.role == 2 ? 
               IconButton(
                  onPressed: editar
                      ? () => guardarInactividad()
                      : () => borrarInactividad(i),
                  icon: editar
                      ? Icon(
                          Icons.check,
                          color: Colors.green[100],
                        )
                      : Icon(
                          Icons.highlight_remove_sharp,
                          color: Colors.red[500],
                        )) : Container(),
          ]);
      datos.add(row);
    }

    return Scaffold(
      backgroundColor: Helper.brandColors[1],
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          margin: EdgeInsets.only(top: 15),
          child: Table(columnWidths: columnWidths, children: datos)),
      floatingActionButton: Visibility(
          child: CustomNavigatorButton(
            accion: () async {
                InactividadBD? inactividadResponse = await Navigator.pushNamed(
                        context, InactividadesBDForm.routeName, arguments: {})
                    as InactividadBD?;
                widget.inactividades.add(inactividadResponse!);
                setState(() {});
              },
            icono: Icons.add,
            showNotif: false,
          )),
    );
  }

  borrarInactividad(int index) async {
    String nombre = widget.inactividades[index].nombre;
    bool confirm =
        await openDialogConfirmationReturn(context, "Seguro que quiere borrar");
    if (!confirm) return;
    final response =
        await _inactividadService.borrar(widget.inactividades[index].id);
    if (response.fallo) {
      openAlertDialog(context, response.error);
      return;
    }
    Helper.showSnackBar(context, 'Inactividad borrada: $nombre', null,
        Duration(milliseconds: 1300), null);
    widget.inactividades.removeAt(index);
    setState(() {});
  }

  guardarInactividad() {
    editar = false;
    setState(() {});
  }
}
