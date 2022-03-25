import 'package:flutter/material.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({Key? key}) : super(key: key);
  static const String routeName = 'notificaciones';
  final List<Map<String, IconData>> iconos = const [
    {'mensaje': Icons.mark_email_unread_outlined},
    {'check': Icons.check_box_outlined},
    {'media': Icons.photo_size_select_actual_rounded},
    {'doc': Icons.document_scanner_outlined},
    {'pedido': Icons.list_alt_rounded},
    {'inactividad': Icons.work_off_outlined}
  ];

  final List<Map<String, dynamic>> notificaciones = const [
    {
      'type': 'mensaje',
      'text': 'Nuevo mensaje en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'check',
      'text': 'Tarea completada en Alasta',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'media',
      'text': 'Nuevo archivo multimedia en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'doc',
      'text': 'Nuevo documento en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'pedido',
      'text': 'Nuevo pedido en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false
    },
    {
      'type': 'inactividad',
      'text': 'Nueva inactividad en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'mensaje',
      'text': 'Nuevo mensaje en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'check',
      'text': 'Tarea completada en Alasta',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'media',
      'text': 'Nuevo archivo multimedia en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'doc',
      'text': 'Nuevo documento en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'pedido',
      'text': 'Nuevo pedido en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'inactividad',
      'text': 'Nueva inactividad en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'mensaje',
      'text': 'Nuevo mensaje en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'check',
      'text': 'Tarea completada en Alasta',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'media',
      'text': 'Nuevo archivo multimedia en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'doc',
      'text': 'Nuevo documento en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'pedido',
      'text': 'Nuevo pedido en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'inactividad',
      'text': 'Nueva inactividad en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'mensaje',
      'text': 'Nuevo mensaje en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'check',
      'text': 'Tarea completada en Alasta',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'media',
      'text': 'Nuevo archivo multimedia en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'doc',
      'text': 'Nuevo documento en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
    {
      'type': 'pedido',
      'text': 'Nuevo pedido en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': false,
      'ts': '18:30',
    },
    {
      'type': 'inactividad',
      'text': 'Nueva inactividad en Alaska',
      'subtext': 'Nueva notificacion',
      'leido': true,
      'ts': '18:30',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notificaciones',
        muestraBackButton: true,
      ),
      body: Container(
        child: ListView.builder(
            itemCount: notificaciones.length,
            itemBuilder: (BuildContext context, int i) {
              final iconName = notificaciones[i]['type'];
              return Column(
                children: [
                  ListTile(
                    title: Text(notificaciones[i]['text']),
                    subtitle: Text(notificaciones[i]['ts'].toString()),
                    leading: CircleAvatar(
                      backgroundColor: !notificaciones[i]['leido']
                          ? Colors.blue
                          : Colors.white,
                      foregroundColor: notificaciones[i]['leido']
                          ? Colors.blue
                          : Colors.white,
                      child: Icon(iconos
                          .where((element) => element.containsKey(iconName))
                          .first[iconName]),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  Divider(
                    height: 5,
                  ),
                ],
              );
            }),
      ),
    );
  }
}

/*

- Mensaje no leido
- Tarea checklist terminada
- Foto o video cargado
- Cambio de estado de pedido (solo integrantes del equipo)
- Nueva inactividad
-

*/
