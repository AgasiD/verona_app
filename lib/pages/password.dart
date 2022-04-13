// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/obras.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';
import 'package:win32/win32.dart';

class PasswordPage extends StatelessWidget {
  static const String routeName = 'password';

  const PasswordPage({Key? key}) : super(key: key);

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
            height: 290,
          ),
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
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final reNewPassCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context);

    return Container(
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
          CustomInput(
            hintText: 'Nueva contraseña',
            icono: Icons.password_outlined,
            textController: newPassCtrl,
            isPassword: true,
          ),
          CustomInput(
            hintText: 'Confirmar contraseña',
            icono: Icons.password_outlined,
            textController: reNewPassCtrl,
            isPassword: true,
          ),
          SizedBox(
            height: 15,
          ),
          MainButton(
            text: 'Cambiar contraseña',
            onPressed: () async {
              try {
                final formValid = validarFormulario();
                print(formValid);
                if (formValid) {
                  final body = {
                    "username": emailCtrl.text,
                    "password": passCtrl.text,
                    "newpass": newPassCtrl.text
                  };
                  final data = await _usuarioService.changePassword(body);
                  final datos = data["data"];
                  print(data["data"]);
                  if (datos["fallo"]) {
                    openAlertDialog(context, datos["error"]);
                  } else {
                    resetForm();
                    openAlertDialog(
                        context, 'La contraseña se cambió correctamente');
                  }
                }
              } catch (err) {
                openAlertDialog(context, err.toString());
              }
            },
          )
        ]));
  }

  validarFormulario() {
    bool valid = true;
    if ((newPassCtrl.text.length == 0)) {
      valid = false;
      throw ErrorDescription('No se ingresó contraseña');
    }
    if ((newPassCtrl.text != reNewPassCtrl.text)) {
      valid = false;
      throw ErrorDescription('Las contraseñas no coinciden');
    }

    return valid;
  }

  resetForm() {
    emailCtrl.text = '';
    passCtrl.text = '';
    newPassCtrl.text = '';
    reNewPassCtrl.text = '';
  }
}

class _Labels extends StatelessWidget {
  const _Labels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Text('Ya tenes clave?',
              style: TextStyle(color: Colors.black45, fontSize: 16)),
          GestureDetector(
            child: Text(
              'Volvé al log in',
              style: TextStyle(color: Colors.blue.shade500, fontSize: 18),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, LoginPage.routeName);
            },
          )
        ],
      ),
    );
  }
}
