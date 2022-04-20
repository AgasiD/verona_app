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

  String get id {
    return _prefs.getString('id') ?? '';
  }

  set id(String id) {
    _prefs.setString('id', id);
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
}
