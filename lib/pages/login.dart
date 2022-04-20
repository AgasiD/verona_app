// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class LoginPage extends StatelessWidget {
  static const String routeName = 'login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = double.infinity;
    bool esWeb = false;
    if (MediaQuery.of(context).size.width > 1000) {
      width = 400;
      esWeb = true;
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
          child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          width: width,
          height: MediaQuery.of(context).size.height * .9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Logo(),
              _Form(),
              _Labels(),
              Text('Powered by e-Drex©'),
            ],
          ),
        ),
      )),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      child: Column(
        children: [
          Image(
            image: AssetImage('assets/logo.png'),
            height: 300,
          ),
          // Text(
          //   Helper.nombre,
          //   style: TextStyle(fontSize: 35),
          // )
        ],
      ),
    ));
  }
}

class _Form extends StatefulWidget {
  _Form({Key? key}) : super(key: key);

  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
  late Preferences pref;
  @override
  void initState() {
    super.initState();
    pref = Preferences();
  }

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final _usuario = Provider.of<UsuarioService>(context);
    return Container(
        margin: EdgeInsets.only(top: 40),
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: Column(children: [
          CustomInput(
            hintText: 'Usuario',
            icono: Icons.person_outline,
            textController: emailCtrl,
          ),
          CustomInput(
            hintText: 'Contraseña',
            icono: Icons.password_outlined,
            textController: passCtrl,
            isPassword: true,
          ),
          MainButton(
            text: 'Ingresar',
            onPressed: () async {
              final response =
                  await _usuario.validarUsuario(emailCtrl.text, passCtrl.text);
              print(response);
              if (response.fallo) {
                openAlertDialog(context, response.error);
              } else {
                _usuario.usuario = Miembro.fromJson(response.data);
                guardarUserData(_usuario.usuario);

                print(pref.id);
                Navigator.pushReplacementNamed(context, ObrasPage.routeName);
              }
            },
          )
        ]));
  }

  void guardarUserData(Miembro usuario) {
    pref.id = usuario.id;
    pref.nombre = '${usuario.nombre} ${usuario.apellido}';
  }
}

class _Labels extends StatelessWidget {
  const _Labels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('No tenes clave?',
              style: TextStyle(color: Colors.black45, fontSize: 16)),
          GestureDetector(
            child: Text(
              'Ingresa por primera vez',
              style: TextStyle(color: Colors.blue.shade500, fontSize: 18),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, 'password');
            },
          )
        ],
      ),
    );
  }
}
