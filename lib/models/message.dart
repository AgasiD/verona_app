import 'package:flutter/foundation.dart';

class Message {
  String messageId;
  String chatId;
  String from;
  String name;
  String mensaje;
  int ts;
  Message(
      {this.messageId = '',
      required this.chatId,
      required this.from,
      required this.name,
      required this.mensaje,
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
      );

  toMap() => {
        'messageId': this.messageId,
        'chatId': this.chatId,
        'from': this.from,
        'mensaje': this.mensaje,
        'ts': this.ts,
        'name': this.name
      };
}
