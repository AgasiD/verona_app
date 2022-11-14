// ignore_for_file: prefer_const_constructors, unnecessary_this, prefer_function_declarations_over_variables

import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/form%20copy.dart';
import 'package:verona_app/models/message.dart';
import 'package:verona_app/pages/chat.dart';

import 'package:verona_app/pages/listas/chats.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/notificaciones.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/notifications_service.dart';
import 'package:verona_app/services/socket_service.dart';
import 'package:verona_app/services/usuario_service.dart';

class CustomPainterAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  bool muestraBackButton;
  CustomPainterAppBar({
    this.title = 'Verona',
    this.muestraBackButton = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        child: CustomPaint(
          painter: _CustomPaintBar(),
        ));
  }

  @override
  Size get preferredSize => new Size.fromHeight(50);
}

class _CustomPaintBar extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) async {
    final paint = Paint();
    paint.color = Colors.black38;
    paint.style = PaintingStyle.stroke; //bordes PaintingStyle.fill; relleno
    paint.strokeWidth = 2;

    final path = new Path();

    ByteData bd = await rootBundle.load("assets/background.jpg");
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

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
      actions: [!hideNotifications ? _NotificationButton() : Container()],
      backgroundColor: Color.fromARGB(132, 252, 252, 252),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(50);
}

class _NotificationButton extends StatefulWidget {
  const _NotificationButton({
    Key? key,
  }) : super(key: key);

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  late SocketService _socketService;
  int cant = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _socketService = Provider.of<SocketService>(context);

    return Padding(
        padding: EdgeInsets.only(right: 15, top: 5),
        child: Badge(
          showBadge: false, // _socketService.unreadNotifications > 0,
          badgeContent: Text(_socketService.unreadNotifications.toString()),
          badgeColor: Colors.red.shade100,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.notifications,
              size: 30,
            ),
            onPressed: () async {
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
  final List<Map<String, dynamic>> menu;

  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketService>(context);
    final _usuarioService = Provider.of<UsuarioService>(context);
    final _pref = new Preferences();

    final menuVista = _pref.role == 1
        ? menu
            .map((e) => TextButton(
                  child: Row(children: [
                    Icon(e['icon'], color: Helper.brandColors[8]),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        '${e["name"]}',
                        style: textStyle,
                      ),
                    ),
                  ]),
                  onPressed: () {
                    Navigator.pushNamed(context, e["route"].toString(),
                        arguments: e['args'] ?? null);
                  },
                ))
            .toList()
        : menu
            .sublist(0, 1)
            .map((e) => TextButton(
                  child: Row(children: [
                    Icon(e['icon'], color: Helper.brandColors[8]),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        '${e["name"]}',
                        style: textStyle,
                      ),
                    ),
                  ]),
                  onPressed: () {
                    Navigator.pushNamed(context, e["route"].toString(),
                        arguments: e['args'] ?? null);
                  },
                ))
            .toList();
    return Drawer(
        child: Container(
      color: Helper.brandColors[2],
      child: SafeArea(
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
                    children: [
                      Text(
                        'Cerrar sesion ',
                        style: TextStyle(color: Helper.brandColors[4]),
                      ),
                      Icon(Icons.logout, color: Helper.brandColors[8])
                    ]),
                onPressed: () async {
                  final response = await _usuarioService.deleteDevice(
                      _pref.id, NotificationService.token!);
                  if (response.fallo) {
                    openAlertDialog(
                        context, 'No se ha desasociado el dispositivo',
                        subMensaje: response.error);
                  }
                  _pref.logged = false;
                  _socketService.disconnect();
                  Navigator.pushReplacementNamed(context, LoginPage.routeName);
                },
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 35),
                child: Column(children: menuVista))
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
  final IconData? icono;
  final bool isPassword;
  final TextInputType teclado;
  final TextEditingController textController;
  final double width;
  IconButton? iconButton;
  final int? lines;
  final bool validaError;
  final bool enable;
  final bool readOnly;
  String? Function(String?) validarInput;
  Function(String) onChange;
  static void _passedOnChange(String? input) {}
  String initialValue = '';
  static String? _passedFunction(String? input) {}
  TextInputAction textInputAction;
  final Color iconColor = Colors.black;
  CustomInput({
    Key? key,
    required this.hintText,
    required this.icono,
    this.isPassword = false,
    this.teclado = TextInputType.text,
    this.width = double.infinity,
    this.lines = null,
    this.validaError = false,
    this.initialValue = '',
    this.textInputAction = TextInputAction.next,
    this.enable = true,
    this.readOnly = false,
    this.iconButton = null,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        hintText: widget.hintText,
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        suffixIcon: widget.iconButton,
        prefixIcon: widget.icono != null
            ? Icon(
                widget.icono,
                color: Helper.brandColors[9].withOpacity(.6),
              )
            : null,
        hintStyle: TextStyle(color: Helper.brandColors[3]),
        errorMaxLines: 1);
    return Column(
      children: [
        Container(
          width: widget.width,
          padding: EdgeInsets.only(right: 15),
          margin: EdgeInsets.only(bottom: 10),
          child: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            enabled: widget.enable,
            readOnly: widget.readOnly,
            controller: widget.textController,
            maxLines: widget.lines ?? 1,
            autocorrect: false,
            keyboardType: widget.teclado,
            keyboardAppearance: Brightness.dark,
            obscureText: widget.isPassword,
            decoration: inputDecoration,
            textInputAction: widget.textInputAction,
            style: TextStyle(color: Helper.brandColors[5]),
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
            border: Border.all(color: Helper.brandColors[9], width: .2),
            borderRadius: BorderRadius.circular(7),
            color: Helper.brandColors[1],
            boxShadow: [
              BoxShadow(
                  color: Helper.brandColors[0],
                  blurRadius: 4,
                  offset: Offset(10, 8))
            ],
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

class CustomAreaInput extends StatefulWidget {
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
  final Color iconColor = Colors.black;

  CustomAreaInput({
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
  State<CustomInput> createState() => _CustomAreaInputState();
}

class _CustomAreaInputState extends State<CustomInput> {
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
          color: Helper.brandColors[9].withOpacity(.6),
        ),
        hintStyle: TextStyle(color: Helper.brandColors[3]),
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
            style: TextStyle(color: Helper.brandColors[5]),
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
            border: Border.all(color: Helper.brandColors[9], width: .2),
            borderRadius: BorderRadius.circular(7),
            color: Helper.brandColors[1],
            boxShadow: [
              BoxShadow(
                  color: Helper.brandColors[0],
                  blurRadius: 4,
                  offset: Offset(10, 8))
            ],
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
    return ElevatedButton(
      onPressed: this.onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        shadowColor: MaterialStateProperty.all(Helper.brandColors[1]),
      ),
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
  final Color color;

  const MainButton({
    Key? key,
    this.width = double.infinity,
    this.height = 50,
    this.fontSize = 22,
    required this.onPressed,
    required this.text,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      width: this.width,
      onPressed: this.onPressed,
      text: this.text,
      fontSize: this.fontSize,
      height: this.height,
      color: this.color,
    );
  }
}

class Logo extends StatelessWidget {
  final bool ring;
  final double size;
  const Logo({
    Key? key,
    this.ring = false,
    this.size = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = ring
        ? BoxDecoration(
            border: Border.all(color: Helper.brandColors[8], width: 3),
            borderRadius: BorderRadius.circular(10000))
        : null;
    return Center(
        child: Container(
      width: size,
      height: size,
      decoration: decoration,
      child: Image(
        image: AssetImage('assets/isotipo2.png'),
      ),
    ));
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  final double fontSize;
  final Function() onPressed;
  final Color color;
  const SecondaryButton({
    Key? key,
    this.width = 70,
    this.height = 50,
    this.fontSize = 18,
    required this.onPressed,
    required this.text,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      width: this.width,
      onPressed: this.onPressed,
      text: this.text,
      fontSize: this.fontSize,
      height: this.height,
      color: this.color,
    );
  }
}

void openBottomSheet(
    BuildContext context, String titulo, String subtitulo, List actions) {
  if (Platform.isIOS) {
    var botones = actions.map((accion) {
      return CupertinoActionSheetAction(
        isDefaultAction: accion['default'],
        onPressed: accion['accion'],
        child: Text(accion['text']),
      );
    }).toList();

    botones.add(CupertinoActionSheetAction(
      isDestructiveAction: true,
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text('Cancelar'),
    ));
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(titulo),
        message: Text(subtitulo),
        actions: botones,
      ),
    );
  } else {
    var botones = actions.map((accion) {
      return SecondaryButton(
        onPressed: accion['accion'],
        text: accion['text'],
        color: Helper.brandColors[2],
        width: MediaQuery.of(context).size.width,
      );
    }).toList();

    botones.add(SecondaryButton(
      onPressed: () => Navigator.pop(context),
      text: 'Cancelar',
      color: Helper.brandColors[1],
      width: MediaQuery.of(context).size.width,
    ));

    showBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Helper.brandColors[2]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: botones,
          ),
        );
      },
    );
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
            onPressed: () async {
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

void openAlertDialog(BuildContext context, String mensaje,
    {String? subMensaje}) {
  if (Platform.isAndroid) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(mensaje),
              content: subMensaje != null && subMensaje != ''
                  ? Text(subMensaje!)
                  : Container(
                      height: 0,
                    ),
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
      color: Helper.brandColors[1],
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SpinKitDualRing(color: Helper.brandColors[8]),
            SizedBox(
              height: 15,
            ),
            mensaje != ''
                ? Text(
                    mensaje,
                    style: TextStyle(
                        color: Helper.brandColors[3],
                        fontSize: 15,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold),
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
      required this.icon,
      this.values = const [],
      this.addButton = true,
      this.isExpanded = false,
      this.route = '',
      this.params = const {'prueba': 1},
      this.list = 1});

  Function() accion;
  bool addButton;
  List<dynamic> values;
  String titulo;
  String route;
  Map<String, dynamic> params;
  bool isExpanded;
  int list;
  IconData icon;
}

class CustomNavigatorFooter extends StatefulWidget {
  CustomNavigatorFooter({Key? key}) : super(key: key);

  @override
  State<CustomNavigatorFooter> createState() => _CustomNavigatorFooterState();
}

class _CustomNavigatorFooterState extends State<CustomNavigatorFooter> {
  @override
  Widget build(BuildContext context) {
    final _chatService = Provider.of<ChatService>(context);
    final _socketService = Provider.of<SocketService>(context);

    return Container(
      decoration: BoxDecoration(color: Helper.brandColors[1]),
      padding: EdgeInsets.only(top: 20),
      alignment: Alignment.topCenter,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomNavigatorButton(
              showNotif: false,
              icono: Icons.arrow_back,
              accion: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              }),
          CustomNavigatorButton(
            showNotif: false,
            icono: Icons.holiday_village_outlined,
            accion: () {
              final name = ModalRoute.of(context)!.settings.name;
              if (name != ObrasPage.routeName) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ObrasPage.routeName,
                    (Route<dynamic> route) => route.isFirst);
                // Navigator.pushNamed(context, ObrasPage.routeName);
              }
            },
          ),
          CustomNavigatorButton(
            showNotif: _socketService.tieneNovedadesNotif(),
            icono: Icons.notifications_none_rounded,
            accion: () {
              final name = ModalRoute.of(context)!.settings.name;
              if (name != NotificacionesPage.routeName) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    NotificacionesPage.routeName,
                    (Route<dynamic> route) => route.isFirst);
                // Navigator.pushNamed(context, NotificacionesPage.routeName);
              }
            },
          ),
          CustomNavigatorButton(
            showNotif: _chatService.tieneMensaje,
            icono: Icons.message_outlined,
            accion: () {
              final name = ModalRoute.of(context)!.settings.name;
              if (name != ChatList.routeName) {
                _chatService.tieneMensaje = false;
                // Navigator.pushNamed(context, ChatList.routeName);
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ChatList.routeName, (Route<dynamic> route) => true);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }
}

class CustomNavigatorButton extends StatelessWidget {
  final IconData icono;
  final bool showNotif;
  final Function() accion;
  const CustomNavigatorButton(
      {Key? key,
      required this.icono,
      required this.accion,
      required this.showNotif})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 45;
    return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
            border: Border.all(color: Helper.brandColors[8], width: .2),
            color: Helper.brandColors[2],
            boxShadow: [
              BoxShadow(
                  color: Colors.black54, blurRadius: 5, offset: Offset(12, 8))
            ],
            borderRadius: BorderRadius.all(Radius.circular(size / 2))),
        child: Badge(
          showBadge: showNotif,
          badgeColor: Helper.brandColors[8],
          child: IconButton(
            onPressed: accion,
            icon: Icon(
              this.icono,
              size: 27,
              color: Helper.brandColors[9].withOpacity(.6),
            ),
          ),
        ));
  }
}

class CustomListView extends StatefulWidget {
  CustomListView(
      {Key? key,
      required this.data,
      required this.padding,
      this.tapeable = false,
      this.actionOnTap = null,
      this.fontSize = 17,
      this.textAvatar = true,
      this.iconAvatar = Icons.abc})
      : super(key: key);
  List<dynamic> data;
  Function()? actionOnTap;
  double padding;
  bool tapeable;
  bool textAvatar;
  double fontSize;
  IconData iconAvatar;
  @override
  State<CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
            itemCount: widget.data.length,
            itemBuilder: (_, index) {
              bool esPar = false;
              if (index % 2 == 0) {
                esPar = true;
              }
              return CustomListTile(
                fontSize: widget.fontSize,
                textAvatar: widget.textAvatar,
                iconAvatar: widget.iconAvatar,
                esPar: esPar,
                title: widget.data[index]['title'],
                subtitle: widget.data[index]['subtitle'],
                avatar: widget.data[index]['avatar'],
                onTap: widget.tapeable,
                actionOnTap: widget.actionOnTap,
                padding: widget.padding,
              );
            }));
  }
}

class CustomSearchListView extends StatefulWidget {
  CustomSearchListView(
      {Key? key, required this.data, required this.txtController})
      : super(key: key);

  List<dynamic> data;
  TextEditingController txtController;

  @override
  State<CustomSearchListView> createState() => _CustomSearchListViewState();
}

class _CustomSearchListViewState extends State<CustomSearchListView> {
  List<dynamic> dataFiltrada = [];
  late SocketService _socketService;
  Preferences _pref = new Preferences();
  String txtBuscar = '';
  @override
  @override
  Widget build(BuildContext context) {
    dataFiltrada = widget.data;

    return SingleChildScrollView(
      child: Column(
        children: [
          CustomInput(
            width: MediaQuery.of(context).size.width * .95,
            hintText: 'Nombre del personal...',
            icono: Icons.search,
            textInputAction: TextInputAction.search,
            validaError: false,
            iconButton: txtBuscar.length > 0
                ? IconButton(
                    splashColor: null,
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.red.withAlpha(200),
                    ),
                    onPressed: () {
                      widget.txtController.text = '';
                      txtBuscar = '';

                      dataFiltrada = widget.data;
                      setState(() {});
                    },
                  )
                : IconButton(
                    color: Helper.brandColors[4],
                    icon: _pref.role == 1 ? Icon(Icons.add) : Container(),
                    onPressed: null,
                  ),
            textController: widget.txtController,
            onChange: (text) {
              txtBuscar = text;
              dataFiltrada = widget.data
                  .where((dato) =>
                      dato["nombre"].toLowerCase().contains(text.toLowerCase()))
                  .toList();
              setState(() {});
            },
          ),
          txtBuscar.length > 0 && dataFiltrada.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height - 20,
                  child: Center(
                    child: Text(
                      'No se encontraron usuarios',
                      style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                      maxLines: 3,
                    ),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height - 205,
                  child: ListView.builder(
                      itemCount: dataFiltrada.length,
                      itemBuilder: ((context, index) {
                        final esPar = index % 2 == 0;
                        final arg = {
                          'chatId': dataFiltrada[index]['id'],
                          'chatName': dataFiltrada[index]['nombre'],
                        };
                        String nombreMensaje = dataFiltrada[index]
                                    ['usuarioUltimoMensaje']['idUsuario'] ==
                                _pref.id
                            ? 'Yo'
                            : dataFiltrada[index]['usuarioUltimoMensaje']
                                ['nombreUsuario'];
                        return CustomListTile(
                          esPar: esPar,
                          title:
                              '${dataFiltrada[index]['nombre'].toString().trim()} ${dataFiltrada[index]['cantMsgSinLeer']}',
                          subtitle: (dataFiltrada[index]['ultimoMensaje'] == ''
                              ? ''
                              : '${Helper.getFechaHoraFromTS(dataFiltrada[index]['tsUltimoMensaje'])} | ${nombreMensaje}: ${dataFiltrada[index]['ultimoMensaje']} '),
                          avatar: (dataFiltrada[index]['nombre'][0] +
                                  dataFiltrada[index]['nombre'][1])
                              .toString()
                              .toUpperCase(),
                          fontSize: 18,
                          onTap: true,
                          bold:
                              (dataFiltrada[index]['cantMsgSinLeer'] as int) > 0
                                  ? true
                                  : false,
                          actionOnTap: () => Navigator.pushNamed(
                              context, ChatPage.routeName,
                              arguments: arg),
                        );
                      })),
                )
        ],
      ),
    );
  }

  setUltimoMensaje(Message msg) {
    final chatIndex = this
        .dataFiltrada
        .indexWhere((element) => element['chatId'] == msg.chatId);
    dataFiltrada[chatIndex]['ultimoMensaje'] = msg.mensaje;
  }
}

class ChatsList extends StatefulWidget {
  ChatsList({Key? key, required this.data, required this.txtController})
      : super(key: key);

  List<dynamic> data;
  TextEditingController txtController;

  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  List<dynamic> dataFiltrada = [];
  late SocketService _socketService;
  Preferences _pref = new Preferences();
  String txtBuscar = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dataFiltrada = widget.data;

    return SingleChildScrollView(
      child: Column(
        children: [
          CustomInput(
            width: MediaQuery.of(context).size.width * .95,
            hintText: 'Nombre del personal...',
            icono: Icons.search,
            textInputAction: TextInputAction.search,
            validaError: false,
            iconButton: txtBuscar.length > 0
                ? IconButton(
                    splashColor: null,
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.red.withAlpha(200),
                    ),
                    onPressed: () {
                      widget.txtController.text = '';
                      txtBuscar = '';

                      dataFiltrada = widget.data;
                      setState(() {});
                    },
                  )
                : IconButton(
                    color: Helper.brandColors[4],
                    icon: _pref.role == 1 ? Icon(Icons.add) : Container(),
                    onPressed: null,
                  ),
            textController: widget.txtController,
            onChange: (text) {
              txtBuscar = text;
              dataFiltrada = widget.data
                  .where((dato) =>
                      dato["nombre"].toLowerCase().contains(text.toLowerCase()))
                  .toList();
              setState(() {});
            },
          ),
          txtBuscar.length > 0 && dataFiltrada.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height - 20,
                  child: Center(
                    child: Text(
                      'No se encontraron usuarios',
                      style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                      maxLines: 3,
                    ),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height - 180,
                  child: ListView.builder(
                      itemCount: dataFiltrada.length,
                      itemBuilder: ((context, index) {
                        final esPar = index % 2 == 0;
                        final arg = {
                          'chatId': dataFiltrada[index]['id'],
                          'chatName': dataFiltrada[index]['nombre'],
                        };
                        String nombreMensaje = dataFiltrada[index]
                                    ['usuarioUltimoMensaje']['idUsuario'] ==
                                _pref.id
                            ? 'Yo'
                            : dataFiltrada[index]['usuarioUltimoMensaje']
                                ['nombreUsuario'];
                        return CustomListTileMessage(
                          badgeData: dataFiltrada[index]['cantMsgSinLeer'],
                          esPar: esPar,
                          title:
                              '${dataFiltrada[index]['nombre'].toString().trim()}',
                          subtitle: (dataFiltrada[index]['ultimoMensaje'] == ''
                              ? ''
                              : '${Helper.getFechaHoraFromTS(dataFiltrada[index]['tsUltimoMensaje'])} | ${nombreMensaje}: ${dataFiltrada[index]['ultimoMensaje']} '),
                          avatar: (dataFiltrada[index]['nombre'][0] +
                                  dataFiltrada[index]['nombre'][1])
                              .toString()
                              .toUpperCase(),
                          fontSize: 18,
                          onTap: true,
                          bold:
                              (dataFiltrada[index]['cantMsgSinLeer'] as int) > 0
                                  ? true
                                  : false,
                          actionOnTap: () => Navigator.pushNamed(
                              context, ChatPage.routeName,
                              arguments: arg),
                        );
                      })),
                )
        ],
      ),
    );
  }

  setUltimoMensaje(Message msg) {
    final chatIndex = this
        .dataFiltrada
        .indexWhere((element) => element['chatId'] == msg.chatId);
    dataFiltrada[chatIndex]['ultimoMensaje'] = msg.mensaje;
  }
}

class CustomListTileMessage extends StatelessWidget {
  int badgeData;
  String title;
  String subtitle;
  String avatar;
  bool esPar;
  bool onTap;
  bool textAvatar;
  bool bold;
  double padding;
  double fontSize;
  IconData iconAvatar;
  Function()? actionOnTap;
  CustomListTileMessage(
      {Key? key,
      required this.esPar,
      required this.title,
      required this.subtitle,
      required this.avatar,
      this.textAvatar = true,
      this.iconAvatar = Icons.abc,
      this.padding = 20,
      this.onTap = false,
      this.fontSize = 10,
      this.bold = false,
      required this.badgeData,
      this.actionOnTap = null})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = esPar ? Helper.brandColors[2] : Helper.brandColors[1];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: this.padding),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: _color, borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                    color:
                        !esPar ? Helper.brandColors[8].withOpacity(.8) : null,
                    borderRadius: BorderRadius.circular(100)),
                child: CircleAvatar(
                  backgroundColor: Helper.brandColors[0],
                  child: textAvatar
                      ? Text(
                          avatar,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Helper.brandColors[5],
                          ),
                        )
                      : Icon(iconAvatar),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Text(title,
                    style: TextStyle(
                        color: Helper.brandColors[5],
                        fontSize: fontSize,
                        fontWeight: bold ? FontWeight.bold : null)),
              ),
              subtitle: this.subtitle != ''
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: Helper.brandColors[8].withOpacity(.8),
                            fontWeight: bold ? FontWeight.bold : null),
                      ),
                    )
                  : null,
              trailing: Container(
                width: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    badgeData > 0
                        ? Badge(
                            badgeColor: Helper.brandColors[8],
                            badgeContent: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(badgeData.toString()),
                            ),
                          )
                        : Container(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Helper.brandColors[3],
                    ),
                  ],
                ),
              ),
              onTap: actionOnTap,
            ),
          ),
        ],
      ),
    );
    ;
  }
}

class CustomListTile extends StatelessWidget {
  bool esPar;
  String title;
  String subtitle;
  String avatar;
  bool onTap;
  bool textAvatar;
  bool bold;
  double padding;
  double fontSize;
  IconData iconAvatar;
  Function()? actionOnTap;
  CustomListTile(
      {Key? key,
      required this.esPar,
      required this.title,
      required this.subtitle,
      required this.avatar,
      this.textAvatar = true,
      this.iconAvatar = Icons.abc,
      this.padding = 20,
      this.onTap = false,
      this.fontSize = 10,
      this.bold = false,
      this.actionOnTap = null})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = esPar ? Helper.brandColors[2] : Helper.brandColors[1];
    final profileImage = (avatar.isEmpty
        ? AssetImage('assets/user.png')
        : NetworkImage(avatar)) as ImageProvider;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: this.padding),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: _color, borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                    color:
                        !esPar ? Helper.brandColors[8].withOpacity(.8) : null,
                    borderRadius: BorderRadius.circular(100)),
                child: CircleAvatar(
                  backgroundColor: Helper.brandColors[0],
                  backgroundImage: profileImage,
                  child: textAvatar
                      ? Container()
                      // Text(
                      //     avatar,
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(
                      //       color: Helper.brandColors[5],
                      //     ),
                      //   )
                      : Icon(iconAvatar),
                ),
              ),
              title: Text(title,
                  style: TextStyle(
                      color: Helper.brandColors[5],
                      fontSize: fontSize,
                      fontWeight: bold ? FontWeight.bold : null)),
              subtitle: this.subtitle != ''
                  ? Text(
                      subtitle,
                      style: TextStyle(
                          color: Helper.brandColors[8].withOpacity(.8),
                          fontWeight: bold ? FontWeight.bold : null),
                    )
                  : null,
              trailing: onTap
                  ? Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Helper.brandColors[3],
                    )
                  : null,
              onTap: actionOnTap,
            ),
          ),
        ],
      ),
    );
    ;
  }
}
