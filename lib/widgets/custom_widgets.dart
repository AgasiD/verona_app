// ignore_for_file: prefer_const_constructors, unnecessary_this, prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/form%20copy.dart';
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
      title: Image(
        image: AssetImage('assets/logo.png'),
        height: 170,
      ),
      automaticallyImplyLeading: muestraBackButton,
      primary: true,
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
  IconButton iconButton;
  final int lines;
  final bool validaError;
  String? Function(String?) validarInput;
  Function(String) onChange;
  static void _passedOnChange(String? input) {}
  String initialValue = '';
  static String? _passedFunction(String? input) {}
  CustomInput({
    Key? key,
    required this.hintText,
    required this.icono,
    this.isPassword = false,
    this.teclado = TextInputType.text,
    this.width = double.infinity,
    this.lines = 1,
    this.validaError = false,
    this.initialValue = '',
    this.iconButton = const IconButton(
      onPressed: null,
      icon: Icon(null),
    ),
    required this.textController,
    this.validarInput = _passedFunction,
    this.onChange = _passedOnChange,
  }) : super(key: key);

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  ValidInput inputValid = ValidInput();
  @override
  Widget build(BuildContext context) {
    final icon = inputValid.value ? Icons.verified : Icons.cancel;
    var inputDecoration = InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 13),
        hintText: widget.hintText,
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        suffixIcon: widget.iconButton,
        prefixIcon: Icon(
          widget.icono,
          color: Helper.primaryColor,
        ),
        errorMaxLines: 1);
    return Column(
      children: [
        Container(
          width: widget.width,
          padding: EdgeInsets.only(right: 15),
          margin: EdgeInsets.only(bottom: 10),
          child: TextFormField(
            controller: widget.textController,
            maxLines: widget.lines,
            autocorrect: false,
            keyboardType: widget.teclado,
            obscureText: widget.isPassword,
            decoration: inputDecoration,
            onChanged: (text) {
              inputValid = widget.validarInput(text) == null
                  ? ValidInput()
                  : ValidInput(error: widget.validarInput(text)!, value: false);
              widget.onChange(text);
              setState(() {});
            },
          ),
          // ignore: prefer_const_literals_to_create_immutables
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.black45, blurRadius: 5, offset: Offset(0, 3))
          ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
        ),
        widget.validaError
            ? inputValid.value
                ? Container(
                    height: 22,
                  )
                : Container(
                    padding: EdgeInsets.only(bottom: 5, left: 25),
                    alignment: Alignment.topLeft,
                    child: Text(
                      inputValid.error,
                      style: TextStyle(color: Colors.red),
                    ))
            : Container()
      ],
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

openLoadingDialog(BuildContext context, {String mensaje = ''}) {
  if (Platform.isAndroid) {
    showDialog(
        context: context, builder: (context) => Loading(mensaje: mensaje));
  } else {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(title: Text(mensaje)),
    );
  }
  return context;
}

void closeLoadingDialog(BuildContext context) {
  if (Platform.isAndroid) {
    Navigator.of(context, rootNavigator: true).pop();
  } else {
    Navigator.of(context, rootNavigator: true).pop();
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
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPressed(context);
                    },
                    child: Text('Confirmar')),
              ],
            ));
  } else {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            child: Text('Confirmar'),
            onPressed: () {
              Navigator.pop(context);
              onPressed(context);
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

void openAlertDialog(BuildContext context, String mensaje) {
  if (Platform.isAndroid) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(mensaje),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cerrar'),
                ),
              ],
            ));
  } else {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            child: Text('Cerrar'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  Loading({Key? key, this.mensaje = ''}) : super(key: key);
  String mensaje;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SpinKitDualRing(color: Helper.primaryColor!),
          SizedBox(
            height: 15,
          ),
          mensaje != ''
              ? Text(
                  mensaje,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      decoration: TextDecoration.none),
                )
              : Container()
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
      this.params = const {'prueba': 1},
      this.list = 1});

  Function accion;
  bool addButton;
  List<dynamic> values;
  String titulo;
  String route;
  Map<String, dynamic> params;
  bool isExpanded;
  int list;
}
