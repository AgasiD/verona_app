import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/contactos.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

import '../../services/socket_service.dart';

class ChatList extends StatelessWidget {
  const ChatList({Key? key}) : super(key: key);
  static final routeName = 'chat_list';

  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketService>(context, listen: false);
    final _pref = new Preferences();
    _socketService.connect(_pref.id);
    final _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    TextEditingController txtController = new TextEditingController();
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Helper.brandColors[1],
          child: SafeArea(
            child: FutureBuilder(
                future: _usuarioService.obtenerUsuario(_pref.id),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Loading(mensaje: 'Cargando chats');
                  } else {
                    final response = MyResponse.fromJson(
                        snapshot.data as Map<String, dynamic>);
                    final usuario = Miembro.fromJson(response.data);
                    usuario.chats = usuario.chats
                        .where((element) => element['individual'] == true)
                        .toList();

                    if (usuario.chats.length > 0) {
                      final dataTile = usuario.chats.map((e) => Helper.toCustomTile(
                          '${e['nombre']}',
                          'Previsualizacion',
                          '${(e['nombre'][0] + e['nombre'][1]).toString().toUpperCase()}'));
                      return CustomSearchListView(
                        data: usuario.chats,
                        txtController: txtController,
                      );
                    } else {
                      return Column(
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height - 200,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Text(
                                  'Aún no tiene conversaciones',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Helper.brandColors[4]),
                                ),
                              )),
                        ],
                      );
                    }
                  }
                }),
          ),
        ),
      ),
      floatingActionButton: CustomNavigatorButton(
        accion: () => Navigator.pushNamed(context, ContactsPage.routeName),
        icono: Icons.add,
        showNotif: false,
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}
