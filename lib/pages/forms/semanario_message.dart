import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/tarea.dart';
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
          title: Text('Tareas seleccionadas'),
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
            height: 50,
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

    return text;
  }
  
  enviarMensaje(context) async{
    openLoadingDialog(context, mensaje: 'Enviando mensaje...');
                        await Future.delayed(Duration(seconds: 2));
                        closeLoadingDialog(context);
                        openAlertDialog(context, 'El Mensaje NO ha sido enviado');
  }
}
