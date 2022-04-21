import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/message.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  // SocketService() {
  //   initConfig();
  // }

  void connect(clientId) {
    this._socket = IO.io('https://veronaserver.herokuapp.com', {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
      'extraHeaders': {'x-token': clientId}
    });

    if (this.socket.disconnected) {
      // Accion al conectarse al servidor
      this._socket.onConnect((_) {
        this._socket.emit('connection', 'App conectada');
        this._serverStatus = ServerStatus.Online;
        print('se ha conectado con el servidor');
      });

      // Accion al desconectarse del servidor
      this._socket.onDisconnect((_) {
        this._serverStatus = ServerStatus.Offline;
        // notifyListeners();
      });
    }
  }

  void disconnect() {
    this.socket.disconnect();
  }

  void enviarMensaje(Message mensaje) {
    this._socket.emit('nuevo-mensaje', mensaje.toMap());
  }
}
