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
          'transports': ['websocket'],
          'autoConnect': true,
          'forceNew': true,
          'extraHeaders': {'x-token': clientId}
        });
      }

      toConnect(clientId);
      escucharNotificaciones();
      pedirNotificaciones(clientId);
      tieneChatsSinLeer(clientId);
      getUsuariosOnline();
      // Accion al desconectarse del servidor
      toDisconnect();
      obtenerNovedad();

      conectando = false;
    }
  }

  void disconnect() {
    this.socket.disconnect();
  }

  obtenerNovedad() {
    socket.on('novedad', (data) {
      novedades = data ?? [];
      notifyListeners();
    });
  }

  void tieneChatsSinLeer(clientId) {
    socket.on('chatSinLeer', (data) {
      tieneMensaje = data;
      notifyListeners();
    });
  }

  void getUsuariosOnline() {
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
      this._serverStatus = ServerStatus.Online;
      print('----------CONECTADO CON EL SERVIDOR----------');
      obtenerNovedades(clientId);
      conectando = false;
      notifyListeners();
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

  void enviarMensaje(Message mensaje) async {
    this._socket.emit('nuevo-mensaje', mensaje.toMap());
  }

  void pedirNotificaciones(String userId) {
    this._socket.emit('notifications-count', userId);
  }

  void obtenerNovedades(String userId) {
    this._socket.emit('novedades', userId);
  }

  void leerNotificaciones(String userId) {
    this._socket.emit('leerNotificaciones', userId);
  }

  Future agregarUsuario(String obraId, String usuarioId) async {
    this
        ._socket
        .emit('nuevo-usuario', {'obraId': obraId, 'usuarioId': usuarioId});
  }

  Future quitarUsuario(String obraId, String usuarioId) async {
    this
        ._socket
        .emit('quitar-usuario', {'obraId': obraId, 'usuarioId': usuarioId});
  }

  void agregarInactividad(Inactividad inactividad, String obraId) async {
    this._socket.emit('nueva-inactividad', [inactividad.toMap(), obraId]);
  }

  tieneNovedadesNotif() {
    return novedades.where((novedad) => novedad['menu'] < 7).length > 0;
  }

  void escucharNotificaciones() {
    socket.on('notifications-count', (data) {});
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