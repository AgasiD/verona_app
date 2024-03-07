import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/services/socket_service.dart';

import 'package:verona_app/widgets/custom_widgets.dart';

import '../services/whatsapp_service.dart';

class MensajeForm extends StatelessWidget {
  const MensajeForm({Key? key}) : super(key: key);
  static const String routeName = 'mensajesForm';

  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketService>(context);
    final _pref = new Preferences();
    _socketService.connect(_pref.id);
    return Scaffold(
      body: Container(
          color: Helper.brandColors[1], child: SafeArea(child: _Form())),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _Form extends StatelessWidget {
  _Form({Key? key}) : super(key: key);
  TextEditingController txtPhone =
      new TextEditingController(text: 'Mandos Medios');
  TextEditingController txtMessage = new TextEditingController(text: '');
  String selectedGroup = '120363197901233524';

  @override
  Widget build(BuildContext context) {
    final wsService = Provider.of<WSService>(context, listen: false);
    List<DropdownMenuItem<String>> grupos =[];
    return FutureBuilder(
        future: wsService.obtenerGrupos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Loading(
              mensaje: 'Recuperando grupos...',
            );
          }
          final response = snapshot.data! as MyResponse;
          (response.data as List).sort((a, b) => a['name'].toString().compareTo(b['name'].toString())) ;
          grupos = (response.data as List).map((e) => DropdownMenuItem<String>(
          child: Text(e['name'] ?? ' Sin nombre'), value: e['id'])).toList();
          return Form(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                SizedBox(
                    height: 80,
                    child: DropdownButtonFormField2(
                        value: selectedGroup,
                        items: grupos,
                        style: TextStyle(
                            color: Helper.brandColors[5], fontSize: 16),
                        iconSize: 30,
                        buttonHeight: 60,
                        buttonPadding: EdgeInsets.only(left: 20, right: 10),
                        decoration: Helper.getDecoration(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Helper.brandColors[3],
                        ),
                        dropdownMaxHeight:
                            MediaQuery.of(context).size.height * .4,
                        dropdownWidth: 250,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Helper.brandColors[2],
                        ),
                        onChanged: (value) {
                          selectedGroup = value as String;
                        })),
               
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomInput(
                    hintText: 'Escriba un mensaje',
                    icono: Icons.message_sharp,
                    textController: txtMessage,
                    lines: 10,
                  ),
                ),
                Expanded(child: Container()),
                MainButton(
                  onPressed: () async => await sendMessage(context),
                  text: 'Enviar mensaje',
                  color: Helper.brandColors[8],
                )
              ]));
        });
  }

  sendMessage(context) async {
    final wsService = Provider.of<WSService>(context, listen: false);
    try {
      openLoadingDialog(context, mensaje: 'Enviando mensaje...');
      final text = txtMessage.text;
      final phone = txtPhone.text;
      if(text.trim().isEmpty){
        throw new Exception(['No se ingresó mensaje']);
      }
      await wsService.enviarMensajeGrupo(selectedGroup, text);
      closeLoadingDialog(context);
      openAlertDialog(context, 'Mensaje enviado con éxito');
    } catch (err) {
      closeLoadingDialog(context);
      openAlertDialog(context, err.toString());
    }
  }
}
