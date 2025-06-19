import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';

import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/error.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/password.dart';
import 'package:verona_app/services/notifications_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

import '../services/image_service.dart';

class PerfilPage extends StatelessWidget {
  PerfilPage({Key? key, this.usuarioId = null}) : super(key: key);
  static final routeName = 'perfil';
  String? usuarioId;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  late bool perfilPropio = true;

  bool esPhone = true;
  @override
  Widget build(BuildContext context) {
    _scaffoldKey = GlobalKey<ScaffoldState>();
    final _usuarioService = Provider.of<UsuarioService>(context);
    final _obraService = Provider.of<ObraService>(context, listen: false);
    final _pref = new Preferences();
    String textoImg = 'Cambiar imagen';
    bool sinImg = false;
    if (usuarioId != _pref.id) {
      perfilPropio = false;
    }

    double paddingLeft = 0.00;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
            future: _usuarioService.obtenerUsuario(usuarioId),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done)
                return Loading(mensaje: 'Cargando...');
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasError) {
                return ErrorPage(errorMsg: snapshot.error.toString());
              }

              Miembro usuario =
                  Miembro.fromJson(snapshot.data as Map<String, dynamic>);

              if (usuario.profileURL == '') {
                textoImg = 'Subir imagen de perfil';
                sinImg = true;
              }
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          // color: _color,
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                            color: Helper.brandColors[8].withOpacity(.8),
                            borderRadius: BorderRadius.circular(100)),
                        child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Helper.brandColors[0],
                            backgroundImage: sinImg
                                ? null
                                : NetworkImage(usuario.profileURL),
                            child: sinImg
                                ? FittedBox(
                                    child: Text(
                                      '${usuario.nombre[0].toUpperCase()} ${usuario.apellido[0].toUpperCase()}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Helper.brandColors[5],
                                      ),
                                    ),
                                  )
                                : Container()),
                      ),
                    ),
                    TextButton(
                        onPressed: () async => await uploadProfileImage(
                            context, usuario, _usuarioService),
                        child: Text(textoImg,
                            style: TextStyle(color: Helper.brandColors[8]))),
                    Text(
                      '${usuario.nombre.toUpperCase()} ${usuario.apellido.toUpperCase()}',
                      style: TextStyle(
                          overflow: TextOverflow.clip,
                          color: Helper.brandColors[5],
                          fontSize: 25),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: paddingLeft),
                      child: Column(children: [
                        DataRow(
                            text: '${usuario.username.toUpperCase()}',
                            icon: FontAwesomeIcons.solidUser),
                        DataRow(
                            icon: FontAwesomeIcons.briefcase,
                            text:
                                '${Helper.getProfesion(usuario.role).toUpperCase()}'),
                        DataRow(
                            icon: FontAwesomeIcons.idCard,
                            text: '${usuario.dni}'),
                        DataRow(
                            icon: FontAwesomeIcons.at,
                            text: '${usuario.email.toUpperCase()}'),
                        DataRow(
                            icon: FontAwesomeIcons.phone,
                            text: '${usuario.telefono.toUpperCase()}'),
                      ]),
                    ),
                    _pref.role == 1
                        ? TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context,
                                  usuario.role == 3
                                      ? PropietarioForm.routeName
                                      : MiembroForm.routeName,
                                  arguments: {
                                    "usuarioId": usuario.id,
                                    "pageFrom": 'profile'
                                  });
                            },
                            child: Text('Editar usuario',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Helper.brandColors[8])))
                        : Container(),
                    TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, PasswordPage.routeName,
                            arguments: {"usuarioId": usuario.id}),
                        child: Text('Cambiar contraseña',
                            style: TextStyle(
                                fontSize: 17, color: Helper.brandColors[8]))),
                    perfilPropio
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              MainButton(
                                  onPressed: () async => await sincNotifications(
                                      context, _usuarioService),
                                  width: 250,
                                  height: 35,
                                  fontSize: 15,
                                  color: Helper.brandColors[8],
                                  text: 'Sincronizar notificaciones'),
                              MainButton(
                                  onPressed: () async => 
                                      deleteDevices(context, _usuarioService),
                                  width: 250,
                                  height: 35,
                                  fontSize: 15,
                                  color: Helper.brandColors[8],
                                  text: 'Eliminar dispositivos asociados')
                            ],
                          )
                        : Container(),
                    !perfilPropio && _pref.role == 1
                        ? TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 122, 9, 1))),
                            child: Container(
                              alignment: Alignment.center,
                              width: 270,
                              child: Text(
                                'Eliminar usuario',
                                style: TextStyle(color: Helper.brandColors[5]),
                              ),
                            ),
                            onPressed: () async => await eliminarUsuario(
                                context, _usuarioService, _obraService))
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomNavigatorButton(
                              icono: Icons.mobile_screen_share_sharp,
                              accion: () => compartirUsuario(usuario),
                              showNotif: false),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }

  deleteDevices(context, _usuarioService) async {
    final deleteDevices = () async {
      openLoadingDialog(context, mensaje: 'Desasociando dispositivos...');
      try {
        final response = await _usuarioService.deleteAllDevice(usuarioId!);
        Navigator.pop(_scaffoldKey.currentContext!);
        openAlertDialog(
            _scaffoldKey.currentContext!, 'Dispositivo sincronizado con éxito');
      } catch (err) {
        openAlertDialog(
            _scaffoldKey.currentContext!, 'Error al sincronizar dispositivo',
            subMensaje: err.toString());
        return;
      }
    };

    final confirm = openDialogConfirmation(
        _scaffoldKey.currentContext!, deleteDevices, 'Confirmar desasociacion');
  }

  sincNotifications(context, _usuarioService) async {
    try {
      openLoadingDialog(context, mensaje: 'Sincronizando...');
      final response = await _usuarioService.setTokenDevice(
          usuarioId!, NotificationService.token!);
      closeLoadingDialog(context);
      openAlertDialog(context, 'Dispositivo sincronizado con éxito');
    } catch (err) {
      closeLoadingDialog(context);
      openAlertDialog(context, 'Error al sincronizar dispositivo',
          subMensaje: err.toString());
      return;
    }
  }

  uploadProfileImage(context, usuario, _usuarioService) async {
    final _imageService = Provider.of<ImageService>(context);

    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      openLoadingDialog(context, mensaje: 'Subiendo imagen...');
      try {
        _imageService.guardarImagen(image);
        final dataImage = await _imageService
            .grabarImagen('${usuario.nombre} ${usuario.apellido}');

        if (!dataImage['success']) {
          closeLoadingDialog(context);
          openAlertDialog(context, 'No se pudo cargar imagen');
          return;
        }

        final imageUrl = dataImage['data']['url'];

        usuario.profileURL = imageUrl;
        await _usuarioService.modificarUsuario(usuario);
        closeLoadingDialog(context);
        openAlertDialog(context, 'Imagen subida con éxito');
      } catch (err) {
        closeLoadingDialog(context);
        openAlertDialog(context, 'Error al subir imagen',
            subMensaje: err.toString());
      }
    }
  }

  Future<void> eliminarUsuario(
      context, UsuarioService _usuarioService, ObraService _obraService) async {
    try {
      if (!await openDialogConfirmationReturn(
          context, 'Confirmar para eliminar personal')) return;

      openLoadingDialog(
        context,
        mensaje: 'Eliminando personal, puede demorar...',
      );
      
      final response = await _usuarioService.deleteUsuario(usuarioId!);
      closeLoadingDialog(context);
      await openAlertDialogReturn(context, 'Usuario desactivado con éxito');
      _obraService.notifyListeners();

      Navigator.pop(context);
    } catch (err) {
      openAlertDialog(context, 'Error al desactivar usuario',
          subMensaje: err.toString());
      return;
    }
  }

  compartirUsuario(Miembro usuario) async {
    final _msg = '¡Bienvenido a Verona, ${usuario.nombre}! \n' +
        'Tu usuario es: ${usuario.username} \n' +
        'Si es tu primera vez, la contraseña irá vacía \n' +
        //'Contraseña: ${usuario.} |'+
        'Una vez que ingreses recordá asignarte una contraseña desde tu perfil. \n' +
        'Descargá la app para tu dispositivo \n' +
        'iOS: ${Helper.iosURL} \n' +
        'Android: ${Helper.androidURL}';

    String url = "wa.me";
    var encoded = Uri.https(url, '', {"text": _msg, "phone": usuario.telefono});
    if (await canLaunchUrl(encoded))
      await launchUrl(encoded, mode: LaunchMode.externalApplication);
    else {
      // openAlertDialog(context, 'No se puede visualizar el documento');
    }
  }
}

class DataRow extends StatelessWidget {
  DataRow({
    Key? key,
    required this.text,
    required this.icon,
  }) : super(key: key);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child:
              SizedBox(), // Este espacio ocupará 1/4 del ancho total de la pantalla
        ),
        Expanded(
          flex: 6,
          child: Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Icon(icon, color: Helper.brandColors[8], size: 25),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Helper.brandColors[5],
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
