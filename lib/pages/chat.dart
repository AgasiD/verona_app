// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:vibration/vibration.dart';

import '../models/message.dart';
import '../widgets/custom_widgets.dart';

class ChatPage extends StatefulWidget {
  static const String routeName = 'chat';
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final focusNode = new FocusNode();
  List<MessageBox> messageList = [];
  List<Message> messages = [];
  Preferences _pref = Preferences();
  String chatName = 'Sin nombre';
  @override
  Widget build(BuildContext context) {
    final _service = Provider.of<ChatService>(context);
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final chatId = arguments['chatId'];
    final txtController = TextEditingController();
    return Container(
      child: FutureBuilder(
          future: _service.loadChat(chatId: chatId),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Loading(
                mensaje: 'Recuperando mensajes...',
              );
            } else {
              final response = snapshot.data as MyResponse;
              if (response.fallo) {
                openAlertDialog(context, response.error);
                return Container();
              } else {
                chatName = response.data['chatName'];
                final messagesRes = response.data['message'] as List<dynamic>;
                final messages = messagesRes;
                final mensajes =
                    messages.map((e) => Message.fromMap(e)).toList();

                messageList = mensajes
                    .map((e) => MessageBox(
                        esMsgPropio: e.from == _pref.id,
                        messageText: e.mensaje,
                        name: e.name,
                        ts: e.ts))
                    .toList();
                final appbar = _CustomChatBar(chatName: chatName);
                return Scaffold(
                    appBar: appbar,
                    body: ListMessageBox(
                        messages: mensajes,
                        messageList: messageList,
                        txtController: txtController,
                        chatId: chatId));
              }
            }
          }),
    );
  }
}

class _CustomChatBar extends StatefulWidget implements PreferredSizeWidget {
  _CustomChatBar({
    Key? key,
    this.chatName = '',
  }) : super(key: key);

  String chatName;

  @override
  State<_CustomChatBar> createState() => _CustomChatBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => new Size.fromHeight(50);
}

class _CustomChatBarState extends State<_CustomChatBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Helper.primaryColor?.withOpacity(0.3),
      title: Column(
        children: [
          Text('${widget.chatName}', style: TextStyle(color: Colors.white70))
          // CircleAvatar(
          //     backgroundColor: Helper.primaryColor?.withOpacity(0.3),
          //     child: )),
        ],
      ),
    );
  }

  void setChatName(String chatName) {
    this.widget.chatName = chatName;
    setState(() {});
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}

class ListMessageBox extends StatefulWidget {
  ListMessageBox({
    Key? key,
    required this.messages,
    required this.messageList,
    required this.txtController,
    required this.chatId,
  }) : super(key: key);

  final List<Message> messages;
  List<MessageBox> messageList;
  final TextEditingController txtController;
  final String chatId;

  @override
  State<ListMessageBox> createState() => _ListMessageBoxState();
}

class _ListMessageBoxState extends State<ListMessageBox> {
  Preferences _pref = new Preferences();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final _socket = Provider.of<SocketService>(context, listen: false);
    _socket.socket.on('nuevo-mensaje', (data) {
      print('NUEVO MENSAJE');

      _recibirMensaje(data);
    }); //Escucha mensajes del servidor
  }

  void _recibirMensaje(dynamic data) {
    if (data['id'] == _pref.id) {
    } else {
      agregarMensaje(data, false);
      Vibration.vibrate(duration: 75, amplitude: 128);
    }
  }

  void agregarMensaje(dynamic data, bool propio) {
    final mensaje = Message.fromMap(data);
    print(mensaje.mensaje);
    if (mensaje.from != _pref.id && !propio) {
      print('NUEVO MENSAJE RECIBIDO');
      widget.messages.add(mensaje);
      final mBox = MessageBox(
          esMsgPropio: false,
          messageText: mensaje.mensaje,
          name: mensaje.name,
          ts: mensaje.ts);
      widget.messageList.add(mBox);
      setState(() {});
    } else if (mensaje.from == _pref.id && propio) {
      print('NUEVO MENSAJE PROPIO');
      widget.messages.insert(0, mensaje);
      final mBox = MessageBox(
          esMsgPropio: true,
          messageText: mensaje.mensaje,
          name: mensaje.name,
          ts: mensaje.ts);
      widget.messageList.add(mBox);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Flexible(
              child: ListView.builder(
            reverse: true,
            itemCount: widget.messages.length,
            itemBuilder: (_, i) => widget.messageList.reversed.toList()[i],
            physics: BouncingScrollPhysics(),
          )),
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 10, bottom: 5),
                child: widget.txtController.text != ''
                    ? Text(
                        'Damian está escribiendo...',
                        style: TextStyle(color: Colors.grey.shade500),
                      )
                    : SizedBox(),
              )),
          Divider(
            height: 1,
            color: Colors.grey,
          ),
          SafeArea(
              child: Container(
            height: 50,
            child: _InputChat(
              chatId: widget.chatId,
              txtCtrl: widget.txtController,
              messageList: widget.messages,
              agregarMensaje: agregarMensaje,
            ),
          ))
        ],
      ),
    );
  }
}

class _InputChat extends StatefulWidget {
  _InputChat(
      {Key? key,
      required this.chatId,
      required this.txtCtrl,
      required this.messageList,
      required this.agregarMensaje})
      : super(key: key);
  String chatId;
  TextEditingController txtCtrl;
  List<Message> messageList;
  final Function agregarMensaje;

  @override
  State<_InputChat> createState() => __InputChatState();
}

class __InputChatState extends State<_InputChat> {
  Preferences _pref = Preferences();

  @override
  Widget build(BuildContext context) {
    final focusNode = new FocusNode();
    final _socket = Provider.of<SocketService>(context);

    return SafeArea(
        child: Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Flexible(
              child: TextField(
            textInputAction: TextInputAction.send,
            focusNode: focusNode,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Escriba mensaje',
                isCollapsed: true),
            controller: widget.txtCtrl,
            onSubmitted: (_) {
              widget.txtCtrl.clear();
              focusNode.requestFocus(); //para solicitar el foco
            },
            onChanged: (text) {
              setState(() {});
            },
          )),
          Container(
              child: Row(
            children: [
              IconButton(
                  onPressed: () {}, icon: Icon(Icons.attach_file_outlined)),
              Platform.isAndroid
                  ? widget.txtCtrl.text == ''
                      ? IconButton(
                          onPressed: () {}, icon: Icon(Icons.mic_none_rounded))
                      : IconButton(
                          icon: Icon(Icons.send),
                          onPressed: widget.txtCtrl.text == ''
                              ? null
                              : () {
                                  enviarMensaje(_socket);
                                },
                        )
                  : widget.txtCtrl.text == ''
                      ? IconButton(
                          onPressed: _socket.socket.connected ? () {} : null,
                          icon: Icon(Icons.mic_none_rounded))
                      : CupertinoButton(
                          child: Text(
                            'Enviar',
                            style: TextStyle(fontSize: 15),
                          ),
                          onPressed: _socket.socket.connected
                              ? () {
                                  enviarMensaje(_socket);
                                }
                              : null)
            ],
          ))
        ],
      ),
    ));
  }

  void enviarMensaje(SocketService _socket) {
    final mensaje = Message(
        chatId: widget.chatId,
        from: _pref.id,
        name: _pref.nombre,
        mensaje: widget.txtCtrl.text,
        ts: DateTime.utc(
                2022, 1, 1, DateTime.now().hour, DateTime.now().minute, 0, 0, 0)
            .millisecond);

    widget.agregarMensaje(mensaje.toMap(), true);
    _socket.enviarMensaje(mensaje);
    widget.txtCtrl.text = '';
  }
}

class MessageBox extends StatelessWidget {
  const MessageBox(
      {Key? key,
      required this.esMsgPropio,
      required this.messageText,
      required this.name,
      required this.ts})
      : super(key: key);

  final bool esMsgPropio;
  final String messageText;
  final String name;
  final int ts;

  @override
  Widget build(BuildContext context) {
    final List<Widget> list = [
      CircleAvatar(
        child: Text(name.substring(0, 2).toUpperCase()),
        backgroundColor: Colors.red.shade300,
      ),
      _ChatMessage(
          esMsgPropio: esMsgPropio,
          name: name,
          messageText: messageText,
          ts: ts)
    ];

    return Container(
        child: _ChatMessage(
            esMsgPropio: esMsgPropio,
            name: name,
            messageText: messageText,
            ts: ts));
  }
}

class _ChatMessage extends StatefulWidget {
  _ChatMessage(
      {Key? key,
      required this.esMsgPropio,
      required this.messageText,
      required this.name,
      required this.ts})
      : super(key: key);

  final bool esMsgPropio;
  final String messageText;
  final String name;
  final int ts;

  @override
  State<_ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<_ChatMessage> {
  int shade = 100;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () {
          print('reenviar');
          shade = 200;
          setState(() {});
        },
        onLongPressEnd: (long) {
          print('reenviar');
          shade = 100;
          setState(() {});
        },
        child: Align(
          alignment: !widget.esMsgPropio
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: LimitedBox(
            child: Column(
              crossAxisAlignment: widget.esMsgPropio
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Positioned(
                        bottom: 15,
                        right: widget.esMsgPropio ? 5 : null,
                        left: widget.esMsgPropio ? null : 5,
                        width: 20,
                        height: 10,
                        child: Transform.rotate(
                            angle: 10.0,
                            child: Container(
                              color: widget.esMsgPropio
                                  ? Colors.grey[shade * 2]
                                  : Colors.red[shade],
                            ))),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          color: widget.esMsgPropio
                              ? Colors.grey[shade * 2]
                              : Colors.red[shade],
                          borderRadius: BorderRadius.circular(7)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !widget.esMsgPropio
                              ? Text(
                                  widget.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            widget.messageText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                    margin: EdgeInsets.only(
                        bottom: 10, left: 25, right: 25, top: 0),
                    child: Text(
                        '${DateTime(widget.ts).hour.toString()}:${DateTime(widget.ts).minute.toString()}',
                        style: TextStyle(color: Colors.grey)))
              ],
            ),
          ),
        ));
  }
}
