import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({Key? key}) : super(key: key);
  static const String routeName = 'Chats';
  @override
  Widget build(BuildContext context) {
    final chats = [
      {
        "id": "-N-dZcZPirpY8unI9CGW",
        "nombre": 'Lionel',
        "apellido": 'Messi',
        "cantMensajes": 2,
      },
      {
        "id": "-N-dZcZPirpY8unI9CGW",
        "nombre": 'Neymar JR.',
        "apellido": '0',
        "cantMensajes": 5,
      },
      {
        "id": "-N-dZcZPirpY8unI9CGW",
        "nombre": 'Luis',
        "apellido": 'Suarez',
        "cantMensajes": 0,
      },
      {
        "id": "-N-dZcZPirpY8unI9CGW",
        "nombre": 'Luis',
        "apellido": 'Miguel',
        "cantMensajes": 1,
      },
    ];
    return Scaffold(
      appBar: CustomAppBar(
        muestraBackButton: true,
        title: 'Conversaciones',
      ),
      body: SingleChildScrollView(
          child: Container(
        width: MediaQuery.of(context).size.width,
        height: 1000,
        child: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (_, index) {
              return _ChatTile(chat: chats[index]);
            }),
      )),
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
    return Column(
      children: [
        ListTile(
          subtitle: Text('Hola como estas?'),
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Text(
              '${widget.chat['nombre'].toString()[0]}${widget.chat['apellido'].toString()[0]} ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Helper.primaryColor,
              ),
            ),
          ),
          title: Text(
              '${widget.chat["nombre"].toString()} ${widget.chat["apellido"].toString()}'),
          trailing: Container(
            width: 80,
            // alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.chat["cantMensajes"] != 0
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
            Navigator.pushNamed(context, ChatPage.routeName,
                arguments: {'chatId': widget.chat["id"]});
          },
        ),
        Divider()
      ],
    );
  }
}
