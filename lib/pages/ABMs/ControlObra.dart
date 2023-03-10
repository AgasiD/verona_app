import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ControlObraABM extends StatefulWidget {
  ControlObraABM({Key? key}) : super(key: key);
  static final routeName = 'ControlObraABM';

  @override
  State<ControlObraABM> createState() => _ControlObraABMState();
}

class _ControlObraABMState extends State<ControlObraABM> with TickerProviderStateMixin{
  final etapas = [
    { "descripcion": "Etapa 1", "isDefault": false, "orden": 1 },
    { "descripcion": "Etapa 2", "isDefault": true,  "orden": 2 },
    { "descripcion": "Etapa 3", "isDefault": false, "orden": 3 },
    { "descripcion": "Etapa 4", "isDefault": true,  "orden": 4 }
  ];

    final subetapas = [
    {
      "etapa": "Etapa 1",
      "descripcion": "Subetapa 1",
      "isDefault": false,
      "orden": 1
    },
    {
      "etapa": "Etapa 2",
      "descripcion": "Subetapa 2",
      "isDefault": true,
      "orden": 2
    },
    {
      "etapa": "Etapa 3",
      "descripcion": "Subetapa 3",
      "isDefault": false,
      "orden": 3
    },
    {
      "etapa": "Etapa 4",
      "descripcion": "Subetapa 4",
      "isDefault": true,
      "orden": 4
    }
  ];

    final tareas = [
    {
      "subetapa": "Subetapa 1",
      "descripcion": "Tarea 1",
      "isDefault": false,
      "orden": 1
    },
    {
      "subetapa": "Subetapa 2",
      "descripcion": "Tarea 2",
      "isDefault": true,
      "orden": 2
    },
    {
      "subetapa": "Subetapa 3",
      "descripcion": "Tarea 3",
      "isDefault": false,
      "orden": 3
    },
    {
      "subetapa": "Subetapa 4",
      "descripcion": "Tarea 4",
      "isDefault": true,
      "orden": 4
    }
  ];

  late TabController _tabCtrl;

  int index = 0;

  
  @override
  Widget build(BuildContext context) {
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.index = index;
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
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _EtapasView(etapas: etapas),
              _SubetapasView(etapas: etapas, subetapas: subetapas,),
              _TareasView(subetapas: subetapas, tareas: tareas),
            ],
          ),
          floatingActionButton: CustomNavigatorButton(
              accion: () => agregarItem(_tabCtrl.index),
              icono: Icons.add,
              showNotif: false,
              
            ),
        ));
  }

  agregarItem(int i){
    index = i;
    switch(i){
      case 0: etapas.add({
      "descripcion": "Nueva etapa ",
      "isDefault": true,
      "orden": etapas.length + 1
    });
    break;
    case 1: subetapas.add({
      "etapa": etapas.first['descripcion'].toString(),
      "descripcion": "Nueva nueva subetapa ",
      "isDefault": true,
      "orden": subetapas.length + 1
    });
    break;
    case 2: tareas.add({
            "subetapa": subetapas.first['descripcion'].toString(),

      "descripcion": "Nueva etapa ",
      "isDefault": true,
      "orden": tareas.length + 1
    });
    break;
    }
    setState(() {
      
    });
  }
}

class _EtapasView extends StatefulWidget {
  _EtapasView({Key? key, required this.etapas})
      : super(key: key);

List<Map<String, Object>> etapas;
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
          TextEditingController(text: widget.etapas[i]['descripcion'].toString());
      var txtOrden = TextEditingController(text: widget.etapas[i]['orden'].toString());

      var row = TableRow(
          decoration: BoxDecoration(color: Helper.brandColors[2]),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextField(
                controller: txtDescri,
                style: TextStyle(color: Helper.brandColors[3]),
                onEditingComplete: () => print('lostFocus'),
                onChanged: (text) => widget.etapas[i]['descripcion'] = text,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              expands: false,
              controller: txtOrden,
              style: TextStyle(color: Helper.brandColors[3]),
              onEditingComplete: () => print('lostFocus'),
              onChanged: (text) => widget.etapas[i]['descripcion'] = text,
              decoration: InputDecoration(border: InputBorder.none),
            ),
            Switch(
              value: widget.etapas[i]['isDefault'] as bool,
              activeColor: Helper.brandColors[3],
              activeTrackColor: Helper.brandColors[8],
              inactiveTrackColor: Helper.brandColors[3],
              onChanged: (value) {
                widget.etapas[i]['isDefault'] = value;
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
  _SubetapasView({Key? key, required this.etapas, required this.subetapas}) : super(key: key);
  List<Map<String, Object>> etapas;

  List<Map<String, Object>> subetapas;

  @override
  State<_SubetapasView> createState() => _SubetapasViewState();
}

class _SubetapasViewState extends State<_SubetapasView> {
  @override


  @override
  Widget build(BuildContext context) {
    var etapas = widget.etapas
        .map((e) => DropdownMenuItem(
            value: e['descripcion'].toString(),
            child: Container(child: Text(e['descripcion'].toString()))))
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
      var txtDescri =
          TextEditingController(text: widget.subetapas[i]['descripcion'].toString());
      var txtOrden =
          TextEditingController(text: widget.subetapas[i]['orden'].toString());

      var row = TableRow(
          decoration: BoxDecoration(color: Helper.brandColors[2]),
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 0),
                child: DropdownButtonFormField2(
                  dropdownWidth: 200,
                  isExpanded: false,
                  onChanged: (a) {},
                  value: widget.subetapas[i]['etapa'].toString(),
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
                onChanged: (text) => widget.subetapas[i]['descripcion'] = text,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              expands: false,
              controller: txtOrden,
              style: TextStyle(color: Helper.brandColors[3]),
              onEditingComplete: () => print('lostFocus'),
              onChanged: (text) => widget.subetapas[i]['descripcion'] = text,
              decoration: InputDecoration(border: InputBorder.none),
            ),
            Switch(
              value: widget.subetapas[i]['isDefault'] as bool,
              activeColor: Helper.brandColors[3],
              activeTrackColor: Helper.brandColors[8],
              inactiveTrackColor: Helper.brandColors[3],
              onChanged: (value) {
                widget.subetapas[i]['isDefault'] = value;
                setState(() {});
              },
            )
          ]);
      datos.add(row);
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(top: 15),
        child: Table(columnWidths: columnWidths, children: datos));
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
   _TareasView({Key? key, required this.subetapas, required this.tareas}) : super(key: key);
  List<Map<String, Object>> subetapas;
  List<Map<String, Object>> tareas;


  @override
  State<_TareasView> createState() => _TareasViewState();
}

class _TareasViewState extends State<_TareasView> {
  @override
  Widget build(BuildContext context) {
 var subetapas = widget.subetapas
        .map((e) => DropdownMenuItem(
            value: e['descripcion'].toString(),
            child: Container(child: Text(e['descripcion'].toString()))))
        .toList();

print(widget.tareas);
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
    for (int i = 0; i < widget.tareas.length; i++) {
      var txtDescri =
          TextEditingController(text: widget.tareas[i]['descripcion'].toString());
      var txtOrden =
          TextEditingController(text: widget.tareas[i]['orden'].toString());

      var row = TableRow(
          decoration: BoxDecoration(color: Helper.brandColors[2]),
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 0),
                child: DropdownButtonFormField2(
                  dropdownWidth: 200,
                  isExpanded: false,
                  onChanged: (a) {},
                  value: widget.tareas[i]['subetapa'].toString(),
                  items: subetapas,
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
                onChanged: (text) => widget.tareas[i]['descripcion'] = text,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              expands: false,
              controller: txtOrden,
              style: TextStyle(color: Helper.brandColors[3]),
              onEditingComplete: () => print('lostFocus'),
              onChanged: (text) => widget.tareas[i]['descripcion'] = text,
              decoration: InputDecoration(border: InputBorder.none),
            ),
            Switch(
              value: widget.tareas[i]['isDefault'] as bool,
              activeColor: Helper.brandColors[3],
              activeTrackColor: Helper.brandColors[8],
              inactiveTrackColor: Helper.brandColors[3],
              onChanged: (value) {
                widget.tareas[i]['isDefault'] = value;
                setState(() {});
              },
            )
          ]);
      datos.add(row);
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(top: 15),
        child: Table(columnWidths: columnWidths, children: datos));
  }

  borrarSubetapa(int index) async {
    bool confirm =
        await openDialogConfirmationReturn(context, "Seguro que quiere borrar");
    if (!confirm) return;

    widget.tareas.removeAt(index);
    setState(() {});
  }
}

