import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/tarea.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class SemanarioMessageForm extends StatelessWidget {
  SemanarioMessageForm({Key? key}) : super(key: key);
  static final routeName = 'SemanarioMessageForm';
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    List<Tarea> data = args['data'];
    FocusNode focus = FocusNode();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Helper.brandColors[2],
        appBar: AppBar(
          title: Text('${data.length} tareas seleccionadas'),
          backgroundColor: Helper.brandColors[1],
          
        ),
        body: _Form(data: data),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  _Form({required this.data});

  List<Tarea> data;
  TextEditingController txtCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    txtCtrl.text = generarTexto(data);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 15),
            height: 40,
            // child: Text('Total tareas: ${data.length}', style: TextStyle(color: Helper.brandColors[4], fontSize: 18 )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: CustomInput(
              lines: 20,
              hintText: 'Texto a enviar...',
              icono: null,
              textController: txtCtrl,
              teclado: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CustomNavigatorButton(
                      icono: Icons.copy,
                      accion: () async {
                        try{

                        await Clipboard.setData(
                            ClipboardData(text: txtCtrl.text));

                            Helper.showSnackBar(context, 'Texto copiado', null, Duration(seconds: 2), null);
                        }catch( err ){
                          openAlertDialog(context, 'Error al copiar texto');
                        }
                      },
                      showNotif: false,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 13),
                        child: Text('Copiar',
                            style: TextStyle(
                                fontSize: 17, color: Helper.brandColors[4])))
                  ],
                ),
                Column(
                  children: [
                    CustomNavigatorButton(
                      icono: Icons.send,
                      accion: () async{

                        final result = await openDialogConfirmationReturn(context, 'Confirmar envío de mensaje a grupo con propietarios');
                        if(result)
                          await enviarMensaje(context);
                      },
                      showNotif: false,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 13),
                        child: Text('Enviar a grupo',
                            style: TextStyle(
                                fontSize: 17, color: Helper.brandColors[4])))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  String generarTexto(List<Tarea> data) {
    String text = '¡Hola! Les envío el resumen de lo logrado esta semana \n\n';
    data.forEach((element) {
      text += '- ${element.descripcion} \n\n';
    });

    text += '\n¡Seguimos avanzando con los trabajos!';
    text.replaceAll('"', '');
    return text;
  }
  
  enviarMensaje(context) async{
    try{

    openLoadingDialog(context, mensaje: 'Enviando mensaje...');
    final _chatService = Provider.of<ChatService>(context, listen: false);
    final _obraService = Provider.of<ObraService>(context, listen: false);
    final _pref = new Preferences();
    final response = await _chatService.enviarMensajeChatGroup(_obraService.obra.id, _pref.id, txtCtrl.text);
    closeLoadingDialog(context);
    if( response.fallo )
    {
      openAlertDialog(context, 'Error al enviar mensaje', subMensaje: response.error);
      return;
    }
    openAlertDialog(context, 'Mensaje enviado');
    }catch( err ){
      closeLoadingDialog(context);
      openAlertDialog(context, 'Error al enviar mensaje', subMensaje: err.toString());

    }
    
  }
}
