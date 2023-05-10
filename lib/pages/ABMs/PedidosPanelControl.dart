import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';
import 'package:badges/badges.dart' as badges;

class PedidosPanelControl extends StatefulWidget {
  PedidosPanelControl({Key? key}) : super(key: key);
  static final routeName = 'PedidosPanelControl';

  @override
  State<PedidosPanelControl> createState() => _PedidosPanelControlState();
}

class _PedidosPanelControlState extends State<PedidosPanelControl>
    with TickerProviderStateMixin {
   late TabController _tabCtrl;

  int index = 0;

  @override
  Widget build(BuildContext context) {
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.index = index;
    final _pref = new Preferences();
    final _obraService = Provider.of<ObraService>(context);
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Helper.brandColors[1],
          appBar: AppBar(
            title: Text('Control de pedidos'),
            backgroundColor: Helper.brandColors[2],
            bottom: TabBar(
              // controller: _tabCtrl,
              splashFactory: NoSplash.splashFactory,
              dividerColor: Helper.brandColors[8],
              indicatorColor: Helper.brandColors[8],
              tabs: [
                Tab(
                    child: Text(
                  'Pendientes',
                  style: TextStyle(color: Helper.brandColors[8]),
                )),
                Tab(
                    child: Text(
                  'Confirmados',
                  style: TextStyle(color: Helper.brandColors[8]),
                )),
                Tab(
                    child: Text(
                  'P. Entrega',
                  style: TextStyle(color: Helper.brandColors[8]),
                )),
              ],
            ),
          ),
          body: FutureBuilder(
              future: _obraService.obtenerPedidosPorObra(_pref.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Loading(mensaje: 'Cargando pedidos...');

                final response = snapshot.data as MyResponse;
                if (response.fallo)
                  return Center(
                    child: Text(response.error),
                  );

                final obras = response.data;

                final pendientes = obtenerPedidos(obras, 1);
                final confirmados = obtenerPedidos(obras, 2);
                final pEntrega = obtenerPedidos(obras, 3);
                return TabBarView(
                  //controller: _tabCtrl,
                  children: [
                    _PendientesView(
                      pendientes: pendientes,
                    ),
                    _PendientesView(
                      pendientes: confirmados,
                    ),
                    _PendientesView(
                      pendientes: pEntrega,
                    ),
                  ],
                );
              }),
        ));
  }

  obtenerPedidos(List<dynamic> obras, int estado) {
    var newObras = [];
    obras = obras.where((obra) => (obra['pedidos'] as List).length > 0).toList();
    obras.forEach((obra) {
      var filtrados = (obra["pedidos"] as List<dynamic>)
           .where((pedido) => pedido['estado'] == estado).toList();
           
      filtrados.length > 0 ? newObras.add({
        "nombre": obra["nombre"],
        "barrio": obra["barrio"],
        "obraId": obra["obraId"],
        "pedidos": filtrados 
      }) 
      : false;
    });
    return newObras;
    // return newObras.toList();
  }
}

class _PendientesView extends StatefulWidget {
  _PendientesView({Key? key, required this.pendientes}) : super(key: key);

  List<dynamic> pendientes;
  @override
  State<_PendientesView> createState() => _PendientesViewState();
}

late SocketService  _socketService;

class _PendientesViewState extends State<_PendientesView> {
  @override
  Widget build(BuildContext context) {
   final _obraService = Provider.of<ObraService>(context, listen: false);
   _socketService = Provider.of<SocketService>(context);

    return widget.pendientes.length > 0 
    ? ListView.builder(
      
      itemCount: widget.pendientes.length,
      itemBuilder: (context, i)  {
      final obra = widget.pendientes[i];

      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Helper.brandColors[9], width: .2),
            borderRadius: BorderRadius.circular(5),
            color: Helper.brandColors[0],
          ),
          child: ListTile(
            title: Text('${obra['nombre'].toString().toUpperCase()} | ${obra['barrio'].toString().toUpperCase()} '),
            textColor: Helper.brandColors[5],
          ),
        ),
        obra['pedidos'].length > 0
            ? ListView.builder(
                itemCount: obra['pedidos'].length,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  final esPar = index % 2 == 0;
                  final arg = {
                    'pedidoId': obra['pedidos'][index]['id'],
                    'obraId': obra['obraId']
                  };
                                    final txtFecha = 'Fecha Pedido ${Helper.getFechaFromTS(obra['pedidos'][index]['ts'])}';
                  final textSubtitle = obra['pedidos'][index]['fechaEstimada'] == ''
                      ? "${("Fecha deseada").toUpperCase()} ${obra['pedidos'][index]['fechaDeseada']}"
                      : "${("Fecha de entrega").toUpperCase()} ${obra['pedidos'][index]['fechaEstimada']}";
                  return Column(
                    children: [
                      _CustomListTile(
                        esNovedad: _tieneNovedad(obra['obraId'],
                            obra['pedidos'][index]['id']),
                        esPar: false,
                        title:
                            "${obra['pedidos'][index]['titulo'].toString().toUpperCase()}",
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                             Text(  txtFecha.toUpperCase(),
                              style: TextStyle(
                                  color: Helper.brandColors[8].withOpacity(.8)),),
                            Text(
                              textSubtitle.toUpperCase(),
                              style: TextStyle(
                                  color: Helper.brandColors[8].withOpacity(.8)),
                            ),
                            Text(
                              ('Por: ${obra['pedidos'][index]['usuario']['nombre']} ${obra['pedidos'][index]['usuario']['apellido']}')
                                 .toUpperCase(),
                              style: TextStyle(
                                  color: Helper.brandColors[8].withOpacity(.8)),
                            ),
                          ],
                        ),
                        avatar: obra['pedidos'][index]['prioridad'].toString(),
                        fontSize: 18,
                        onTap: true,
                        actionOnTap: () => Navigator.pushNamed(
                            context, PedidoForm.routeName,
                            arguments: arg),
                      ),
                      index != obra['pedidos'].length - 1
                          ? Divider(
                              color: Helper.brandColors[8],
                            )
                          : Container()
                    ],
                  );
                })
            : ListTile(
                title: Text(
                  'No hay pedidos',
                  style: TextStyle(color: Helper.brandColors[3], fontSize: 19),
                ),
              )
      ],
    );}
    )
    : Container(
              height: MediaQuery.of(context).size.height,
              child: Center(
                  child: Text(
                    'No hay pedidos',
                    style: TextStyle(color: Helper.brandColors[3], fontSize: 19),
                  ),
                ),
            );
            

}
 _tieneNovedad(String obraId, String pedidoId) {
    final dato = (_socketService.novedades??[]).indexWhere((novedad) =>
        novedad['tipo'] == 1 &&
        novedad['obraId'] == obraId &&
        novedad['pedidoId'] == pedidoId);

    return dato >= 0;
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
                  : null,
              onTap: actionOnTap,
              leading: Chip(
                label: Container(
                  width: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(Helper.toTextPrioridad(int.parse(avatar)).toUpperCase()),
                    ],
                  ),
                ),
                backgroundColor: colorPrioridad,
              ),
            ),
          ),
        ],
      ),
    );
    ;
  }
}