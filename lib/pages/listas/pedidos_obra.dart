import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PedidoList extends StatelessWidget {
  const PedidoList({Key? key}) : super(key: key);
  static final routeName = 'pedido_list';

  @override
  Widget build(BuildContext context) {
    final _pref = new Preferences();
    final _obraService = Provider.of<ObraService>(context);
    Future future;

    if (_pref.role == 6) {
      future = _obraService.obtenerPedidosAsignadosDelivery(
          _obraService.obra.id, _pref.id);
    } else {
      future = _obraService.obtenerPedidos(_obraService.obra.id);
    }
    return Scaffold(
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Loading(mensaje: 'Cargando equipo asignado');
                } else {
                  final response = snapshot.data as MyResponse;
                  if (!response.fallo) {
                    final pedidos = response.data as List<dynamic>;
                    final _pref = new Preferences();
                    if (pedidos.length > 0) {
                      final agrupado = getPedidosAgrupadosxEstado(pedidos);
                      return Container(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: agrupado.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return _PedidosByEstado(
                                          estado: agrupado[index]["estado"],
                                          pedidos: agrupado[index]['data']);
                                    }),
                              ),
                              _pref.role != 6
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        MainButton(
                                          width: 150,
                                          height: 20,
                                          color: Helper.brandColors[8],
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, PedidoForm.routeName,
                                                arguments: {
                                                  'obraId': _obraService.obra.id
                                                });
                                          },
                                          text: 'Crear pedido',
                                          fontSize: 15,
                                        ),
                                      ],
                                    )
                                  : Container()
                            ],
                          ));
                    } else {
                      return Column(
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height - 220,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Text(
                                  'Aún no hay pedidos solicitados',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Helper.brandColors[4]),
                                ),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Helper.habilitaByRole([1, 2, 4, 5])
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    MainButton(
                                      width: 150,
                                      height: 20,
                                      color: Helper.brandColors[8],
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, PedidoForm.routeName,
                                            arguments: {
                                              'obraId': _obraService.obra.id
                                            });
                                      },
                                      text: 'Crear pedido',
                                      fontSize: 15,
                                    ),
                                  ],
                                )
                              : Container()
                        ],
                      );
                    }
                  } else {
                    return Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text(
                            'Error al recuperar pedidos: ${response.error}',
                            style: TextStyle(
                                fontSize: 18, color: Helper.brandColors[4]),
                          ),
                        ));
                  }
                }
              }),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }

  getPedidosAgrupadosxEstado(List pedidos) {
    List<dynamic> agrupados = [];
    const estados = Helper.ESTADOSPEDIDO;
    estados.forEach((estado) {
      List<dynamic> agrupacion = [];
      agrupacion =
          pedidos.where((element) => element['estado'] == estado).toList();
      agrupados
          .add({"estado": Helper.getEstadoPedido(estado), "data": agrupacion});
    });
    return agrupados;
  }
}

class _PedidosByEstado extends StatelessWidget {
  _PedidosByEstado({Key? key, required this.estado, required this.pedidos})
      : super(key: key);

  List<dynamic> pedidos;
  String estado;

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context, listen: false);
    final _socketService = Provider.of<SocketService>(context);

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
            title: Text(estado.toUpperCase()),
            textColor: Helper.brandColors[5],
          ),
        ),
        pedidos.length > 0
            ? ListView.builder(
                itemCount: pedidos.length,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  final esPar = index % 2 == 0;
                  final arg = {
                    'pedidoId': pedidos[index]['id'],
                    'obraId': _obraService.obra.id
                  };
                  final textSubtitle = pedidos[index]['fechaEstimada'] == ''
                      ? "${("Fecha deseada").toUpperCase()} ${pedidos[index]['fechaDeseada']}"
                      : "${("Fecha de entrega").toUpperCase()} ${pedidos[index]['fechaEstimada']}";
                  return Column(
                    children: [
                      _CustomListTile(
                        esNovedad: _tieneNovedad(_obraService.obra.id,
                            pedidos[index]['id'], _socketService),
                        esPar: false,
                        title:
                            "${pedidos[index]['titulo'].toString().toUpperCase()}",
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              textSubtitle.toUpperCase(),
                              style: TextStyle(
                                  color: Helper.brandColors[8].withOpacity(.8)),
                            ),
                            Text(
                              ('Por: ${pedidos[index]['usuario']['nombre']} ${pedidos[index]['usuario']['apellido']}')
                                  .toUpperCase(),
                              style: TextStyle(
                                  color: Helper.brandColors[8].withOpacity(.8)),
                            ),
                          ],
                        ),
                        avatar: pedidos[index]['prioridad']
                            .toString()
                            .toUpperCase(),
                        fontSize: 18,
                        onTap: true,
                        actionOnTap: () => Navigator.pushNamed(
                            context, PedidoForm.routeName,
                            arguments: arg),
                      ),
                      index != pedidos.length - 1
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
    );
  }

  _tieneNovedad(String obraId, String pedidoId, SocketService _socketService) {
    final dato = (_socketService.novedades ?? []).indexWhere((novedad) =>
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
                      ))
                  : null,
              onTap: actionOnTap,
              leading: Chip(
                label: Container(
                  width: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(toTextPrioridad(int.parse(avatar)).toUpperCase()),
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

  String toTextPrioridad(int prioridad) {
    String text = '';
    switch (prioridad) {
      case 1:
        text = 'baja';
        break;
      case 2:
        text = 'media';
        break;
      case 3:
        text = 'Alta';
        break;
    }
    return text;
  }
}
