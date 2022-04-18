import 'package:flutter/foundation.dart';

class Message {
  String messageId;
  String chatId;
  String from;
  String mensaje;
  DateTime ts;
  Message(
      {this.messageId = '',
      required this.chatId,
      required this.from,
      required this.mensaje,
      required this.ts}) {
    this.chatId = chatId;
    this.from = from;
    this.mensaje = mensaje;
    this.ts = ts;
  }

  factory Message.fromMap(Map<String, dynamic> json) => Message(
        messageId: json["messageId"],
        chatId: json["chatId"],
        from: json["from"],
        mensaje: json["mensaje"],
        ts: DateTime(json["ts"]),
      );

  toMap() => {
        'messageId': this.messageId,
        'chatId': this.chatId,
        'from': this.from,
        'mensaje': this.mensaje,
        'ts': this.ts,
      };
}
