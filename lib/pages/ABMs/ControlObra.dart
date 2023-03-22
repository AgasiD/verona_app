import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/models/subetapa.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/pages/forms/Etapa_Sub_Tarea.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ControlObraABM extends StatefulWidget {
  ControlObraABM({Key? key}) : super(key: key);
  static final routeName = 'ControlObraABM';

  @override
  State<ControlObraABM> createState() => _ControlObraABMState();
}

class _ControlObraABMState extends State<ControlObraABM>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  late List<Etapa> etapas;
  late List<Subetapa> subetapas;
  late List<Tarea> tareas;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.index = index;
    final _obraService = Provider.of<ObraService>(context, listen: false);
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Helper.brandColors[1],
          appBar: AppBar(
            title: Text('Control de obras ABM'),
            backgroundColor: Helper.brandColors[2],
            bottom: TabBar(
              controller: _tabCtrl,
              splashFactory: NoSplash.splashFactory,
              dividerColor: Helper.brandColors[8],
              indicatorColor: Helper.brandColors[8],
              tabs: [
                Tab(

                    child: Text(
                  'Etapas',
                  style: TextStyle(color: Helper.brandColors[8]),
                )),
                Tab(
                    child: Text(
                  'Subetapas',
                  style: TextStyle(color: Helper.brandColors[8]),
                )),
                Tab(
                    child: Text(
                  'Tareas',
                  style: TextStyle(color: Helper.brandColors[8]),
                )),
              ],
            ),
          ),
          body: FutureBuilder(
              future: _obraService.obtenerControlObra(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Loading(
                    mensaje: 'Cargando etapas...',
                  );
                final response = snapshot.data as MyResponse;
                if (response.fallo)
                  return Center(
                    child: Text(
                      response.error,
                      style: TextStyle(color: Helper.brandColors[3]),
                    ),
                  );

                etapas = (response.data['etapas'] as List)
                    .map((e) => Etapa.fromJson(e))
                    .toList() as List<Etapa>;

                subetapas = (response.data['subetapas'] as List)
                    .map((e) => Subetapa.fromJson(e))
                    .toList() as List<Subetapa>;

                tareas = (response.data['tareas'] as List)
                    .map((e) => Tarea.fromJson(e))
                    .toList() as List<Tarea>;

                return TabBarView(
                  
                  controller: _tabCtrl,
                  children: [
                    _EtapasView(etapas: etapas),
                    _SubetapasView(
                      etapas: etapas,
                      subetapas: subetapas,
                    ),
                    _TareasView(subetapas: subetapas, tareas: tareas),
                  ],
                );
              }),
          floatingActionButton: CustomNavigatorButton(
            accion: () => agregarItem(_tabCtrl.index),
            icono: Icons.add,
            showNotif: false,
          ),
        ));
  }

  agregarItem(int i) async {
    index = i;

    switch (i) {
      case 0:
        final data = await Navigator.pushNamed(
            context, Etapa_Sub_Tarea_Form.routeName,
            arguments: {
              "sinObra": true,
            });
        // if (data != null) etapas.add(data as Etapa);

        break;
      case 1:
        final data = await Navigator.pushNamed(
            context, Etapa_Sub_Tarea_Form.routeName, arguments: {
          "sinObra": true,
          "etapaId": etapas.first.descripcion.toString()
        });
        // if (data != null) subetapas.add(data as Map<String, Object>);
        break;
      case 2:
        final data = await Navigator.pushNamed(
            context, Etapa_Sub_Tarea_Form.routeName, arguments: {
          "sinObra": true,
          "subetapaId": subetapas.first.descripcion.toString()
        });
        // if (data != null) tareas.add(data as Map<String, Object>);
        break;
    }
    setState(() {});
  }
}

class _EtapasView extends StatefulWidget {
  _EtapasView({Key? key, required this.etapas}) : super(key: key);

  List<Etapa> etapas;
  @override
  State<_EtapasView> createState() => _EtapasViewState();
}

class _EtapasViewState extends State<_EtapasView> {
  @override
  Widget build(BuildContext context) {
    Map<int, FlexColumnWidth> columnWidths = {
      0: FlexColumnWidth(3),
      1: FlexColumnWidth(1),
      2: FlexColumnWidth(1.5),
      3: FlexColumnWidth(1),
    };

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
                '#',
                style: textTitleStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Por defecto',
                style: textTitleStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Borrar',
                style: textTitleStyle,
              ),
            )
          ])
    ];
    var controllers = [];
    for (int i = 0; i < widget.etapas.length; i++) {
      var txtDescri =
          TextEditingController(text: widget.etapas[i].descripcion.toString());
      var txtOrden =
          TextEditingController(text: widget.etapas[i].orden.toString());

      var row = TableRow(
          decoration: BoxDecoration(color: Helper.brandColors[2]),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextField(
                controller: txtDescri,
                style: TextStyle(color: Helper.brandColors[3]),
                onEditingComplete: () => print('lostFocus'),
                onChanged: (text) => widget.etapas[i].descripcion = text,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              expands: false,
              controller: txtOrden,
              style: TextStyle(color: Helper.brandColors[3]),
              onEditingComplete: () => print('lostFocus'),
              onChanged: (text) => widget.etapas[i].descripcion = text,
              decoration: InputDecoration(border: InputBorder.none),
            ),
            Switch(
              value: widget.etapas[i].isDefault as bool,
              activeColor: Helper.brandColors[3],
              activeTrackColor: Helper.brandColors[8],
              inactiveTrackColor: Helper.brandColors[3],
              onChanged: (value) {
                widget.etapas[i].isDefault = value;
                setState(() {});
              },
            ),
            IconButton(
                onPressed: () => borrarEtapa(i),
                icon: Icon(
                  Icons.highlight_remove_sharp,
                  color: Colors.red[500],
                ))
          ]);
      datos.add(row);
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(top: 15),
        child: Table(columnWidths: columnWidths, children: datos));
  }

  borrarEtapa(int index) async {
    bool confirm =
        await openDialogConfirmationReturn(context, "Seguro que quiere borrar");
    if (!confirm) return;

    widget.etapas.removeAt(index);
    setState(() {});
  }
}

class _EtapasTableRow extends StatefulWidget {
  const _EtapasTableRow();

  @override
  State<_EtapasTableRow> createState() => __EtapasTableRowState();
}

class __EtapasTableRowState extends State<_EtapasTableRow> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _SubetapasView extends StatefulWidget {
  _SubetapasView({Key? key, required this.etapas, required this.subetapas})
      : super(key: key);
  List<Etapa> etapas;

  List<Subetapa> subetapas;

  @override
  State<_SubetapasView> createState() => _SubetapasViewState();
}

class _SubetapasViewState extends State<_SubetapasView> {
  @override
  @override
  Widget build(BuildContext context) {
    var etapas = widget.etapas
        .map((e) => DropdownMenuItem(
            value: e.id.toString(),
            child: Container(child: Text(e.descripcion.toString()))))
        .toList();

    Map<int, FlexColumnWidth> columnWidths = {
      0: FlexColumnWidth(2),
      1: FlexColumnWidth(2),
      2: FlexColumnWidth(1),
      3: FlexColumnWidth(1.5),
    };

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
                'Etapa',
                style: textTitleStyle,
              ),
            ),
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
                '#',
                style: textTitleStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Por defecto',
                style: textTitleStyle,
              ),
            ),
          ])
    ];
    var controllers = [];
    for (int i = 0; i < widget.subetapas.length; i++) {
      var txtDescri = TextEditingController(
          text: widget.subetapas[i].descripcion.toString());
      var txtOrden =
          TextEditingController(text: widget.subetapas[i].orden.toString());

      var row = TableRow(
          decoration: BoxDecoration(color: Helper.brandColors[2]),
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 0),
                child: DropdownButtonFormField2(
                  dropdownWidth: 200,
                  isExpanded: false,
                  onChanged: (a) {},
                  value: widget.subetapas[i].etapa.toString(),
                  items: etapas,
                  style: TextStyle(color: Helper.brandColors[5], fontSize: 14),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Helper.brandColors[3],
                  ),
                  dropdownDecoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(15),
                    border: null,
                    color: Helper.brandColors[2],
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextField(
                controller: txtDescri,
                style: TextStyle(color: Helper.brandColors[3]),
                onEditingComplete: () => print('lostFocus'),
                onChanged: (text) => widget.subetapas[i].descripcion = text,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              expands: false,
              controller: txtOrden,
              style: TextStyle(color: Helper.brandColors[3]),
              onEditingComplete: () => print('lostFocus'),
              onChanged: (text) => widget.subetapas[i].descripcion = text,
              decoration: InputDecoration(border: InputBorder.none),
            ),
            Switch(
              value: widget.subetapas[i].isDefault as bool,
              activeColor: Helper.brandColors[3],
              activeTrackColor: Helper.brandColors[8],
              inactiveTrackColor: Helper.brandColors[3],
              onChanged: (value) {
                widget.subetapas[i].isDefault = value;
                setState(() {});
              },
            )
          ]);
      datos.add(row);
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(top: 15),
        child: SingleChildScrollView(
            child: Table(columnWidths: columnWidths, children: datos)));
  }

  borrarSubetapa(int index) async {
    bool confirm =
        await openDialogConfirmationReturn(context, "Seguro que quiere borrar");
    if (!confirm) return;

    widget.subetapas.removeAt(index);
    setState(() {});
  }
}

class _TareasView extends StatefulWidget {
  _TareasView({Key? key, required this.subetapas, required this.tareas})
      : super(key: key);
  List<Subetapa> subetapas;
  List<Tarea> tareas;
  List<Tarea> tareasFiltradas = [];

  @override
  State<_TareasView> createState() => _TareasViewState();
}

class _TareasViewState extends State<_TareasView> {
  int valueSelect = 1;
  int cantRegistros = 10;
  List<Tarea> tareasAux = [];
  TextEditingController searchCtrl = TextEditingController();
  bool busquedaActiva = false;
  @override
  Widget build(BuildContext context) {
    busquedaActiva ? false : tareasAux = widget.tareas;
    var subetapas = widget.subetapas
        .map((e) => DropdownMenuItem(
            value: e.id.toString(),
            child: FittedBox(
                fit: BoxFit.fitWidth, child: Text(e.descripcion.toString()))))
        .toList();

    Map<int, FlexColumnWidth> columnWidths = {
      0: FlexColumnWidth(1.5),
      1: FlexColumnWidth(2),
      2: FlexColumnWidth(.7),
      3: FlexColumnWidth(1),
    };

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
                'Subetapa',
                style: textTitleStyle,
              ),
            ),
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
                '#',
                textAlign: TextAlign.center,
                style: textTitleStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Por defecto',
                textAlign: TextAlign.center,
                style: textTitleStyle,
              ),
            ),
          ])
    ];
    var controllers = [];

    int veces = widget.tareas.length < cantRegistros ? widget.tareas.length - 1 : valueSelect * cantRegistros + cantRegistros - 1;
    print(valueSelect);
    for (int i = valueSelect * cantRegistros;
        i < veces;
        i++) {
      var txtDescri =
          TextEditingController(text: widget.tareas[i].descripcion.toString());
      var txtOrden = TextEditingController(text: 0.toString());

      var row = TableRow(
          decoration: BoxDecoration(color: Helper.brandColors[2]),
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Container(
                  child: DropdownButtonFormField2(
                    isExpanded: true,
                    onChanged: (a) {},
                    value: widget.tareas[i].subetapa.toString(),
                    items: subetapas,
                    style: TextStyle(
                        color: Helper.brandColors[5],
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Helper.brandColors[3],
                    ),
                    dropdownDecoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(15),
                      border: null,
                      color: Helper.brandColors[2],
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextField(
                controller: txtDescri,
                style: TextStyle(color: Helper.brandColors[3]),
                onEditingComplete: () => print('lostFocus'),
                onChanged: (text) => widget.tareas[i].descripcion = text,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              expands: false,
              controller: txtOrden,
              style: TextStyle(color: Helper.brandColors[3]),
              onEditingComplete: () => print('lostFocus'),
              onChanged: (text) => widget.tareas[i].descripcion = text,
              decoration: InputDecoration(border: InputBorder.none),
            ),
            Switch(
              value: widget.tareas[i].isDefault as bool,
              activeColor: Helper.brandColors[3],
              activeTrackColor: Helper.brandColors[8],
              inactiveTrackColor: Helper.brandColors[3],
              onChanged: (value) {
                widget.tareas[i].isDefault = value;
                setState(() {});
              },
            )
          ]);
      datos.add(row);
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(top: 15),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Cantidad de registros visibles',
                          style: TextStyle(
                              color: Helper.brandColors[3], fontSize: 18)),
                      DropdownButton(
                          alignment: Alignment.center,
                          value: cantRegistros,
                          items: [10, 25, 50, 100]
                              .map((cant) => DropdownMenuItem<int>(
                                    child: Text(cant.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Helper.brandColors[3],
                                            fontSize: 18)),
                                    value: cant,
                                  ))
                              .toList(),
                          onChanged: (a) {
                            refreshCantRegistros(int.parse(a.toString()));
                          }),
                    ],
                  ),
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                          style: TextStyle(color: Helper.brandColors[5]),
                          controller: searchCtrl,
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.search,
                              color: Helper.brandColors[3],
                            ),
                            hintText: 'Buscar tarea...',
                            hintStyle: TextStyle(color: Helper.brandColors[3]),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Helper.brandColors[8], width: 2.0)),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Helper.brandColors[3], width: 2.0),
                            ),
                          ),
                          onChanged: (value) => filtrarDatos(value)
                          ,),
                    ),
                  )
                ],
              ),
            ),
            Table(columnWidths: columnWidths, children: datos),
            Container(
                margin: EdgeInsets.symmetric(vertical: 45),
                child: _Paginator(
                    total: widget.tareas.length,
                    valueSelect: valueSelect,
                    refreshTable: refreshTable,
                    cantRegistros: cantRegistros))
          ],
        )));
  }

  refreshTable(int value) {
    setState(() {
      valueSelect = value;
    });
  }

  refreshCantRegistros(int value) {
    setState(() {
      cantRegistros = value;
      valueSelect = 1;
    });
  }

  borrarSubetapa(int index) async {
    bool confirm =
        await openDialogConfirmationReturn(context, "Seguro que quiere borrar");
    if (!confirm) return;

    widget.tareas.removeAt(index);
    setState(() {});
  }
  
  filtrarDatos(String value) {
    if(value.isEmpty) {
      widget.tareas = tareasAux;
      busquedaActiva = false;
    }
    else{
    widget.tareas = widget.tareas.where((tarea) => tarea.descripcion.toLowerCase().contains(value.toLowerCase())).toList();
    busquedaActiva = true;
    ;}
    setState(() {
      
    });
  }
}

class _Paginator extends StatefulWidget {
  _Paginator(
      {required this.total,
      required this.cantRegistros,
      required this.valueSelect,
      required this.refreshTable});
  int total, cantRegistros;
  int valueSelect;
  Function(int) refreshTable;
  @override
  State<_Paginator> createState() => __PaginatorState();
}

class __PaginatorState extends State<_Paginator> {
  @override
  Widget build(BuildContext context) {
    final cantItems = (widget.total / widget.cantRegistros).round();
    int maxItems = 1;
    maxItems = cantItems < maxItems ? cantItems : maxItems;

    List<Widget> items = [];
    items.addAll([
      _ItemPaginator(move: setValueSelect, value: 1, first: true), // <<
      _ItemPaginator(
        move: setValueSelect,
        value: widget.valueSelect > 0 ? widget.valueSelect - 1 : 1,
        back: true,
      )
    ]); // <

    int cant = ((widget.valueSelect < cantItems)
        ? widget.valueSelect == widget.valueSelect + maxItems
            ? widget.valueSelect + maxItems - 1
            : widget.valueSelect + maxItems
        : maxItems);

    for (int i = (widget.valueSelect > 1
            ? widget.valueSelect - 1
            : widget.valueSelect);
        i <= cant;
        i++) {
      items.add(_ItemPaginator(
        move: setValueSelect,
        value: i,
        number: i,
        isSelect: i == widget.valueSelect,
      ));
    }
    widget.valueSelect < cantItems - 2
        ? items.add(_ItemPaginator(
            move: setValueSelect,
            value: -1,
            ellipsis: true,
          ))
        : false;
    widget.valueSelect < cantItems - 1
        ? items.add(_ItemPaginator(
            move: setValueSelect,
            value: cantItems,
            number: cantItems,
            isSelect: cantItems == widget.valueSelect))
        : false;
    widget.valueSelect < cantItems
        ? items.add(_ItemPaginator(
            move: setValueSelect, value: widget.valueSelect + 1, next: true))
        : false; // >
    widget.valueSelect < cantItems - 1
        ? items.add(_ItemPaginator(
            move: setValueSelect,
            value: cantItems,
            last: true,
          ) // >>
            )
        : false;

    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: items),
    );
  }

  setValueSelect(int value) {
    widget.valueSelect = value < 1 ? widget.valueSelect = 1 : value;
    widget.refreshTable(value);
    setState(() {});
  }
}

class _ItemPaginator extends StatelessWidget {
  _ItemPaginator(
      {required this.move,
      required this.value,
      this.isSelect = false,
      this.back = false,
      this.next = false,
      this.first = false,
      this.last = false,
      this.ellipsis = false,
      this.number = 1});
  Function(int) move;
  bool back, ellipsis, next, first, last;
  int number;
  int value;
  bool isSelect;
  @override
  Widget build(BuildContext context) {
    String text = first
        ? '<<'
        : back
            ? '<'
            : next
                ? '>'
                : last
                    ? '>>'
                    : ellipsis
                        ? '...'
                        : number.toString();

    return GestureDetector(
      onTap: () => ellipsis ? null : move(value),
      child: Center(
          child: Container(
              color: isSelect ? Helper.brandColors[8] : Helper.brandColors[2],
              padding: EdgeInsets.all(10),
              child: Text(
                text,
                style: TextStyle(
                    color: isSelect
                        ? Helper.brandColors[2]
                        : Helper.brandColors[3],
                    fontWeight: isSelect ? FontWeight.bold : FontWeight.normal),
              ))),
    );
  }
}
