// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:verona_app/helpers/helpers.dart';

class ChatPage extends StatefulWidget {
  static const String routeName = 'chat';
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final txtController = TextEditingController();
  final focusNode = new FocusNode();
  final messageList = [
    MessageBox(esMsgPropio: true, messageText: 'Hola!', name: 'Damián Agasi'),
    MessageBox(
        esMsgPropio: false,
        messageText: 'Hola, como andas?',
        name: 'Damián Agasi'),
    MessageBox(
        esMsgPropio: true, messageText: 'Muy bien y vos', name: 'Damián Agasi'),
    MessageBox(
        esMsgPropio: false,
        messageText:
            'Bien bien, te queria contar que estoy trabajando en un nuevo proyecto que incumbe el desarrollo de una app para una empresa constructora!',
        name: 'Damián Agasi'),
    MessageBox(
        esMsgPropio: true, messageText: 'Buenisimo', name: 'Damián Agasi'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Helper.primaryColor?.withOpacity(0.3),
        title: Column(
          children: [
            CircleAvatar(
                backgroundColor: Helper.primaryColor?.withOpacity(0.3),
                child: Text('DA', style: TextStyle(color: Colors.white70))),
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
              reverse: true,
              itemCount: messageList.length,
              itemBuilder: (_, i) => messageList.reversed.toList()[i],
              physics: BouncingScrollPhysics(),
            )),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 10, bottom: 5),
                  child: txtController.text != ''
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
              child: _inputChat(),
            ))
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
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
            controller: txtController,
            onSubmitted: (_) {
              txtController.clear();
              focusNode.requestFocus(); //para solicitar el foco
            },
            onChanged: (text) {
              setState(() {});
            },
          )),
          Container(
              child: Platform.isAndroid
                  ? IconButton(
                      icon: Icon(Icons.send),
                      onPressed: txtController.text == '' ? null : () {},
                    )
                  : CupertinoButton(
                      child: Text(
                        'Enviar',
                        style: TextStyle(fontSize: 15),
                      ),
                      onPressed: txtController.text == ''
                          ? null
                          : () {
                              messageList.add(new MessageBox(
                                  esMsgPropio: true,
                                  messageText: txtController.text,
                                  name: 'Damian Agasi'));
                              txtController.text = '';
                              setState(() {});
                            }))
        ],
      ),
    ));
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
                    'Damian Agasi',
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
    );
  }
}
