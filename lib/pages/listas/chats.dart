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
    final _chatService = Provider.of<ChatService>(context);
    return Scaffold(
      body: Container(
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
                    return ListView.builder(
                        itemCount: usuario.chats.length,
                        itemBuilder: ((context, index) {
                          final esPar = index % 2 == 0;
                          final arg = {
                            'chatId': usuario.chats[index]['chatId'],
                            'chatName': usuario.chats[index]['nombre'],
                          };
                          return CustomListTile(
                            esPar: esPar,
                            title: usuario.chats[index]['nombre'],
                            subtitle: 'Ultimo mensaje',
                            avatar: (usuario.chats[index]['nombre'][0] +
                                    usuario.chats[index]['nombre'][1])
                                .toString()
                                .toUpperCase(),
                            fontSize: 18,
                            onTap: true,
                            actionOnTap: () => Navigator.pushNamed(
                                context, ChatPage.routeName,
                                arguments: arg),
                          );
                        }));
                  } else {
                    return Column(
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height - 200,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                'A??n no tiene conversaciones',
                                style: TextStyle(
                                    fontSize: 18, color: Helper.brandColors[4]),
                              ),
                            )),
                      ],
                    );
                  }
                }
              }),
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
