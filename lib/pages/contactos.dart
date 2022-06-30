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

class ContactsPage extends StatelessWidget {
  ContactsPage({Key? key}) : super(key: key);
  static const String routeName = 'Contactos';
  final _pref = new Preferences();
  @override
  Widget build(BuildContext context) {
    final _usuarios = Provider.of<UsuarioService>(context);
    return Scaffold(
      body: Container(
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

                return ListView.builder(
                    itemCount: contactos.length,
                    itemBuilder: (_, index) {
                      return _ContactTile(
                        personal: contactos[index],
                        index: index,
                      );
                    });
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
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
                    (widget.personal.nombre[0] + widget.personal.apellido[0])
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
                style: TextStyle(color: Helper.brandColors[9].withOpacity(.8)),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Helper.brandColors[3],
              ),
              onTap: () async {
                // Generar Chat
                final response =
                    await _chat.crearChat(_pref.id, widget.personal.id);
                if (response.fallo) {
                  openAlertDialog(context, 'Error al crear el chat',
                      subMensaje: response.error);
                } else {
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
