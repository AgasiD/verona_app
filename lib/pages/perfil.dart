import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_fade/image_fade.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/forms/miembro.dart';
import 'package:verona_app/pages/password.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

import '../services/image_service.dart';

class PerfilPage extends StatelessWidget {
  PerfilPage({Key? key}) : super(key: key);
  static final routeName = 'perfil';
  late String _usuarioId;

  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context);
    final _imageService = Provider.of<ImageService>(context);
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    _usuarioId = arguments['usuarioId'];
    String textoImg = 'Cambiar imagen';
    bool sinImg = false;

    return Scaffold(
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
                MyResponse response =
                    MyResponse.fromJson(snapshot.data as Map<String, dynamic>);
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
                    height: MediaQuery.of(context).size.height - 100,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: 600,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  radius: 50,
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
                            alignment: Alignment.center,
                            child: Text(
                              '${usuario.nombre.toUpperCase()} ${usuario.apellido.toUpperCase()}',
                              style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: Helper.brandColors[5],
                                  fontSize: 25),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(FontAwesomeIcons.solidUser,
                                    color: Helper.brandColors[8], size: 25),
                              ),
                              Text(
                                '${usuario.username.toUpperCase()}',
                                style: TextStyle(
                                    color: Helper.brandColors[3], fontSize: 20),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(FontAwesomeIcons.briefcase,
                                    color: Helper.brandColors[8], size: 25),
                              ),
                              Text(
                                '${Helper.getProfesion(usuario.role).toUpperCase()}',
                                style: TextStyle(
                                  color: Helper.brandColors[5],
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(FontAwesomeIcons.idCard,
                                    color: Helper.brandColors[8], size: 25),
                              ),
                              Text(
                                '${usuario.dni.toUpperCase()}',
                                style: TextStyle(
                                  color: Helper.brandColors[5],
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(FontAwesomeIcons.at,
                                    color: Helper.brandColors[8], size: 25),
                              ),
                              Text(
                                '${usuario.email.toUpperCase()}',
                                style: TextStyle(
                                  color: Helper.brandColors[5],
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(FontAwesomeIcons.phone,
                                      color: Helper.brandColors[8], size: 25),
                                ),
                              ),
                              Text(
                                '${usuario.telefono.toUpperCase()}',
                                style: TextStyle(
                                  color: Helper.brandColors[5],
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, MiembroForm.routeName,
                                    arguments: {"usuarioId": usuario.id});
                              },
                              child: Text('Editar usuario',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Helper.brandColors[8]))),
                          TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, PasswordPage.routeName,
                                    arguments: {"usuarioId": usuario.id});
                              },
                              child: Text('Cambiar contraseña',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Helper.brandColors[8])))
                        ],
                      ),
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
