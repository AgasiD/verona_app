// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/models/form.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/forms/asignar_pedido.dart';
import 'package:verona_app/pages/forms/obra.dart';
import 'package:verona_app/pages/forms/pedido.dart';
import 'package:verona_app/pages/forms/propietario.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class FormPage extends StatelessWidget {
  static const routeName = 'form';
  late String titulo;
  late Function accion;
  late String formName;
  late String mensajeConfirmacion;
  late String rutaPrevia;
  late Map<String, String> argRuta;
  late FormState? formState;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final formName = arguments['formName'];
    final _service = Provider.of<ObraService>(context, listen: false);
    dynamic formulario;
    switch (formName) {
      case AsignarPedidoForm.routeName:
        formulario = AsignarPedidoForm();
        titulo = AsignarPedidoForm.nameForm;
        accion = AsignarPedidoForm.accion;
        mensajeConfirmacion = AsignarPedidoForm.alertMessage;
        //rutaPrevia = AsignarPedidoForm.rutaPrevia;
        break;
      case PedidoForm.routeName:
        formulario = PedidoForm();
        titulo = PedidoForm.nameForm;
        accion = PedidoForm.accion;
        mensajeConfirmacion = PedidoForm.alertMessage;
        //rutaPrevia = PedidoForm.rutaPrevia;
        break;
      case ObraForm.routeName:
        formulario = ObraForm();
        titulo = ObraForm.nameForm;
        accion = ObraForm.accion;
        mensajeConfirmacion = ObraForm.alertMessage;
        rutaPrevia = ObraForm.routeName;
        argRuta = {"obraId": _service.obra.id};
        break;

      case PropietarioForm.routeName:
        formulario = PropietarioForm();
        titulo = PropietarioForm.nameForm;
        accion = PropietarioForm.accion;
        mensajeConfirmacion = PropietarioForm.alertMessage;
        rutaPrevia = AgregarPropietariosPage.routeName;
        argRuta = {"obraId": _service.obra.id};

        break;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: this.titulo,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * .90,
            child: Column(children: [
              formulario,
              Align(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    MainButton(
                        onPressed: () {
                          openDialogConfirmation(context, accion,
                              mensajeConfirmacion, rutaPrevia, argRuta);
                        },
                        text: 'Aceptar'),
                    SizedBox(
                      height: 10,
                    ),
                    SecondaryButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: 'Cancelar')
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
