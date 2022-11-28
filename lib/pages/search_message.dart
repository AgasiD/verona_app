import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/message.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class Search_Message_Screen extends StatefulWidget {
  static final routeName = 'Search_Message_Screen';
  Search_Message_Screen({Key? key}) : super(key: key);

  @override
  State<Search_Message_Screen> createState() => _Search_Message_ScreenState();
}

class _Search_Message_ScreenState extends State<Search_Message_Screen> {
  TextEditingController txtCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final chatName = arguments['chatName'];
    final chatId = arguments['chatId'];
    final _chatService = Provider.of<ChatService>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: Helper.brandColors[0],
        appBar: _AppBar(chatName: chatName),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: txtCtrl.text.isEmpty
                    ? Center(
                        child: Text(
                          'Buscar mensajes',
                          style: TextStyle(
                              fontSize: 18, color: Helper.brandColors[4]),
                        ),
                      )
                    : FutureBuilder(
                        future:
                            _chatService.buscarMensajes(chatId, txtCtrl.text),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return Loading(mensaje: 'Buscando mensajes...');

                          final response = snapshot.data as MyResponse;
                          if (response.fallo) {
                            return Center(
                              child: Text(
                                'Error al recuperar la información',
                                style: TextStyle(
                                    fontSize: 18, color: Helper.brandColors[4]),
                              ),
                            );
                          }
                          final mensajes = (response.data as List)
                              .map((json) => Message.fromMap(json))
                              .toList();

                          return _Messages_List(mensajes: mensajes);
                        },
                      ),
              ),
              _InputChat(
                  txtCtrl: txtCtrl,
                  action: () {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    setState(() {});
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  _AppBar({
    Key? key,
    this.chatName = '',
  }) : super(key: key);
  String chatName;

  @override
  // TODO: implement preferredSize
  Size get preferredSize => new Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Helper.brandColors[0],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text('${chatName}',
                  style: TextStyle(color: Helper.brandColors[8]))
            ],
          ),
        ],
      ),
    );
  }
}

class _Messages_List extends StatelessWidget {
  _Messages_List({
    Key? key,
    required this.mensajes,
  }) : super(key: key);

  List<Message> mensajes;

  @override
  Widget build(BuildContext context) {
    if (mensajes.length == 0)
      return Center(
        child: Text(
          'No se encontraron mensajes ',
          style: TextStyle(fontSize: 18, color: Helper.brandColors[4]),
        ),
      );
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        child: ListView.builder(
          itemCount: mensajes.length,
          itemBuilder: (context, index) =>
              _Searche_Message(mensaje: mensajes[index], index: index),
        ),
      ),
    );
  }
}

/*Message(
                chatId: '',
                from: '',
                mensaje: 'Gola como etsa',
                name: 'Damian',
                members: [],
                ts: 0,
                messageId: '') */

class _Searche_Message extends StatelessWidget {
  _Searche_Message({Key? key, required this.mensaje, required this.index})
      : super(key: key);

  int index;
  Message mensaje;

  @override
  Widget build(BuildContext context) {
    final _pref = Preferences();

    return FadeIn(
      child: ListTile(
        title: Text(
          mensaje.from == _pref.id ? 'Yo' : mensaje.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          mensaje.mensaje,
          style: TextStyle(color: Helper.brandColors[8]),
        ),
        iconColor: Helper.brandColors[3],
        textColor: Helper.brandColors[3],
        tileColor: Helper.brandColors[0],
        trailing: Wrap(alignment: WrapAlignment.end, children: [
          Text(
            Helper.getFechaHoraFromTS(mensaje.ts),
            style: TextStyle(color: Helper.brandColors[3]),
          ),
          Icon(Icons.arrow_forward_ios_rounded),
        ]),
        onTap: () => Navigator.pushNamed(context, ChatPage.routeName,
            arguments: {
              "chatName": mensaje.name,
              "chatId": mensaje.chatId,
              "fromTS": mensaje.ts
            }),
      ),
    );
  }
}

class _InputChat extends StatefulWidget {
  _InputChat({Key? key, required this.txtCtrl, required this.action})
      : super(key: key);
  TextEditingController txtCtrl;
  Function() action;

  @override
  State<_InputChat> createState() => __InputChatState();
}

class __InputChatState extends State<_InputChat> {
  Preferences _pref = Preferences();
  @override
  Widget build(BuildContext context) {
    final focusNode = new FocusNode();
    return Container(
      height: 50,
      color: Helper.brandColors[3],
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Flexible(
              child: TextField(
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.search,
            focusNode: focusNode,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Escriba palabra clave a buscar',
                isCollapsed: true),
            controller: widget.txtCtrl,
            onSubmitted: (_) => widget.action,
            onChanged: (text) {
              // widget.txtCtrl.text = text;
              // setState(() {});
            },
          )),
          Platform.isAndroid
              ? IconButton(icon: Icon(Icons.send), onPressed: widget.action)
              : CupertinoButton(
                  child: Text(
                    'Buscar',
                    style: TextStyle(fontSize: 15),
                  ),
                  onPressed: widget.action)
        ],
      ),
    );
  }
}
