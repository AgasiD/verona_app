// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/obra_service.dart';
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
      color: Colors.white,
      child: FutureBuilder(
          future: _service.loadChat(chatId: chatId, limit: 25, offset: 0),
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
                final members = response.data["members"] as List<dynamic>;
                chatName = response.data['chatName'];
                chatName == '' ? chatName = arguments['chatName'] : false;
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
                        members: members,
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
    final _socketService = Provider.of<SocketService>(context);
    _socketService.socket.connect();
    return AppBar(
      backgroundColor: Helper.primaryColor?.withOpacity(0.3),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text('${widget.chatName}',
                  style: TextStyle(color: Colors.white70))
            ],
          ),
          _socketService.socket.connected
              ? CircleAvatar(
                  maxRadius: 5,
                  backgroundColor: Colors.green[400],
                )
              : CircleAvatar(
                  maxRadius: 5,
                  backgroundColor: Colors.red[400],
                )
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
    required this.members,
    required this.messages,
    required this.messageList,
    required this.txtController,
    required this.chatId,
  }) : super(key: key);

  final List<Message> messages;
  List<MessageBox> messageList;
  List<dynamic> members;
  final TextEditingController txtController;
  final String chatId;

  @override
  State<ListMessageBox> createState() => _ListMessageBoxState();
}

class _ListMessageBoxState extends State<ListMessageBox> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _pref = new Preferences();

  late final header;
  int offset = 0;

  void _onLoad(
      ChatService _chatService, String chatId, int offset, int limit) async {
    final response = await _chatService.loadChat(
        chatId: chatId, limit: Helper.limit, offset: offset);

    if (response.fallo) {
      _refreshController.loadFailed();
    } else {
      final mensajesNuevos = (response.data['message'] as List<dynamic>);

      mensajesNuevos.reversed.forEach((element) {
        widget.messages.insert(0, Message.fromMap(element));
      });
      widget.messageList = widget.messages
          .map((e) => MessageBox(
              esMsgPropio: e.from == _pref.id,
              messageText: e.mensaje,
              name: e.name,
              ts: e.ts))
          .toList();

      _refreshController.loadComplete();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    Platform.isIOS
        ? header = WaterDropHeader()
        : header = MaterialClassicHeader();

    final _socket = Provider.of<SocketService>(context, listen: false);
    _socket.socket.on('nuevo-mensaje', (data) {
      _recibirMensaje(data);
    }); //Escucha mensajes del servidor
  }

  void _recibirMensaje(dynamic data) {
    if (data['id'] == _pref.id) {
    } else {
      agregarMensaje(data, false);
      //Vibration.vibrate(duration: 75, amplitude: 128);
    }
  }

  void agregarMensaje(dynamic data, bool propio) {
    final mensaje = Message.fromMap(data);
    if (mensaje.from != _pref.id && !propio) {
      if (mensaje.chatId == widget.chatId) {
        widget.messages.add(mensaje);
        final mBox = MessageBox(
            esMsgPropio: false,
            messageText: mensaje.mensaje,
            name: mensaje.name,
            ts: mensaje.ts);
        widget.messageList.add(mBox);
        if (this.mounted) {
          setState(() {
            // Your state change code goes here
          });
        }
      }
    } else if (mensaje.from == _pref.id && propio) {
      widget.messages.insert(0, mensaje);
      final mBox = MessageBox(
          esMsgPropio: true,
          messageText: mensaje.mensaje,
          name: mensaje.name,
          ts: mensaje.ts);
      widget.messageList.add(mBox);
      if (this.mounted) {
        setState(() {
          // Your state change code goes here
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _chatService = Provider.of<ChatService>(context, listen: false);
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 30),
      child: Column(
        children: [
          Flexible(
              child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            controller: _refreshController,
            onLoading: () {
              offset = offset + 25;
              _onLoad(_chatService, widget.chatId, offset, Helper.limit);
            },
            header: header,
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body = Text('');

                if (mode == LoadStatus.loading) {
                  body = CupertinoActivityIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = Text("Load Failed!Click retry!");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("Cargar mas mensajes...");
                }
                ;
                return Container(
                  child: Center(child: body),
                );
              },
            ),
            child: ListView.builder(
              reverse: true,
              itemCount: widget.messages.length,
              itemBuilder: (_, i) => widget.messageList.reversed.toList()[i],
              physics: BouncingScrollPhysics(),
            ),
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
              members: widget.members,
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
      required this.members,
      required this.agregarMensaje})
      : super(key: key);
  String chatId;
  List<dynamic> members;
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
                          onPressed: () {
                            _socket.socket.connected
                                ? enviarMensaje(_socket)
                                : openAlertDialog(
                                    context, 'No hay conexión con el servidor');
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
                          onPressed: () {
                            _socket.socket.connected
                                ? enviarMensaje(_socket)
                                : openAlertDialog(
                                    context, 'No hay conexión con el servidor');
                          })
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
        members: widget.members,
        ts: DateTime.now().millisecondsSinceEpoch);

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
    var tiempoMensaje = DateTime.fromMillisecondsSinceEpoch(widget.ts);

    var fecha = DateFormat('dd/MM/yyyy').format(tiempoMensaje);
    final hora = tiempoMensaje.hour.toString();
    final minutos = tiempoMensaje.minute < 10
        ? '0${tiempoMensaje.minute}'
        : tiempoMensaje.minute.toString();
    final fechaMensaje;
    if (widget.ts < DateTime.now().millisecondsSinceEpoch - 24 * 3600000) {
      //mostrar
      fechaMensaje = '$fecha  ${hora}:${minutos}';
    } else {
      //no mostrar fecha
      fechaMensaje = '${hora}:${minutos}';
    }

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
                    child: Text('${fechaMensaje}',
                        style: TextStyle(color: Colors.grey)))
              ],
            ),
          ),
        ));
  }
}
