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
  const ContactsPage({Key? key}) : super(key: key);
  static const String routeName = 'Contactos';
  @override
  Widget build(BuildContext context) {
    final _usuarios = Provider.of<UsuarioService>(context);
    return Scaffold(
        appBar: CustomAppBar(
          muestraBackButton: true,
          title: 'Contactos',
        ),
        body: SingleChildScrollView(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: 1000,
              child: FutureBuilder(
                future: _usuarios.obtenerPersonal(),
                builder: (_, snapshot) {
                  if (snapshot.data == null) {
                    return Loading(mensaje: 'Cargando contactos');
                  } else {
                    final contactos = snapshot.data as List<dynamic>;
                    return ListView.builder(
                        itemCount: contactos.length,
                        itemBuilder: (_, index) {
                          return _ContactTile(personal: contactos[index]);
                        });
                  }
                },
              )),
        ));
  }
}

class _ContactTile extends StatefulWidget {
  _ContactTile({Key? key, required this.personal}) : super(key: key);
  Miembro personal;

  @override
  State<_ContactTile> createState() => __ContactTileState();
}

class __ContactTileState extends State<_ContactTile> {
  final _pref = new Preferences();
  @override
  Widget build(BuildContext context) {
    final _chat = Provider.of<ChatService>(context);

    return Column(
      children: [
        ListTile(
          subtitle: Text(Helper.getProfesion(widget.personal.role)),
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Text(
              '${widget.personal.nombre[0]}${widget.personal.apellido[0]} ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Helper.primaryColor,
              ),
            ),
          ),
          title: Text('${widget.personal.nombre} ${widget.personal.apellido}'),
          trailing: Icon(Icons.arrow_forward_ios_rounded),
          onTap: () async {
            // Generar Chat
            final chatId = _chat.crearChat(_pref.id, widget.personal.id);
            // Navigator.pushNamed(context, ChatPage.routeName,
            //     arguments: {'chatId': widget.chat["id"]});
          },
        ),
        Divider()
      ],
    );
  }
}
