// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import '../models/message.dart';
import '../widgets/custom_widgets.dart';

class ChatPage extends StatefulWidget {
  static const String routeName = 'chat';
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with RouteAware, TickerProviderStateMixin {
  final focusNode = new FocusNode();
  List<MessageBox> messageList = [];
  List<Message> messages = [];
  Preferences _pref = Preferences();
  String chatName = 'Sin nombre';
  late ChatService _chatService =
      Provider.of<ChatService>(context, listen: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatService = Provider.of<ChatService>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final chatId = arguments['chatId'];

    final txtController = TextEditingController();
    final _socketService = Provider.of<SocketService>(context, listen: false);
    quitarNovedad(chatId, _socketService);
    return Container(
      color: Colors.white,
      child: FutureBuilder(
          future: _chatService.loadChat(chatId: chatId, limit: 25, offset: 0),
          builder: (_, snapshot) {
            if (snapshot.data == null) {
              return Loading(
                mensaje: 'Recuperando mensajes...',
              );
            } else {
              _chatService.chat.chatName == ''
                  ? chatName = arguments['chatName']
                  : chatName = _chatService.chat.chatName;

              return Scaffold(
                  appBar: _CustomChatBar(chatName: chatName),
                  body: ListMessageBox(
                      members: _chatService.chat.members,
                      txtController: txtController,
                      chatId: chatId));
            }
          }),
    );
  }

  void quitarNovedad(String chatId, SocketService _socketService) {
    final dato = (_socketService.novedades ?? []).where(
        (novedad) => novedad['tipo'] == 1 && novedad['chatId'] == chatId);

    if (dato.length == 0) return;
    final _pref = Preferences();
    _socketService.quitarNovedad(_pref.id, dato.map((e) => e['id']).toList());
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
  late ChatService _chatService;
  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<ChatService>(context, listen: false);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketService>(context);
    return AppBar(
      backgroundColor: Helper.brandColors[0],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text('${widget.chatName}',
                  style: TextStyle(color: Helper.brandColors[8]))
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
    required this.txtController,
    required this.chatId,
  }) : super(key: key);

  List<dynamic> members;
  final TextEditingController txtController;
  final String chatId;

  @override
  State<ListMessageBox> createState() => _ListMessageBoxState();
}

class _ListMessageBoxState extends State<ListMessageBox>
    with TickerProviderStateMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _pref = new Preferences();
  late ChatService _chatService;
  late List<Message> mensajes;

  late final header;
  int offset = 0;

  List<MessageBox> mensajesBox = [];

  void _onLoad(
      ChatService _chatService, String chatId, int offset, int limit) async {
    final response = await _chatService.loadChat(
        chatId: chatId, limit: Helper.limit, offset: offset);

    if (response.fallo) {
      _refreshController.loadFailed();
    } else {
      final mensajesNuevos = (response.data['message'] as List<dynamic>);
      if (mensajesNuevos.length > 0) {
        // print(mensajes);
        mensajesNuevos.forEach((element) {
          //inserto al principio del chat (mensaje viejo)
          mensajes.add(Message.fromMap(element));
        });

        this.mensajesBox = mensajes.map((e) => e.toWidget(_pref.id)).toList();

        _refreshController.loadComplete();
        setState(() {});
      }
    }
  }

  late SocketService _socketService;
  late UsuarioService _usuarioService;

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<ChatService>(context, listen: false);
    _usuarioService = Provider.of<UsuarioService>(context, listen: false);
    Platform.isIOS
        ? header = WaterDropHeader()
        : header = MaterialClassicHeader();

    mensajes =
        _chatService.chat.messages.map((e) => Message.fromMap(e)).toList();

    _socketService = Provider.of<SocketService>(context, listen: false);

    _socketService.socket.on('nuevo-mensaje', (data) {
      //Escucha mensajes del servidor
      _recibirMensaje(data);
    });

    cargarHistorial();
    leerUltimoMensaje(mensajes.first);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // _socketService.socket.off('nuevo-mensaje');

    super.dispose();
  }

  void leerUltimoMensaje(mensaje) async {
    if (mensajes.length > 0) {
      // print(mensajes.first.ts);
      await _usuarioService.ultimoMensajeLeido(
          _pref.id, widget.chatId, mensaje.ts ?? 0);
      _chatService.notifyListeners();
    }
  }

  void _recibirMensaje(dynamic data) async {
    if (this.mounted) {
      final mensaje = Message.fromMap(data);
      if (mensaje.chatId == _chatService.chat.chatId) {
        //si el mensaje pertenece al chat actual

        if (mensaje.from != _pref.id) {
          agregarMensaje(mensaje, false);
          // print(mensaje.ts);
          ModalRoute.of(context)!.settings.name == ChatPage.routeName
              ? leerUltimoMensaje(mensaje)
              : false;
          // print(mensajes.last.ts);

          //Vibration.vibrate(duration: 75, amplitude: 128);
        } else {
          //si es mensaje propio

        }
      } else {
        // no hacer nada

      }
    }
  }

  void agregarMensaje(dynamic data, bool propio) {
    if (this.mounted) {
      final mensaje = data;
      //agrego mensaje
      mensajes.add(mensaje);
      final mBox = MessageBox(
          esMsgPropio: propio,
          messageText: mensaje.mensaje,
          name: mensaje.name,
          animatorController: AnimationController(
              vsync: this, duration: Duration(milliseconds: 200)),
          ts: mensaje.ts);
      mBox.animatorController!.forward();
      //lo inserto al final de la pantalla (como mensaje reciente)
      mensajesBox.insert(0, mBox);

      // if (this.mounted) {
      setState(() {});
    }
    //  }
  }

  void cargarHistorial() {
    this.mensajesBox = mensajes.map((e) => e.toWidget(_pref.id)).toList();
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   // _socketService.socket.off('nuevo-mensaje');
  //   super.dispose();

  // }

  @override
  Widget build(BuildContext context) {
    final _chatService = Provider.of<ChatService>(context, listen: false);
    _socketService.connect(_pref.id);

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 0),
      color: Helper.brandColors[1],
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
              itemCount: mensajesBox.length,
              itemBuilder: (_, i) => mensajesBox.toList()[i],
              physics: BouncingScrollPhysics(),
            ),
          )),
          Divider(
            height: 1,
            color: Colors.grey,
          ),
          SafeArea(
              child: Container(
            height: 50,
            child: _InputChat(
              txtCtrl: widget.txtController,
              messageList: [], //widget.messages,

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
      required this.txtCtrl,
      required this.messageList,
      required this.agregarMensaje})
      : super(key: key);
  TextEditingController txtCtrl;
  List<Message> messageList;
  final Function agregarMensaje;

  @override
  State<_InputChat> createState() => __InputChatState();
}

class __InputChatState extends State<_InputChat> {
  Preferences _pref = Preferences();
  late ChatService _chatService;
  @override
  Widget build(BuildContext context) {
    final focusNode = new FocusNode();
    final _socket = Provider.of<SocketService>(context);
    _chatService = Provider.of<ChatService>(context, listen: false);
    return Container(
      color: Helper.brandColors[3],
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Flexible(
              child: TextField(
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.send,
            focusNode: focusNode,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Escriba mensaje',
                isCollapsed: true),
            controller: widget.txtCtrl,
            onSubmitted: (_) async {
              if (widget.txtCtrl.text.trim().length > 0) {
                _socket.socket.connected
                    ? await enviarMensaje(_socket)
                    : openAlertDialog(
                        context, 'No hay conexión con el servidor');
                focusNode.requestFocus(); //para solicitar el foco
                // widget.txtCtrl.clear();
              }
            },
            onChanged: (text) {
              // setState(() {});
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
    );
  }

  Future<void> enviarMensaje(SocketService _socket) async {
    final mensaje = Message(
        chatId: _chatService.chatId,
        from: _pref.id,
        name: _pref.nombre,
        mensaje: widget.txtCtrl.text,
        members: _chatService.chat.members,
        ts: DateTime.now().millisecondsSinceEpoch);

    widget.agregarMensaje(mensaje, true);
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
      this.animatorController,
      required this.ts})
      : super(key: key);

  final bool esMsgPropio;
  final String messageText;
  final String name;
  final int ts;
  final AnimationController? animatorController;

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
    var textbox;
    animatorController == null
        ? textbox = Container(
            child: _ChatMessage(
                esMsgPropio: esMsgPropio,
                name: name,
                messageText: messageText,
                ts: ts))
        : textbox = FadeTransition(
            opacity: animatorController!,
            child: SizeTransition(
                sizeFactor: CurvedAnimation(
                    curve: Curves.easeIn, parent: animatorController!),
                child: Container(
                    child: _ChatMessage(
                        esMsgPropio: esMsgPropio,
                        name: name,
                        messageText: messageText,
                        ts: ts))));

    return textbox;
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
    final fechaMensaje = Helper.getFechaHoraFromTS(widget.ts);

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
                            angle: widget.esMsgPropio ? 15 : 10.0,
                            child: Container(
                              color: widget.esMsgPropio
                                  ? Colors.grey[shade * 2]
                                  : Helper.brandColors[7],
                            ))),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          color: widget.esMsgPropio
                              ? Colors.grey[shade * 2]
                              : Helper.brandColors[7],
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
