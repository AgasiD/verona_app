import 'package:badges/badges.dart';
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

import '../services/socket_service.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({Key? key}) : super(key: key);
  static const String routeName = 'Chats';
  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketService>(context, listen: false);
    final _pref = new Preferences();
    _socketService.connect(_pref.id);

    return Scaffold(
        appBar: CustomAppBar(
          muestraBackButton: true,
          title: 'Conversaciones',
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.grey[400],
          onPressed: () {
            Navigator.pushNamed(context, ContactsPage.routeName);
            //cant++;
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: _ContactList());
  }
}

class _ContactList extends StatelessWidget {
  const _ContactList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _chatService = Provider.of<ChatService>(context);
    final _usuarioService = Provider.of<UsuarioService>(context);
    final _pref = new Preferences();
    return FutureBuilder(
      future: _usuarioService.obtenerUsuario(_pref.id),
      builder: (_, snapshot) {
        if (snapshot.data == null) {
          return Loading(
            mensaje: 'Recuperando conversaciones',
          );
        } else {
          final response = snapshot.data as MyResponse;
          final usuario = Miembro.fromJson(response.data);
          usuario.chats = usuario.chats
              .where((element) => element['individual'] == true)
              .toList();
          if (response.fallo) {
            openAlertDialog(context, 'No se pudo recuperar los datos',
                subMensaje: response.error);
            return Container();
          } else {
            if (usuario.chats.length > 0) {
              return ListView.builder(
                  itemCount: usuario.chats.length,
                  itemBuilder: (_, index) {
                    return _ChatTile(chat: usuario.chats[index]);
                  });
            } else {
              return Center(
                child: Text(
                  'Aún no hay conversaciones activas ',
                  style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                ),
              );
            }
          }
        }
      },
    );
  }
}

class _ChatTile extends StatefulWidget {
  _ChatTile({Key? key, required this.chat}) : super(key: key);
  Map<String, dynamic> chat;

  @override
  State<_ChatTile> createState() => __ChatTileState();
}

class __ChatTileState extends State<_ChatTile> {
  @override
  Widget build(BuildContext context) {
    final _chatService = Provider.of<ChatService>(context, listen: false);
    final _socketService = Provider.of<SocketService>(context, listen: false);
    final _pref = new Preferences();
    _socketService.connect(_pref.id);
    return Column(
      children: [
        ListTile(
          subtitle: Text('Sin previsualizacion'),
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Text(
              '${widget.chat['nombre'].toString()[0]} ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Helper.primaryColor,
              ),
            ),
          ),
          title: Text('${widget.chat["nombre"].toString()} '),
          trailing: Container(
            width: 80,
            // alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // widget.chat["cantMensajes"] != 0
                0 != 0
                    ? Container(
                        width: 40,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.blue[50],
                        ),
                        child: Text(
                          widget.chat["cantMensajes"].toString(),
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 20,
                      ),
                Icon(Icons.arrow_forward_ios_rounded),
              ],
            ),
          ),
          onTap: () {
            _chatService.chatId = widget.chat["chatId"];
            Navigator.pushNamed(context, ChatPage.routeName, arguments: {
              'chatId': widget.chat["chatId"],
              'chatName': widget.chat["nombre"],
            });
          },
        ),
        Divider()
      ],
    );
  }
}
