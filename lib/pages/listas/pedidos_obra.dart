import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PedidoList extends StatelessWidget {
  const PedidoList({Key? key}) : super(key: key);
  static final routeName = 'pedido_list';

  @override
  Widget build(BuildContext context) {
    final _pref = new Preferences();

    final _obraService = Provider.of<ObraService>(context, listen: false);
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
                    final pedidos = response.data;
                    final _pref = new Preferences();
                    if (pedidos.length > 0) {
                      return Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height - 210,
                            color: Helper.brandColors[1],
                            child: ListView.builder(
                                itemCount: pedidos.length,
                                itemBuilder: ((context, index) {
                                  final esPar = index % 2 == 0;
                                  final arg = {
                                    'pedidoId': pedidos[index]['id']
                                  };
                                  return _CustomListTile(
                                    esPar: esPar,
                                    title: Helper.getFechaFromTS(
                                        pedidos[index]['ts']),
                                    subtitle: pedidos[index]['cerrado']
                                        ? 'Cerrado'.toUpperCase()
                                        : pedidos[index]['asignado']
                                            ? 'Asingado'.toUpperCase()
                                            : 'Sin asignar'.toUpperCase(),
                                    avatar: pedidos[index]['prioridad']
                                        .toString()
                                        .toUpperCase(),
                                    fontSize: 18,
                                    onTap: true,
                                    actionOnTap: () => Navigator.pushNamed(
                                        context, PedidoForm.routeName,
                                        arguments: arg),
                                  );
                                })),
                          ),
                          SizedBox(
                            height: 10,
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
                      );
                    } else {
                      return Column(
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height - 210,
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
                                        print('hola');
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
                        height: MediaQuery.of(context).size.height - 210,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text(
                            'Aún no hay integrantes en el equipo',
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
}

class _CustomListTile extends StatelessWidget {
  bool esPar;
  String title;
  String subtitle;
  String avatar;
  bool onTap;
  bool textAvatar;
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
      this.textAvatar = true,
      this.iconAvatar = Icons.abc,
      this.padding = 20,
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
      padding: EdgeInsets.symmetric(horizontal: this.padding),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: _color, borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(title,
                  style: TextStyle(
                      color: Helper.brandColors[5], fontSize: fontSize)),
              subtitle: this.subtitle != ''
                  ? Text(
                      subtitle,
                      style: TextStyle(
                          color: Helper.brandColors[8].withOpacity(.8)),
                    )
                  : null,
              trailing: onTap
                  ? Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Helper.brandColors[3],
                    )
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
