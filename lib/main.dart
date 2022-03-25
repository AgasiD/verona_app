import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/pages/Form.dart';
import 'package:verona_app/pages/addpropietarios.dart';
import 'package:verona_app/pages/login.dart';
import 'package:verona_app/pages/notificaciones.dart';
import 'package:verona_app/routes/routes.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/services/usuario_service.dart';

void main() => runApp(AppState());

class AppState extends StatelessWidget {
  // Para inyectar services http
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ObraService(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => UsuarioService(),
          lazy: false,
        ), //lazy es para que se cree cuando se necesite. con el false se crea cuando se instancia.
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verona App',
      initialRoute: LoginPage.routeName,
      routes: appRoutes,
    );
  }
}
