import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/pages/listas/contactos.dart';
import 'package:verona_app/services/chat_service.dart';

import 'package:verona_app/widgets/custom_widgets.dart';

import '../../services/socket_service.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);
  static const routeName = 'chat_list';

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> with RouteAware {
 
  TextEditingController txtController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _chatService = Provider.of<ChatService>(context);
    final _socketService = Provider.of<SocketService>(context, listen: false);
    final _pref = new Preferences();
    _socketService.connect(_pref.id);
    return Scaffold(
      body: Container(
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
              future: _chatService.obtenerChats(_pref.id),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Loading(mensaje: 'Cargando chats');
                } else {
                  final response = snapshot.data as MyResponse;
                  final chats = response.data as List;
                  if (chats.length > 0) {
                    return _UsuariosChats(
                        chats: chats, txtController: txtController);
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
    required this.chats,
    // required this.usuario,
    required this.txtController,
  }) : super(key: key);

  final List<dynamic> chats;
  // final Miembro usuario;
  final TextEditingController txtController;

  @override
  Widget build(BuildContext context) {
    return ChatsList(
      data: chats,
      txtController: txtController,
    );
  }
}
