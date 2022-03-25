// ignore_for_file: prefer_const_constructors, unnecessary_this

import 'dart:async';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/notificaciones.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  bool muestraBackButton;
  CustomAppBar({
    this.title = 'Verona',
    this.muestraBackButton = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hideNotifications =
        ModalRoute.of(context)?.settings.name == NotificacionesPage.routeName;
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: muestraBackButton,
      actions: [
        !hideNotifications
            ? Padding(
                padding: EdgeInsets.only(right: 15, top: 5),
                child: Badge(
                  badgeContent: Text('3'),
                  badgeColor: Colors.red.shade100,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.notifications,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, NotificacionesPage.routeName);
                    },
                  ),
                ))
            : Container()
      ],
      backgroundColor: Helper.primaryColor,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(50);
}

class CustomInput extends StatefulWidget {
  final String hintText;
  final IconData icono;
  final bool isPassword;
  final TextInputType teclado;
  final TextEditingController textController;
  final double width;
  final IconButton iconButton;
  final int lines;

  const CustomInput(
      {Key? key,
      required this.hintText,
      required this.icono,
      this.isPassword = false,
      this.teclado = TextInputType.text,
      this.width = double.infinity,
      this.lines = 1,
      this.iconButton = const IconButton(onPressed: null, icon: Icon(null)),
      required this.textController})
      : super(key: key);

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: EdgeInsets.only(right: 15),
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: widget.textController,
        maxLines: widget.lines,
        autocorrect: false,
        keyboardType: widget.teclado,
        obscureText: widget.isPassword,
        decoration: InputDecoration(
            hintText: widget.hintText,
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            suffixIcon: widget.iconButton,
            prefixIcon: Icon(
              widget.icono,
              color: Helper.primaryColor,
            )),
        onChanged: (text) {
          setState(() {});
        },
      ),
      // ignore: prefer_const_literals_to_create_immutables
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(0, 3))
      ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
    );
  }
}

class CustomInputArea extends StatefulWidget {
  final String hintText;
  final IconData icono;
  final bool isPassword;
  final TextInputType teclado;
  final TextEditingController textController;
  final double width;
  final IconButton iconButton;
  final int lines;

  const CustomInputArea(
      {Key? key,
      required this.hintText,
      required this.icono,
      this.isPassword = false,
      this.teclado = TextInputType.text,
      this.width = double.infinity,
      this.lines = 1,
      this.iconButton = const IconButton(onPressed: null, icon: Icon(null)),
      required this.textController})
      : super(key: key);

  @override
  State<CustomInputArea> createState() => _CustomInputAreaState();
}

class _CustomInputAreaState extends State<CustomInputArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: EdgeInsets.symmetric(horizontal: 15),
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: widget.textController,
        maxLines: widget.lines,
        autocorrect: true,
        keyboardType: widget.teclado,
        obscureText: widget.isPassword,
        decoration: InputDecoration(
          hintText: widget.hintText,
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
        ),
        onChanged: (text) {
          setState(() {});
        },
      ),
      // ignore: prefer_const_literals_to_create_immutables
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(0, 3))
      ], color: Colors.white, borderRadius: BorderRadius.circular(5)),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  final double fontSize;
  final Color color;
  final Function() onPressed;

  const AppButton({
    Key? key,
    this.width = double.infinity,
    this.height = 50,
    this.fontSize = 22,
    required this.color,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: this.onPressed,
      color: this.color,
      elevation: 2,
      highlightElevation: 5,
      shape: StadiumBorder(), // Bordes redondeados

      child: Container(
        width: width,
        height: height,
        child: Center(
          child: Text(text,
              style: TextStyle(color: Colors.white, fontSize: fontSize)),
        ),
      ),
    );
  }
}

class MainButton extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  final double fontSize;
  final Function() onPressed;

  const MainButton({
    Key? key,
    this.width = double.infinity,
    this.height = 50,
    this.fontSize = 22,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      width: this.width,
      onPressed: this.onPressed,
      text: this.text,
      fontSize: this.fontSize,
      height: this.height,
      color: Helper.primaryColor!,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  final double fontSize;
  final Function() onPressed;

  const SecondaryButton({
    Key? key,
    this.width = double.infinity,
    this.height = 50,
    this.fontSize = 22,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      width: this.width,
      onPressed: this.onPressed,
      text: this.text,
      fontSize: this.fontSize,
      height: this.height,
      color: Helper.secondaryColor!,
    );
  }
}

void openDialogConfirmation(BuildContext context, Function onPressed,
    String mensaje, String routeNueva, Map<String, String> argumentos) {
  if (Platform.isAndroid) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(mensaje),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(onPressed: () {}, child: Text('Confirmar')),
              ],
            ));
  } else {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(mensaje),
        actions: [
          CupertinoDialogAction(
//            isDestructiveAction: true,
            child: Text('Confirmar'),
            onPressed: () {
              Navigator.pop(context);
              onPressed(context);
              Timer(
                  Duration(milliseconds: 1000),
                  () => Navigator.of(context)
                      .popAndPushNamed(routeNueva, arguments: argumentos));
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}

class Item {
  Item(
      {required this.titulo,
      required this.accion,
      this.values = const [],
      this.addButton = true,
      this.isExpanded = false,
      this.route = '',
      this.params = const {'prueba': 1}});

  Function accion;
  bool addButton;
  List<dynamic> values;
  String titulo;
  String route;
  Map<String, dynamic> params;
  bool isExpanded;
}
