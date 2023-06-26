import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/forms/notificaciones_edit.dart';
import 'package:verona_app/services/notificaciones_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class NotificacionesABM extends StatefulWidget {
  NotificacionesABM({Key? key}) : super(key: key);
  static final routeName = 'NoticicacionesABM';

  @override
  State<NotificacionesABM> createState() => _NotificacionesABMState();
}

class _NotificacionesABMState extends State<NotificacionesABM>     with TickerProviderStateMixin {
    late TabController _tabCtrl;

  int index = 0;

  @override
  Widget build(BuildContext context) {
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.index = index;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
      backgroundColor: Helper.brandColors[1],
      appBar: AppBar(
        backgroundColor: Helper.brandColors[2],
        bottom: TabBar(
                controller: _tabCtrl,
                splashFactory: NoSplash.splashFactory,
                dividerColor: Helper.brandColors[8],
                indicatorColor: Helper.brandColors[8],
                tabs: [
                  Tab(
                      child: Text(
                    'Por autorizar',
                    style: TextStyle(color: Helper.brandColors[8]),
                  )),
                  Tab(
                      child: Text(
                    'Autorizadas',
                    style: TextStyle(color: Helper.brandColors[8]),
                  )),
                ],
              ),
      ),
      body: _Tabs(ctrl: _tabCtrl),
      bottomNavigationBar: CustomNavigatorFooter(), 
      ),
    );
  }
}


class _Tabs extends StatelessWidget {
  _Tabs({Key? key, required this.ctrl}) : super(key: key);
 TabController ctrl;


  @override
  Widget build(BuildContext context) {
    return TabBarView(
                  controller: ctrl,
                  children: [
                    _ListNotificaciones(),
                    _ListNotificaciones(autorizada: true,),
                  ]
                  );
  }
}

class _ListNotificaciones extends StatelessWidget {
  _ListNotificaciones({Key? key, this.autorizada = false }) : super(key: key);
  bool autorizada;
  @override
  Widget build(BuildContext context) {
    final _pref = new Preferences();
    final _notificacionesService = Provider.of<NotificacionesService>(context);
    return FutureBuilder(
      future: _notificacionesService.obtenerNotificaciones(_pref.id, autorizada),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Loading(mensaje: 'Cargando información...');
        }
      final response = snapshot.data as MyResponse;
      if(response.fallo){
        return Center(child: Text('Error al cargar información'),);
      }
      final notif = response.data;
      (notif as List).sort(( a,b ) {
        return a['ts'] > b['ts'] ? -1 : 1;
      });
      if(notif.length > 0)
      return ListView.builder(
        itemCount: notif.length,
        itemBuilder: (context, index) => CustomListTile(
        esPar: index % 2 == 0, 
        title: notif[index]['titulo'], 
        subtitle: '${notif[index]['usuario']['nombre']} ${notif[index]['usuario']['apellido']}',
        textAvatar: false,
        iconAvatar: autorizada ?Icons.notifications : Icons.notification_important_sharp ,
        avatar: 'e',
        onTap: true,
        fontSize: 15,
        actionOnTap: () => Navigator.pushNamed(context, NotificacionesEditForm.routeName, arguments: {'idNotif': notif[index]['id'] ?? ''}),
        ));
        else{
          String text;
          if(autorizada)
          text = 'Aún no hay notificaciones autorizadas';
          else
          text = 'No hay notificaciones pendientes';
          return Center(
            child: Text(text, style: TextStyle(color: Helper.brandColors[4], fontSize: 18),),
          );
        }
    });
  }
}
