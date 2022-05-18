import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/message.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Offline;
  late IO.Socket _socket;
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  void connect(clientId) {
    print('Estado del servicio ' + this._serverStatus.toString());

    if (this._serverStatus != ServerStatus.Online) {
      final url =
          'http://192.168.0.155:8008'; //'https://veronaserver.herokuapp.com'; //
      this._socket = IO.io(url, {
        'transports': ['websocket'],
        'autoConnect': false,
        'forceNew': true,
        'extraHeaders': {'x-token': clientId}
      });
      if (this.serverStatus == ServerStatus.Offline) {
        this._serverStatus = ServerStatus.Connecting;
        this._socket.connect();
      }
      // Accion al conectarse al servidor
      print(this._serverStatus != ServerStatus.Online &&
          this.serverStatus != ServerStatus.Connecting);
      if (this._serverStatus != ServerStatus.Online &&
          this.serverStatus != ServerStatus.Connecting) {
        this._socket.onConnect((_) {
          this._serverStatus = ServerStatus.Online;
          print('----------CONECTADO CON EL SERVIDOR----------');
          print('notifly listener 7');
          notifyListeners();
        });
      }

      // Accion al desconectarse del servidor
      this._socket.onDisconnect((_) {
        print('usuario desconectado');
        this._serverStatus = ServerStatus.Offline;
        this.socket.disconnect();
        print('notifly listener 8');
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
