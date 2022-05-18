// ignore_for_file: prefer_const_constructors, unnecessary_this, prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/form%20copy.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/notificaciones.dart';
import 'package:verona_app/services/notifications_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/services/usuario_service.dart';

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
    final _usuarioService = Provider.of<UsuarioService>(context);
    final _pref = new Preferences();
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
            ? FutureBuilder(
                future: _usuarioService.obtenerNotificaciones(_pref.id),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    int cant = 0;
                    return _NotificationButton(
                      cant: cant,
                    );
                  } else {
                    final response = snapshot.data as MyResponse;
                    int cant = (response.data as List<dynamic>)
                        .where((e) => !e['leido'])
                        .length;
                    return _NotificationButton(cant: cant);
                  }
                })
            : Container()
      ],
      backgroundColor: Color.fromARGB(132, 252, 252, 252),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(50);
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    Key? key,
    required this.cant,
  }) : super(key: key);

  final int cant;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 15, top: 5),
        child: Badge(
          showBadge: cant > 0,
          badgeContent: Text(cant.toString()),
          badgeColor: Colors.red.shade100,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.notifications,
              size: 30,
            ),
            onPressed: () {
              Navigator.pushNamed(context, NotificacionesPage.routeName);
            },
          ),
        ));
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
    required this.textStyle,
    required this.menu,
  }) : super(key: key);

  final TextStyle textStyle;
  final List<Map<String, String>> menu;

  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketService>(context);
    final _usuarioService = Provider.of<UsuarioService>(context);
    final _pref = new Preferences();
    final tokenDevice = NotificationService.token;
    return Drawer(
        child: SafeArea(
      child: Container(
        child: Stack(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                'Estado del servidor',
                style: textStyle,
              ),
              _socketService.socket.connected
                  ? Icon(
                      Icons.signal_cellular_alt,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.signal_cellular_connected_no_internet_4_bar,
                      color: Colors.red,
                    )
            ]),
            Positioned(
              bottom: 20,
              left: 85,
              child: TextButton(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [Text('Cerrar sesion   '), Icon(Icons.logout)]),
                onPressed: () async {
                  final response = await _usuarioService.deleteDevice(
                      _pref.id, tokenDevice!);
                  if (response.fallo) {
                    openAlertDialog(
                        context, 'No se ha desasociado el dispositivo',
                        subMensaje: response.error);
                  }
                  _pref.logged = false;
                  Navigator.pushReplacementNamed(context, LoginPage.routeName);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 35),
              child: Column(
                  children: menu
                      .map((e) => TextButton(
                            child: Row(children: [
                              Icon(Icons.person_add_alt_sharp),
                              Text(
                                '${e["name"]}',
                                style: textStyle,
                              ),
                            ]),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, e["route"].toString());
                            },
                          ))
                      .toList()),
            )
          ],
        ),
      ),
    ));
  }
}

class CustomFormInput extends StatefulWidget {
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
  String initialValue;
  bool enable;
  static String? _passedFunction(String? input) {}
  TextInputAction textInputAction;
  CustomFormInput({
    Key? key,
    required this.hintText,
    required this.icono,
    this.isPassword = false,
    this.teclado = TextInputType.text,
    this.width = double.infinity,
    this.lines = 1,
    this.validaError = false,
    this.initialValue = '',
    this.enable = true,
    this.textInputAction = TextInputAction.next,
    this.iconButton = const IconButton(
      onPressed: null,
      icon: Icon(null),
    ),
    required this.textController,
    this.validarInput = _passedFunction,
    this.onChange = _passedOnChange,
  }) : super(key: key);

  @override
  State<CustomFormInput> createState() => _CustomFormInputState();
}

class _CustomFormInputState extends State<CustomFormInput> {
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
        hintStyle: TextStyle(color: Color.fromARGB(255, 185, 185, 185)),
        suffixIcon: widget.iconButton,
        // prefixIcon: Icon(
        //   widget.icono,
        //   color: Helper.primaryColor,
        // ),
        errorMaxLines: 1);
    return Column(
      children: [
        Container(
          width: widget.width,
          padding: EdgeInsets.symmetric(horizontal: 15),
          margin: EdgeInsets.only(bottom: 10),

          child: TextFormField(
            enabled: widget.enable,
            controller: widget.textController,
            maxLines: widget.lines,
            autocorrect: false,
            keyboardType: widget.teclado,
            obscureText: widget.isPassword,
            decoration: inputDecoration,
            textInputAction: widget.textInputAction,
            onChanged: (text) {
              inputValid = widget.validarInput(text) == null
                  ? ValidInput()
                  : ValidInput(error: widget.validarInput(text)!, value: false);
              widget.onChange(text);
              setState(() {});
            },
          ),
          // ignore: prefer_const_literals_to_create_immutables
          decoration: BoxDecoration(
            color: Color.fromARGB(171, 250, 250, 250),
            border: Border.all(color: Helper.primaryColor!, width: 1),
          ),
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
  TextInputAction textInputAction;
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
    this.textInputAction = TextInputAction.next,
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
            textInputAction: widget.textInputAction,
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
          // setState(() {});
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
      color: this.color.withOpacity(.7),
      elevation: 2,
      highlightElevation: 5,
      //shape: StadiumBorder(), // Bordes redondeados

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

void openDialogConfirmation(
    BuildContext context, Function onPressed, String mensaje) {
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

void openAlertDialog(BuildContext context, String mensaje,
    {String? subMensaje}) {
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
        content: subMensaje != null && subMensaje != ''
            ? Text(subMensaje!)
            : Container(),
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
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Center(
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
                        color: Helper.primaryColor,
                        fontSize: 15,
                        decoration: TextDecoration.none),
                  )
                : Container()
          ],
        ),
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
