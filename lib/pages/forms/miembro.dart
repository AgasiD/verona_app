// ignore_for_file: prefer_function_declarations_over_variables, prefer_const_literals_to_create_immutables
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/error.dart';
import 'package:verona_app/pages/perfil.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class MiembroForm extends StatefulWidget {
  static const String routeName = 'miembro';
  static String nameForm = 'Nuevo miembro';
  static String alertMessage = 'Confirmar nuevo miembro';
  late String? usuarioId;
  MiembroForm({Key? key, required this.usuarioId}) : super(key: key);
  @override
  State<MiembroForm> createState() => _MiembroFormState();
}

final TextEditingController _txtNombreCtrl = TextEditingController();
final TextEditingController _txtApellidoCtrl = TextEditingController();
final TextEditingController _txtDNICtrl = TextEditingController();
final TextEditingController _txtTelefonoCtrl = TextEditingController();
final TextEditingController _txtMailCtrl = TextEditingController();
String personalSelected = '2';
late GlobalKey<ScaffoldState> _scaffoldKey;

class _MiembroFormState extends State<MiembroForm> {
  @override
  Widget build(BuildContext context) {
    final _usuarioService = Provider.of<UsuarioService>(context);
    _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: widget.usuarioId == null
              ? _Form(
                scaffoldKey: _scaffoldKey,
                  txtNombreCtrl: _txtNombreCtrl,
                  txtApellidoCtrl: _txtApellidoCtrl,
                  txtDNICtrl: _txtDNICtrl,
                  txtTelefonoCtrl: _txtTelefonoCtrl,
                  usuarioId: widget.usuarioId,
                  txtMailCtrl: _txtMailCtrl)
              : FutureBuilder(
                  future: _usuarioService.obtenerUsuario(widget.usuarioId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Loading(
                        mensaje: 'Recuperando pedidos...',
                      );
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.hasError) {
                      return ErrorPage(
                        errorMsg: snapshot.error.toString(),
                      );
                    }

                    final usuario =
                        Miembro.fromJson(snapshot.data as Map<String, dynamic>);
                    setForm(usuario);
                    return _Form(
                      scaffoldKey: _scaffoldKey,
                      txtNombreCtrl: _txtNombreCtrl,
                      txtApellidoCtrl: _txtApellidoCtrl,
                      txtDNICtrl: _txtDNICtrl,
                      txtTelefonoCtrl: _txtTelefonoCtrl,
                      txtMailCtrl: _txtMailCtrl,
                      usuarioId: widget.usuarioId,
                      edit: true,
                    );
                  })),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }

  void setForm(Miembro usuario) {
    _txtNombreCtrl.text = usuario.nombre;
    _txtApellidoCtrl.text = usuario.apellido;
    _txtDNICtrl.text = usuario.dni;
    _txtTelefonoCtrl.text = usuario.telefono;
    _txtMailCtrl.text = usuario.email;
    personalSelected = usuario.role.toString();
  }
}

class _Form extends StatelessWidget {
  _Form(
      {required this.txtNombreCtrl,
      required this.txtApellidoCtrl,
      required this.txtDNICtrl,
      required this.txtTelefonoCtrl,
      required this.txtMailCtrl,
      required this.usuarioId,
      this.edit = false,
      Key? key, required GlobalKey<ScaffoldState> scaffoldKey})
      : super(key: key);

  String? usuarioId;
  TextEditingController txtNombreCtrl;
  TextEditingController txtApellidoCtrl;
  TextEditingController txtDNICtrl;
  TextEditingController txtTelefonoCtrl;
  TextEditingController txtMailCtrl;
  bool edit;
  final miembros = [
    DropdownMenuItem<String>(
      value: '7',
      child: Text('PM'),
    ),
    DropdownMenuItem<String>(
      value: '2',
      child: Text('Arquitecto'),
    ),
    DropdownMenuItem<String>(
      value: '4',
      child: Text('Contratista'),
    ),
    DropdownMenuItem<String>(
      value: '5',
      child: Text('Encargado de compras'),
    ),
    DropdownMenuItem<String>(
      value: '6',
      child: Text('Repartidor'),
    ),
    DropdownMenuItem<String>(
      value: '1',
      child: Text('Admin'),
    ),
  ];
  final profileURL = '';

  @override
  Widget build(BuildContext context) {
    final colorHint = Helper.brandColors[3];

    return Container(
      color: Helper.brandColors[1],
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      width: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Logo(
                      size: 70,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      edit
                          ? 'Actualizar personal'.toUpperCase()
                          : 'NUEVO MIEMBRO',
                      style:
                          TextStyle(color: Helper.brandColors[8], fontSize: 23),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          CustomInput(
                            hintText: 'Nombre',
                            icono: Icons.person,
                            textController: txtNombreCtrl,
                            teclado: TextInputType.text,
                            validaError: true,
                            validarInput: (value) =>
                                Helper.campoObligatorio(value),
                          ),
                          CustomInput(
                              hintText: 'Apellido ',
                              icono: Icons.person,
                              textController: txtApellidoCtrl,
                              validaError: true,
                              validarInput: (value) =>
                                  Helper.campoObligatorio(value),
                              teclado: TextInputType.text),
                          CustomInput(
                            hintText: 'DNI',
                            icono: Icons.assignment_ind_outlined,
                            textController: txtDNICtrl,
                            teclado: TextInputType.number,
                            validaError: true,
                            // enable: !edit,
                            validarInput: (value) => Helper.validNumeros(value),
                          ),
                          CustomInput(
                            hintText: 'Numero de telefono',
                            icono: Icons.phone_android,
                            textController: txtTelefonoCtrl,
                            teclado: TextInputType.phone,
                            validaError: true,
                            validarInput: (value) => Helper.validNumeros(value),
                          ),
                          CustomInput(
                            hintText: 'Correo electronico',
                            icono: Icons.alternate_email,
                            textController: txtMailCtrl,
                            teclado: TextInputType.emailAddress,
                            validaError: true,
                            validarInput: (value) => Helper.validEmail(value),
                            textInputAction: TextInputAction.done,
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 25),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Helper.brandColors[0],
                                    blurRadius: 4,
                                    offset: Offset(10, 8))
                              ],
                            ),
                            child: DropdownButtonFormField2(
                              items: miembros,
                              value: personalSelected,
                              style: TextStyle(
                                  color: Helper.brandColors[5], fontSize: 16),
                              decoration: InputDecoration(
                                  focusColor: Helper.brandColors[9],
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: Helper.brandColors[9],
                                        width: .2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: Helper.brandColors[9],
                                        width: .5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: Helper.brandColors[9],
                                        width: 2.0),
                                  ),
                                  fillColor: Helper.brandColors[1],
                                  filled: true),
                              hint: Text(
                                'Seleccione puesto',
                                style:
                                    TextStyle(fontSize: 16, color: colorHint),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                  decoration: getDropdownDecoration()),
                              onChanged: (value) {
                                personalSelected = value.toString();
                                //Do something when changing the item if you want.
                              },
                              onSaved: (value) {},
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              MainButton(
                                width: 95,
                                fontSize: 18,
                                color: Helper.brandColors[8]
                                    .withOpacity(.5)
                                    .withAlpha(150),
                                text: 'Grabar',
                                onPressed: () async {
                                  await _grabarMiembro(context);
                                },
                              ),
                              SecondaryButton(
                                  width: 95,
                                  fontSize: 18,
                                  color: Helper.brandColors[2],
                                  text: 'Cancelar',
                                  onPressed: () {
                                    resetForm();

                                    Navigator.pop(context);
                                  }),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _grabarMiembro(BuildContext context) async {
    bool isValid = true;
    final _service = Provider.of<UsuarioService>(context, listen: false);
    final actionText =
        edit ? 'Actualizando... esto puede demorar' : 'Guardando datos...';
    openLoadingDialog(mensaje: actionText);
    bool loading = true;
    txtNombreCtrl.text.trim() == '' ? isValid = false : true;
    txtApellidoCtrl.text.trim() == '' ? isValid = false : true;
    txtDNICtrl.text == '' ? isValid = false : true;
    txtTelefonoCtrl.text == '' ? isValid = false : true;
    txtMailCtrl.text == '' ? isValid = false : true;

    if (!isValid) {
      closeLoadingDialog();
      openAlertDialog('Formulario invalido');
      return;
    }

    final miembro = Miembro(
        id: edit ? usuarioId! : '',
        nombre: txtNombreCtrl.text,
        apellido: txtApellidoCtrl.text,
        dni: txtDNICtrl.text,
        telefono: txtTelefonoCtrl.text,
        email: txtMailCtrl.text,
        role: int.parse(personalSelected));

    dynamic response;
    try {
      edit
          ? response = await _service.modificarUsuario(miembro)
          : response = await _service.grabarUsuario(miembro);

      closeLoadingDialog();
      loading = false;

      final _obraService = Provider.of<ObraService>(context, listen: false);
      _obraService.notifyListeners();

      resetForm();
      if (edit) {
        await openAlertDialogReturn('Personal actualizado');
        Navigator.pop(_scaffoldKey.currentContext!);
      } else {
        await openAlertDialogReturn('Personal creado');
        Navigator.push(
            _scaffoldKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => PerfilPage(usuarioId: response.data['id']),
            ));
      }
    } catch (err) {
      closeLoadingDialog();
      edit
          ? openAlertDialog('No se pudo actualizar el personal',
              subMensaje: err.toString())
          : openAlertDialog('No se pudo crear el personal',
              subMensaje: err.toString());
    }
  }

  void resetForm() {
    txtNombreCtrl.text = '';
    txtApellidoCtrl.text = '';
    txtDNICtrl.text = '';
    txtTelefonoCtrl.text = '';
    txtMailCtrl.text = '';
  }
}

getDecoration() {
  return InputDecoration(
      focusColor: Helper.brandColors[9],
      contentPadding: EdgeInsets.zero,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Helper.brandColors[9], width: .2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Helper.brandColors[9], width: .5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Helper.brandColors[9], width: 2.0),
      ),
      fillColor: Helper.brandColors[1],
      filled: true);
}

getDropdownDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: Helper.brandColors[2],
  );
}
