import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/password.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class PerfilPage extends StatelessWidget {
  PerfilPage({Key? key}) : super(key: key);
  static final routeName = 'perfil';
  Preferences _pref = new Preferences();

  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context);

    return Scaffold(
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
            future: _usuarioService.obtenerUsuario(_pref.id),
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
                  return Container(
                    height: MediaQuery.of(context).size.height - 100,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: 500,
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
                                  child: Text(
                                    '${usuario.nombre[0].toUpperCase()} ${usuario.apellido[0].toUpperCase()}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Helper.brandColors[5],
                                    ),
                                  )),
                            ),
                          ),
                          Text(
                            '${usuario.nombre.toUpperCase()} ${usuario.apellido.toUpperCase()}',
                            style: TextStyle(
                                color: Helper.brandColors[5], fontSize: 25),
                          ),
                          Text(
                            '${Helper.getProfesion(usuario.role).toUpperCase()}',
                            style: TextStyle(
                              color: Helper.brandColors[3],
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${usuario.dni.toUpperCase()}',
                            style: TextStyle(
                              color: Helper.brandColors[5],
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${usuario.email.toUpperCase()}',
                            style: TextStyle(
                              color: Helper.brandColors[5],
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${usuario.telefono.toUpperCase()}',
                            style: TextStyle(
                              color: Helper.brandColors[5],
                              fontSize: 18,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, PasswordPage.routeName,
                                    arguments: {"usuarioId": usuario.id});
                              },
                              child: Text('Cambiar contraseña',
                                  style:
                                      TextStyle(color: Helper.brandColors[8])))
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
