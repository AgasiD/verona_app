import 'package:flutter/foundation.dart';

import '../pages/chat.dart';

class Message {
  String messageId;
  String chatId;
  String from;
  String name;
  String mensaje;
  int ts;
  List<dynamic> members;
  Message(
      {this.messageId = '',
      required this.chatId,
      required this.from,
      required this.name,
      required this.mensaje,
      required this.members,
      required this.ts}) {
    this.chatId = chatId;
    this.from = from;
    this.name = name;
    this.mensaje = mensaje;
    this.ts = ts;
  }

  factory Message.fromMap(Map<String, dynamic> json) => Message(
        name: json.containsKey('name') ? json['name'] : 'Sin nombre',
        messageId: json["messageId"],
        chatId: json["chatId"],
        from: json["from"],
        mensaje: json["mensaje"],
        ts: json.containsKey('ts') ? json["ts"] : 1,
        members: json.containsKey('members') ? json["members"] : [],
      );

  toMap() => {
        'messageId': this.messageId,
        'chatId': this.chatId,
        'from': this.from,
        'mensaje': this.mensaje,
        'ts': this.ts,
        'name': this.name,
        'members': this.members
      };
  MessageBox toWidget(id) => MessageBox(
      esMsgPropio: from == id,
      messageText: mensaje,
      name: name,
      animatorController: null,
      ts: ts);
}
