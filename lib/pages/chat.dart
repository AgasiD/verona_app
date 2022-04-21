// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
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

  @override
  Widget build(BuildContext context) {
    final _service = Provider.of<ChatService>(context);
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final chatId = arguments['chatId'];
    final txtController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Helper.primaryColor?.withOpacity(0.3),
        title: Column(
          children: [
            CircleAvatar(
                backgroundColor: Helper.primaryColor?.withOpacity(0.3),
                child: Text('${_pref.nombre[0]}',
                    style: TextStyle(color: Colors.white70))),
          ],
        ),
      ),
      body: FutureBuilder(
          future: _service.loadChat(chatId: chatId),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Loading();
            } else {
              messages = snapshot.data as List<Message>;
              messageList = messages
                  .map((e) => MessageBox(
                      esMsgPropio: e.from == _pref.id,
                      messageText: e.mensaje,
                      name: e.name))
                  .toList();
              return ListMessageBox(
                  messages: messages,
                  messageList: messageList,
                  txtController: txtController,
                  chatId: chatId);
            }
          }),
    );
  }
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
      print('NUEVO MENSAJE AJENO');
      widget.messages.add(mensaje);
      final mBox = MessageBox(
          esMsgPropio: false, messageText: mensaje.mensaje, name: mensaje.name);
      widget.messageList.add(mBox);
      setState(() {});
    } else if (mensaje.from == _pref.id && propio) {
      print('NUEVO MENSAJE PROPIO');
      widget.messages.insert(0, mensaje);
      final mBox = MessageBox(
          esMsgPropio: true, messageText: mensaje.mensaje, name: mensaje.name);
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
        ts: DateTime.now());

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
      required this.name})
      : super(key: key);

  final bool esMsgPropio;
  final String messageText;
  final String name;

  @override
  Widget build(BuildContext context) {
    final List<Widget> list = [
      CircleAvatar(
        child: Text(name.substring(0, 2).toUpperCase()),
        backgroundColor: Colors.red.shade300,
      ),
      _ChatMessage(
          esMsgPropio: esMsgPropio, name: name, messageText: messageText)
    ];

    return Container(
        child: _ChatMessage(
            esMsgPropio: esMsgPropio, name: name, messageText: messageText));
  }
}

class _ChatMessage extends StatelessWidget {
  const _ChatMessage(
      {Key? key,
      required this.esMsgPropio,
      required this.messageText,
      required this.name})
      : super(key: key);

  final bool esMsgPropio;
  final String messageText;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: !esMsgPropio ? Alignment.centerLeft : Alignment.centerRight,
      child: LimitedBox(
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
              color: esMsgPropio
                  ? Helper.primaryColor?.withOpacity(0.3)
                  : Colors.red.shade100,
              borderRadius: BorderRadius.circular(7)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              !esMsgPropio
                  ? Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : SizedBox(),
              SizedBox(
                height: 4,
              ),
              Text(
                messageText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
