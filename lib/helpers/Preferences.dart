import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _instancia = Preferences._internal();
  late SharedPreferences _prefs;
  factory Preferences() {
    return _instancia;
  }

  Preferences._internal();

  initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  bool get logged {
    return _prefs.getBool('logged') ?? false;
  }

  set logged(bool log) {
    this._prefs.setBool('logged', log);
  }

  String get type {
    return _prefs.getString('type') ?? '';
  }

  set type(String type) {
    this._prefs.setString('type', type);
  }

  String get id {
    return _prefs.getString('id') ?? '';
  }

  set id(String id) {
    _prefs.setString('id', id);
  }

  String get token {
    return _prefs.getString('token') ?? '';
  }

  set token(String token) {
    _prefs.setString('token', token);
  }

  int get role {
    return _prefs.getInt('role') ?? 0;
  }

  set role(int role) {
    _prefs.setInt('role', role);
  }

  String get nombre {
    return _prefs.getString('nombre') ?? '';
  }

  set nombre(String nombre) {
    _prefs.setString('nombre', nombre);
  }

  int get permiso {
    return _prefs.getInt('permiso') ?? 999;
  }

  set permiso(int permiso) {
    _prefs.setInt('permiso', permiso);
  }

  int get badgeNotifications {
    return _prefs.getInt('badgeNotifications') ?? 0;
  }

  set badgeNotifications(int badgeNotifications) {
    _prefs.setInt('badgeNotifications', badgeNotifications);
  }

  deletePreferences() {
    logged = false;
    id = '';
    nombre = '';
    
  }
}
