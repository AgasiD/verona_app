import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/listas/contactos.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

import '../../services/socket_service.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);
  static final routeName = 'chat_list';

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketService>(context, listen: false);
    final _chatService = Provider.of<ChatService>(context, listen: false);
    final _pref = new Preferences();
    _socketService.connect(_pref.id);
    final _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    TextEditingController txtController = new TextEditingController();
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
                    final chatsUsuario = usuario.chats
                        .map((e) => e["chatId"] as String)
                        .toList() as List<String>;
                    return _UsuariosChats(
                        chatService: _chatService,
                        chatsUsuario: chatsUsuario,
                        usuario: usuario,
                        txtController: txtController);
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height - 140,
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
                      ),
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

class _UsuariosChats extends StatelessWidget {
  const _UsuariosChats({
    Key? key,
    required ChatService chatService,
    required this.chatsUsuario,
    required this.usuario,
    required this.txtController,
  })  : _chatService = chatService,
        super(key: key);

  final ChatService _chatService;
  final List<String> chatsUsuario;
  final Miembro usuario;
  final TextEditingController txtController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _chatService.obtenerChats(chatsUsuario),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Loading(
              mensaje: 'Recuperando mensajes',
            );
          } else {
            final response = snapshot.data as MyResponse;
            (response.data as List<dynamic>).forEach((chat) {
              final data = this
                  .usuario
                  .chats
                  .where((element) => element['chatId'] == chat['id'])
                  .toList()
                  .first;
              chat.addAll({'nombre': data['nombre']});
              // print(data);
            });

            var chats = response.data as List;
            chats.sort((a, b) {
              if (a['tsUltimoMensaje'] > b['tsUltimoMensaje'])
                return 1;
              else if (a['tsUltimoMensaje'] < b['tsUltimoMensaje']) {
                return -1;
              } else {
                return 0;
              }
            });
            return CustomSearchListView(
              data: chats,
              txtController: txtController,
            );
          }
        });
  }
}
