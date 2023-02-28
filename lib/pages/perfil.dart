import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/pages/password.dart';
import 'package:verona_app/services/notifications_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

import '../services/image_service.dart';

class PerfilPage extends StatelessWidget {
  PerfilPage({Key? key}) : super(key: key);
  static final routeName = 'perfil';
  late String _usuarioId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late bool perfilPropio = true;

  bool esPhone = true;
  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context);
    final _imageService = Provider.of<ImageService>(context);
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final _pref = new Preferences();
    _usuarioId = arguments['usuarioId'];
    String textoImg = 'Cambiar imagen';
    bool sinImg = false;
    if (_usuarioId != _pref.id) {
      perfilPropio = false;
    }
    if (MediaQuery.of(context).size.width > 1000) esPhone = false;

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
            future: _usuarioService.obtenerUsuario(_usuarioId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading(
                  mensaje: 'Cargando datos...',
                );
              } else {
                MyResponse response = snapshot.data as MyResponse;
                if (response.fallo) {
                  print('Error al cargar datos');
                  return Container();
                } else {
                  Miembro usuario = Miembro.fromJson(response.data);

                  if (usuario.profileURL == '') {
                    textoImg = 'Subir imagen de perfil';
                    sinImg = true;
                  }

                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                    ? Text(
                                        '${usuario.nombre[0].toUpperCase()} ${usuario.apellido[0].toUpperCase()}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Helper.brandColors[5],
                                        ),
                                      )
                                    : Container()),
                          ),
                        ),
                        TextButton(
                            onPressed: () async {
                              final ImagePicker _picker = ImagePicker();
                              final image = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              if (image != null) {
                                openLoadingDialog(context,
                                    mensaje: 'Subiendo imagen...');
                                try {
                                  _imageService.guardarImagen(image);
                                  final dataImage =
                                      await _imageService.grabarImagen(
                                          '${usuario.nombre} ${usuario.apellido}');

                                  if (!dataImage['success']) {
                                    closeLoadingDialog(context);
                                    openAlertDialog(
                                        context, 'No se pudo cargar imagen');
                                    return;
                                  }

                                  final imageUrl = dataImage['data']['url'];

                                  usuario.profileURL = imageUrl;
                                  await _usuarioService
                                      .modificarUsuario(usuario);
                                  closeLoadingDialog(context);
                                  openAlertDialog(
                                      context, 'Imagen subida con éxito');
                                } catch (err) {
                                  closeLoadingDialog(context);
                                  openAlertDialog(
                                      context, 'Error al subir imagen',
                                      subMensaje: err.toString());
                                }
                              }
                            },
                            child: Text(textoImg,
                                style:
                                    TextStyle(color: Helper.brandColors[8]))),
                        Container(
                          child: Text(
                            '${usuario.nombre.toUpperCase()} ${usuario.apellido.toUpperCase()}',
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: Helper.brandColors[5],
                                fontSize: 25),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: esPhone
                                  ? MediaQuery.of(context).size.width * .15
                                  : MediaQuery.of(context).size.width * .4),
                          child: Column(children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(FontAwesomeIcons.solidUser,
                                      color: Helper.brandColors[8], size: 25),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    '${usuario.username.toUpperCase()}',
                                    style: TextStyle(
                                        color: Helper.brandColors[3],
                                        fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(FontAwesomeIcons.briefcase,
                                      color: Helper.brandColors[8], size: 25),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    '${Helper.getProfesion(usuario.role).toUpperCase()}',
                                    style: TextStyle(
                                      color: Helper.brandColors[5],
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(FontAwesomeIcons.idCard,
                                      color: Helper.brandColors[8], size: 25),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    '${usuario.dni.toUpperCase()}',
                                    style: TextStyle(
                                      color: Helper.brandColors[5],
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(FontAwesomeIcons.at,
                                      color: Helper.brandColors[8], size: 25),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    '${usuario.email.toUpperCase()}',
                                    style: TextStyle(
                                      color: Helper.brandColors[5],
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(FontAwesomeIcons.phone,
                                        color: Helper.brandColors[8], size: 25),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    '${usuario.telefono.toUpperCase()}',
                                    style: TextStyle(
                                      color: Helper.brandColors[5],
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                        _pref.role == 1 ? TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context,
                                  usuario.role == 3
                                      ? PropietarioForm.routeName
                                      : MiembroForm.routeName,
                                  arguments: {"usuarioId": usuario.id});
                            },
                            child: Text('Editar usuario',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Helper.brandColors[8])))
                                    : Container(),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, PasswordPage.routeName,
                                  arguments: {"usuarioId": usuario.id});
                            },
                            child: Text('Cambiar contraseña',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Helper.brandColors[8]))),
                        perfilPropio
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MainButton(
                                      onPressed: () async {
                                        try {
                                          openLoadingDialog(context,
                                              mensaje: 'Sincronizando...');
                                          final response = await _usuarioService
                                              .setTokenDevice(_usuarioId,
                                                  NotificationService.token!);
                                          closeLoadingDialog(context);
                                          if (response.fallo) {
                                            openAlertDialog(context,
                                                'Error al sincronizar dispositivo',
                                                subMensaje: response.error);
                                            return;
                                          }
                                          openAlertDialog(context,
                                              'Dispositivo sincronizado con éxito');
                                        } catch (err) {
                                          closeLoadingDialog(context);
                                          openAlertDialog(context,
                                              'Error al sincronizar dispositivo',
                                              subMensaje: err.toString());
                                        }
                                      },
                                      width: 250,
                                      height: 35,
                                      fontSize: 15,
                                      color: Helper.brandColors[8],
                                      text: 'Sincronizar notificaciones'),
                                  MainButton(
                                      onPressed: () {
                                        final deleteDevices = (context) async {
                                          openLoadingDialog(context,
                                              mensaje:
                                                  'Desasociando dispositivos...');
                                          final response = await _usuarioService
                                              .deleteAllDevice(_usuarioId);
                                          // closeLoadingDialog(context);
                                          Navigator.pop(
                                              _scaffoldKey.currentContext!);
                                          if (response.fallo) {
                                            openAlertDialog(
                                                _scaffoldKey.currentContext!,
                                                'Error al sincronizar dispositivo',
                                                subMensaje: response.error);
                                            return;
                                          }
                                          openAlertDialog(
                                              _scaffoldKey.currentContext!,
                                              'Dispositivo sincronizado con éxito');
                                        };
                                        openDialogConfirmation(
                                            _scaffoldKey.currentContext!,
                                            deleteDevices,
                                            'Confirmar desasociacion');
                                      },
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
                                    style:
                                        TextStyle(color: Helper.brandColors[5]),
                                  ),
                                ),
                                onPressed: () async {
                                  final confirma =
                                      await openDialogConfirmationReturn(
                                          context,
                                          'Confirmar para eliminar personal');

                                  // eliminar obra
                                  openLoadingDialog(context,
                                      mensaje: 'Eliminando personal...');
                                  final response = await _usuarioService
                                      .deleteUsuario(_usuarioId);
                                  closeLoadingDialog(context);
                                  if (response.fallo) {
                                    openAlertDialog(
                                        context, 'Error al desactivar usuario',
                                        subMensaje: response.error);
                                  } else {
                                    await openAlertDialogReturn(context,
                                        'Usuario desactivado con éxito');
                                    Navigator.pop(context);
                                  }
                                })
                            : Container()
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}
