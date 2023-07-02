import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/notificaciones_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class NotificacionesEditForm extends StatelessWidget {
  const NotificacionesEditForm({Key? key}) : super(key: key);
  static final routeName = 'NotificacionesEditForm';
  @override
  Widget build(BuildContext context) {
    final _notificacionService = Provider.of<NotificacionesService>(context, listen: false);
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final notifId = args['idNotif'];
    return GestureDetector(
        onTap: () => Helper.requestFocus(context),
        child: Scaffold(
          backgroundColor: Helper.brandColors[1],
          body: FutureBuilder(
              future: _notificacionService.obtenerNotificacionData(notifId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return Loading(mensaje: 'Cargando información');
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al recuperar información', style: TextStyle(color: Helper.brandColors[4], fontSize: 18)),
                  );
                }
                final response = snapshot.data as MyResponse;
                if (response.fallo)
                  return Center(child: Text('Error al recuperar información'));
                return _FormNotificaciones(notif: response.data);
              }),
          bottomNavigationBar: CustomNavigatorFooter(),
        ));
  }
}

class _FormNotificaciones extends StatefulWidget {
  _FormNotificaciones({Key? key, required this.notif}) : super(key: key);
  Map<String, dynamic> notif;
  @override
  State<_FormNotificaciones> createState() => _FormNotificacionesState();
}

class _FormNotificacionesState extends State<_FormNotificaciones> {
  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtMsg = TextEditingController();
  List<String> usuarios = [];
  String adminSelected = '';
  List<DropdownMenuItem<String>> administradoresItem = [];
  List<String> idUsuarioSelected = [];

  bool autorizado = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    txtMsg.text = widget.notif['mensaje'];
    txtTitle.text = widget.notif['titulo'];
    autorizado = widget.notif['autorizado'];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Text(
              'Autorizar notificación'.toUpperCase(),
              style: TextStyle(color: Helper.brandColors[8], fontSize: 23),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: CustomInput(
enable: !autorizado,
                hintText: 'Título',
                textController: txtTitle,
                icono: Icons.title,
              ),
            ),
            CustomInputArea(
              enable: !autorizado,
              hintText: 'Escriba hasta 50 caracteres',
              textController: txtMsg,
              icono: Icons.notifications_active_sharp,
              lines: 4,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Destinatarios",
                style: TextStyle(
                    color: Helper.brandColors[4],
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView.builder(
                itemCount: widget.notif['usuariosDestino'].length,
                itemBuilder: (_, index) {
                  return Text(
                    "${widget.notif['usuariosDestino'][index]['nombre']} ${widget.notif['usuariosDestino'][index]['apellido']}: ${widget.notif['usuariosDestino'][index]['dni']}",
                    style:
                        TextStyle(color: Helper.brandColors[4], fontSize: 17),
                  );
                },
              ),
            ),
              TextButton(
                onPressed: () => eliminarNotificacion(widget.notif['id']),
                child: Text('Eliminar', style: TextStyle(color: Colors.red[400], fontSize: 17),),
                
              ),
              MainButton(
                onPressed: () => enviarNotificacion(context),
                text: !autorizado ? 'Autorizar' : 'Reenviar',
                color: Helper.brandColors[8],
              ),
            
          ],
        ),
      ),
    );
  }

  enviarNotificacion(context) async {
    bool loading = false;
    try {
      // final result = validaForm();
      // if(!result[0]) {
      //   await openAlertDialogReturn(context, result[1]);
      //   return;
      // }

      if (!await openDialogConfirmationReturn(
          context, 'Confirme para enviar notificación')) return;

      openLoadingDialog(context, mensaje: 'Enviando notificación...');
      loading = true;
      final _notifService = Provider.of<NotificacionesService>(context, listen: false);
      String title = txtTitle.text.trim();
      String msg = txtMsg.text.trim();
    
      final _pref = new Preferences();
      final response = await _notifService.autorizarNotificacion(_pref.id,title, msg, widget.notif['id']);
      closeLoadingDialog(context);
      if(response.fallo){
        openAlertDialog(context, 'Error al enviar notificación', subMensaje: response.error);
      return  ;
      }
      await openAlertDialogReturn(context, 'Mensaje enviando con éxito');
      Navigator.pop(context);
    } catch (err) {
      if (loading) closeLoadingDialog(context);
      openAlertDialog(context, 'Error al enviar notificacion',
          subMensaje: err.toString());
    } finally {
      return;
    }
  }
  
  eliminarNotificacion(notif) async{
    if(!await openDialogConfirmationReturn(context, 'Confirme para eliminar notificación')) return;

    bool loading = true;
    try{
      openLoadingDialog(context, mensaje: 'Eliminando...');
      final _notifService = Provider.of<NotificacionesService>(context, listen: false);
      final response = await _notifService.eliminarNotificacion(notif);
      if(response.fallo){
        throw Exception(response.error);
      }
      closeLoadingDialog(context);
      loading = false;
      await openAlertDialogReturn(context, 'Eliminada con éxito');
      Navigator.pop(context);
    }catch ( err ){
      loading ? closeLoadingDialog(context) : false;
      openAlertDialog(context, 'Error al eliminar', subMensaje: err.toString());
      return;
    }
  }
}
