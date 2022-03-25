import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/models/obra.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/form.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ObraPage extends StatelessWidget {
  static const String routeName = 'obra';

  const ObraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final obraId = arguments['obraId'];
    final _service = Provider.of<ObraService>(context, listen: false);

    return Scaffold(
        appBar: CustomAppBar(
          muestraBackButton: true,
        ),
        body: FutureBuilder(
            future: _service.obtenerObra(obraId),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container();
              } else {
                final obra = snapshot.data as Obra;
                return Container(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              Hero(
                                  tag: 'obra',
                                  child: Image(
                                    image: AssetImage('assets/obra.png'),
                                    width: MediaQuery.of(context).size.width,
                                    //height: MediaQuery.of(context).size.height * .4,
                                  )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.edit),
                                    splashColor: null,
                                    splashRadius: 0.1,
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.delete),
                                    splashRadius: 0.1,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Etapa:' + 'Tareas preliminares',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Duracion:' +
                                    '${obra.diasTranscurridos - obra.diasInactivos.length}/${obra.diasEstimados}',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CaracteristicaObra(),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleAvatar(
                                minRadius: 30,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.groups_outlined,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, ChatPage.routeName);
                                  },
                                ),
                              ),
                              CircleAvatar(
                                minRadius: 30,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.chat,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, ChatPage.routeName);
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            }));
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

    return FutureBuilder(
      future: _service.obtenerObra(obraId),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container();
        } else {
          final obra = snapshot.data as Obra;
          final _data = _generarItems(obra);
          return _CustomExpansion(
            data: _data,
          );
        }
      },
    );
  }

  List<Item> _generarItems(Obra obra) {
    List<Item> items = [];
    //Desplegable de propietarios
    final propietarios = Item(
        titulo: 'Propietarios',
        route: AgregarPropietariosPage.routeName,
        accion: () {
          Navigator.pushReplacementNamed(
              context, AgregarPropietariosPage.routeName);
        },
        values: obra.propietarios
            .map((e) => {
                  'id': e.dni,
                  'nombre': e.nombre + ' ' + e.apellido,
                  'telefono': e.telefono
                })
            .toList());
    items.add(propietarios);

    //Desplegable de equipo
    final team = Item(
        titulo: 'Equipo',
        accion: () {},
        values: obra.equipo
            .map((e) => {
                  'id': e.dni,
                  'nombre': e.nombre + ' ' + e.apellido,
                  'telefono': e.telefono
                })
            .toList());
    items.add(team);

    //Desplegable de documentacion

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
  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expandedHeaderPadding: EdgeInsets.symmetric(vertical: 0),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          widget.data[index].isExpanded = !isExpanded;
        });
      },
      elevation: 4,
      children: widget.data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Container(
                padding: EdgeInsets.only(left: 15),
                alignment: Alignment.centerLeft,
                child: ListTile(
                    trailing: item.addButton
                        ? IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              item.accion();
                            })
                        : null,
                    title: Text(
                      item.titulo,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )));
          },
          body: SingleChildScrollView(
              child: Column(children: [
            item.values.length > 0
                ? ListView.builder(
                    physics:
                        NeverScrollableScrollPhysics(), // esto hace que no rebote el gridview al scrollear
                    shrinkWrap: true,
                    itemCount: item.values.length,
                    itemBuilder: (_, i) {
                      return Column(children: [
                        Dismissible(
                            key: Key(item.values[i]['id']),
                            direction: DismissDirection.endToStart,
                            onDismissed: (id) {
                              item.values.remove(item.values.singleWhere(
                                  (element) => element['id'] == id));
                            },
                            background: Container(
                              padding: EdgeInsets.only(left: 5),
                              color: Colors.red,
                              child: const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                            child: ListTile(
                                title: Text(item.values[i]['nombre']),
                                subtitle:
                                    Text(item.values[i]['telefono'] ?? ''),
                                //trailing: const Icon(Icons.delete),
                                onTap: () {}))
                      ]);
                    },
                  )
                : Container(),
          ])),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
