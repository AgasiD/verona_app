import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:verona_app/helpers/Preferences.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/inactividad.dart';
import 'package:verona_app/models/message.dart';
import 'package:verona_app/models/miembro.dart';
import 'package:verona_app/services/usuario_service.dart';

import 'obra_service.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Offline;
  late IO.Socket _socket;
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;
  int unreadNotifications = 0;
  void connect(clientId) {
    print('Estado del servicio ' + this._serverStatus.toString());
    if (this._serverStatus != ServerStatus.Online) {
      final url =
          'http://192.168.0.155:8008'; //'https://veronaserver.herokuapp.com'; //
      this._socket = IO.io(url, {
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true,
        'extraHeaders': {'x-token': clientId}
      });
      if (this.serverStatus == ServerStatus.Offline) {
        this._serverStatus = ServerStatus.Connecting;
        this._socket.connect();
      }
      // Accion al conectarse al servidor
      if (this._serverStatus != ServerStatus.Online &&
          this.serverStatus != ServerStatus.Connecting) {
        this._socket.onConnect((_) {
          this._serverStatus = ServerStatus.Online;
          print('----------CONECTADO CON EL SERVIDOR----------');
          notifyListeners();
        });
      }
      obtenerNotificaciones(clientId);
      // Accion al desconectarse del servidor
      this._socket.onDisconnect((_) {
        print('usuario desconectado');
        this._serverStatus = ServerStatus.Offline;
        this.socket.disconnect();
        notifyListeners();
      });

      socket.on('notifications-count', (data) {
        print('OBTENIENDO NOTIIFICACIONES');
        final notif = data as List<dynamic>;

        //final notificaciones = data
        unreadNotifications =
            notif.where((element) => !element['leido']).length;
        print('notificaciones sin leer ' + unreadNotifications.toString());
        notifyListeners();
      });
    }
  }

  void disconnect() {
    this.socket.disconnect();
  }

  void enviarMensaje(Message mensaje) {
    this._socket.emit('nuevo-mensaje', mensaje.toMap());
  }

  void obtenerNotificaciones(String userId) {
    this._socket.emit('notifications-count', userId);
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
}
