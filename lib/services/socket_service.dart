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
    print('Estado del servicio ' + this._serverStatus.toString());
    if (this._serverStatus != ServerStatus.Online) {
      final url =
          'http://192.168.0.155:8008'; // 'https://veronaserver.herokuapp.com'; //
      this._socket = IO.io(url, {
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true,
        'extraHeaders': {'x-token': clientId}
      });
      // Accion al conectarse al servidor
      this._socket.onConnect((_) {
        this._socket.emit('connection', 'App conectada');
        this._serverStatus = ServerStatus.Online;
        print('se ha conectado con el servidor');
        notifyListeners();
      });

      // Accion al desconectarse del servidor
      this._socket.onDisconnect((_) {
        print('usuario desconectado');
        this._serverStatus = ServerStatus.Offline;
        this.socket.disconnect();
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
}
