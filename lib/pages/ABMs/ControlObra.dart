import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ControlObraABM extends StatelessWidget {
  ControlObraABM({Key? key}) : super(key: key);
  static final routeName = 'ControlObraABM';

  final etapas = [
    {"descripcion": "Etapa 1", "isDefault": false, "orden": 1},
    {"descripcion": "Etapa 2", "isDefault": true, "orden": 2},
    {"descripcion": "Etapa 3", "isDefault": false, "orden": 3},
    {"descripcion": "Etapa 4", "isDefault": true, "orden": 4}
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Helper.brandColors[1],
          appBar: AppBar(
            title: Text('Control de obras ABM'),
            backgroundColor: Helper.brandColors[2],
            bottom: TabBar(
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
            children: [
              _EtapasView(etapas: etapas),
              _SubetapasView(etapas: etapas),
              _TareasView(),
            ],
          ),
        ));
  }
}

class _EtapasView extends StatefulWidget {
  _EtapasView({Key? key, required List<Map<String, Object>> etapas})
      : super(key: key);

  @override
  State<_EtapasView> createState() => _EtapasViewState();
}

class _EtapasViewState extends State<_EtapasView> {
  final etapas = [
    {"descripcion": "Etapa 1", "isDefault": false, "orden": 1},
    {"descripcion": "Etapa 2", "isDefault": true, "orden": 2},
    {"descripcion": "Etapa 3", "isDefault": false, "orden": 3},
    {"descripcion": "Etapa 4", "isDefault": true, "orden": 4}
  ];

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
    for (int i = 0; i < etapas.length; i++) {
      var txtDescri =
          TextEditingController(text: etapas[i]['descripcion'].toString());
      var txtOrden = TextEditingController(text: etapas[i]['orden'].toString());

      var row = TableRow(
          decoration: BoxDecoration(color: Helper.brandColors[2]),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextField(
                controller: txtDescri,
                style: TextStyle(color: Helper.brandColors[3]),
                onEditingComplete: () => print('lostFocus'),
                onChanged: (text) => etapas[i]['descripcion'] = text,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              expands: false,
              controller: txtOrden,
              style: TextStyle(color: Helper.brandColors[3]),
              onEditingComplete: () => print('lostFocus'),
              onChanged: (text) => etapas[i]['descripcion'] = text,
              decoration: InputDecoration(border: InputBorder.none),
            ),
            Switch(
              value: etapas[i]['isDefault'] as bool,
              activeColor: Helper.brandColors[3],
              activeTrackColor: Helper.brandColors[8],
              inactiveTrackColor: Helper.brandColors[3],
              onChanged: (value) {
                etapas[i]['isDefault'] = value;
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

    etapas.removeAt(index);
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
  _SubetapasView({Key? key, required this.etapas}) : super(key: key);
  List<Map<String, Object>> etapas;

  @override
  State<_SubetapasView> createState() => _SubetapasViewState();
}

class _SubetapasViewState extends State<_SubetapasView> {
  @override
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

  @override
  Widget build(BuildContext context) {
    var etapas = widget.etapas
        .map((e) => DropdownMenuItem(
            value: e['descripcion'].toString(),
            child: Container(child: Text(e['descripcion'].toString()))))
        .toList();

    Map<int, FlexColumnWidth> columnWidths = {
      0: FlexColumnWidth(3),
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
    for (int i = 0; i < subetapas.length; i++) {
      var txtDescri =
          TextEditingController(text: subetapas[i]['descripcion'].toString());
      var txtOrden =
          TextEditingController(text: subetapas[i]['orden'].toString());

      var row = TableRow(
          decoration: BoxDecoration(color: Helper.brandColors[2]),
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: DropdownButtonFormField2(
                  isExpanded: false,
                  onChanged: (a) {},
                  value: subetapas[i]['etapa'].toString(),
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
                onChanged: (text) => subetapas[i]['descripcion'] = text,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              expands: false,
              controller: txtOrden,
              style: TextStyle(color: Helper.brandColors[3]),
              onEditingComplete: () => print('lostFocus'),
              onChanged: (text) => subetapas[i]['descripcion'] = text,
              decoration: InputDecoration(border: InputBorder.none),
            ),
            Switch(
              value: subetapas[i]['isDefault'] as bool,
              activeColor: Helper.brandColors[3],
              activeTrackColor: Helper.brandColors[8],
              inactiveTrackColor: Helper.brandColors[3],
              onChanged: (value) {
                subetapas[i]['isDefault'] = value;
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

    subetapas.removeAt(index);
    setState(() {});
  }
}

class _TareasView extends StatelessWidget {
  const _TareasView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('tareas'));
  }
}
