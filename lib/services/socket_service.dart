import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:verona_app/helpers/Enviroment.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/message.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Offline;
  late IO.Socket _socket;
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;
  int unreadNotifications = 0;
  bool tieneMensaje = false;
  List<dynamic> usuariosOnline = [];
  List<dynamic> chats = [];

  bool conectando = false;
  List<dynamic> novedades = [];

  void connect(clientId) {
    if (clientId != null && clientId.toString().trim() != '' && !conectando) {
      conectando = true;
      final url = Environment.isProduction
          ? 'https://${Environment.API_URL}'
          : 'http://${Environment.API_URL}';
      if (this._serverStatus == ServerStatus.Offline) {
        this._serverStatus = ServerStatus.Connecting;
        this._socket = IO.io(url, {
          "transports": ['websocket'],
          "autoConnect": true,
          "forceNew": true,
          "auth": {"usuarioId": clientId}
        });
      }

      escucharNovedad();
      escucharUsuariosOnline();
      toConnect(clientId);
      // pedirNotificaciones(clientId);
      // Accion al desconectarse del servidor
      toDisconnect();
      conectando = false;
    }
  }

  void disconnect() {
    this.socket.disconnect();
  }

  escucharNovedad() {
    socket.on('novedad', (data) {
      novedades = data ?? [];
      notifyListeners();
    });
  }

  escucharChats() {
    socket.on('chats', (data) {
      chats = data;
      notifyListeners();
    });
  }

  // pedirChats(String clientID) {
  //   socket.emit('chats', clientID);
  // }

  void tieneChatsSinLeer() {
    socket.on('chatSinLeer', (data) {
      tieneMensaje = data;
      notifyListeners();
    });
  }

  void escucharUsuariosOnline() {
    socket.on('usuarion-online', (data) {
      usuariosOnline = data;
      notifyListeners();
    });
  }

  void quitarNovedad(usuarioId, novedadesId) {
    this._socket.emit('quitar-novedad', {usuarioId, novedadesId});
  }

  toConnect(clientId) {
    // Accion al conectarse al servidor

    this._socket.onConnect((_) {
      print('----------CONECTADO CON EL SERVIDOR----------');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
      conectando = false;
    });
  }

  toDisconnect() {
    this._socket.onDisconnect((_) {
      print('usuario desconectado');
      this._serverStatus = ServerStatus.Offline;
      this.socket.disconnect();
      notifyListeners();
    });
  }

/* socket.on('notifications-count', (data) {
        final notif = data as List<dynamic>;
        unreadNotifications =
            notif.where((element) => !element['leido']).length;
        notifyListeners();
      }); */

  // void enviarMensaje(Message mensaje) async {
  //   this._socket.emit('nuevo-mensaje', mensaje.toMap());
  // }


  tieneNovedadesNotif() {
    // this._socket.emit('unread-notif', userId);

    return novedades
            .where((novedad) => novedad['menu'] < 7 && novedad['leido'] != null
                ? !novedad['leido']
                : false)
            .length >
        0;
    // return false;
  }

}






/*

Obra -> Documentos
Obra -> Galeria de imagenes
Obra -> Etapas
Obra -> Pedidos -> id pedido
Obra -> Chat Grupal
Obra -> Chat Grupal externo

*/