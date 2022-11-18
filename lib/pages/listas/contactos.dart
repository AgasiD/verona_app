import 'package:animate_do/animate_do.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/pages/chat.dart';
import 'package:verona_app/services/chat_service.dart';
import 'package:verona_app/services/usuario_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class ContactsPage extends StatefulWidget {
  ContactsPage({Key? key}) : super(key: key);
  static const String routeName = 'Contactos';

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final _pref = new Preferences();
  List<dynamic> dataFiltrada = [];
  String txtBuscar = '';

  @override
  Widget build(BuildContext context) {
    final _usuarios = Provider.of<UsuarioService>(context);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Helper.brandColors[1],
        child: SafeArea(
          child: FutureBuilder(
            future: _usuarios.obtenerPersonal(),
            builder: (_, snapshot) {
              if (snapshot.data == null) {
                return Loading(mensaje: 'Cargando contactos');
              } else {
                final contactos = (snapshot.data as List<dynamic>)
                    .where((e) => e.dni != _pref.id)
                    .toList();
                contactos.sort((a, b) {
                  return a.nombre
                      .toLowerCase()
                      .compareTo(b.nombre.toLowerCase());
                });
                if (txtBuscar.length == 0) {
                  dataFiltrada = contactos;
                }

                return _ListViewSearch(data: dataFiltrada);
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _ListViewSearch extends StatefulWidget {
  _ListViewSearch({Key? key, required this.data}) : super(key: key);

  List<dynamic> data;

  @override
  State<_ListViewSearch> createState() => _ListViewSearchState();
}

class _ListViewSearchState extends State<_ListViewSearch> {
  TextEditingController _txtBuscar = TextEditingController();
  List<dynamic> dataFiltrada = [];
  final _pref = new Preferences();

  @override
  void initState() {
    super.initState();
    this.dataFiltrada = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomInput(
            width: MediaQuery.of(context).size.width * .95,
            hintText: 'Nombre del personal',
            icono: Icons.search,
            textInputAction: TextInputAction.search,
            validaError: false,
            iconButton: _txtBuscar.text.length > 0
                ? IconButton(
                    splashColor: null,
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.red.withAlpha(200),
                    ),
                    onPressed: () {
                      _txtBuscar.text = '';
                      dataFiltrada = widget.data;
                      setState(() {});
                    },
                  )
                : IconButton(
                    color: Helper.brandColors[4],
                    icon: _pref.role == 1 ? Icon(Icons.add) : Container(),
                    onPressed: null,
                  ),
            textController: _txtBuscar,
            onChange: (text) {
              dataFiltrada = widget.data
                  .where((dato) => '${dato.nombre} ${dato.apellido}'
                      .toLowerCase()
                      .contains(text.toLowerCase()))
                  .toList();
              setState(() {});
            },
          ),
          _txtBuscar.text.length > 0 && dataFiltrada.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Text(
                      'No se encontraron usuarios',
                      style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                      maxLines: 3,
                    ),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height - 207,
                  child: ListView.builder(
                      itemCount: dataFiltrada.length,
                      itemBuilder: (_, index) {
                        return FadeInRight(
                          delay: Duration(milliseconds: index * 50),
                          child: _ContactTile(
                            personal: dataFiltrada[index],
                            index: index,
                          ),
                        );
                      })),
        ],
      ),
    );
  }
}

class _ContactTile extends StatefulWidget {
  _ContactTile({Key? key, required this.personal, required this.index})
      : super(key: key);
  Miembro personal;
  int index;

  @override
  State<_ContactTile> createState() => __ContactTileState();
}

class __ContactTileState extends State<_ContactTile> {
  final _pref = new Preferences();
  bool esPar = false;

  @override
  void initState() {
    super.initState();
    if (widget.index % 2 == 0) {
      esPar = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _chat = Provider.of<ChatService>(context);
    final _color = esPar ? Helper.brandColors[2] : Helper.brandColors[1];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  child: Text(
                    (widget.personal.nombre[0] ??
                            "" + widget.personal.apellido[0] ??
                            "")
                        .toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Helper.brandColors[5],
                    ),
                  ),
                ),
              ),
              title:
                  Text('${widget.personal.nombre} ${widget.personal.apellido}',
                      style: TextStyle(
                        color: Helper.brandColors[5],
                      )),
              subtitle: Text(
                Helper.getProfesion(widget.personal.role),
                style: TextStyle(color: Helper.brandColors[8].withOpacity(.8)),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Helper.brandColors[3],
              ),
              onTap: () async {
                openLoadingDialog(context, mensaje: 'Creando chat...');
                // Generar Chat
                final response =
                    await _chat.crearChat(_pref.id, widget.personal.id);
                if (response.fallo) {
                  openAlertDialog(context, 'Error al crear el chat',
                      subMensaje: response.error);
                } else {
                  closeLoadingDialog(
                    context,
                  );
                  Navigator.pushNamed(context, ChatPage.routeName, arguments: {
                    'chatId': response.data['chatId'],
                    'chatName': response.data['chatName'],
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
