import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verona_app/helpers/helpers.dart';

class ErrorPage extends StatelessWidget {
  ErrorPage({key, this.errorMsg = 'Estamos trabajando para solucionarlo', this.imageRoute = 'assets/attention.png', this.page = true});
  static String routeName = 'error_page';
  bool page;
  String errorMsg, imageRoute;
  @override
  Widget build(BuildContext context) {
    final body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.triangleExclamation, size: 75, color: Colors.red[500],),
            SizedBox(height: 50,),
            Text('¡Tenemos un problema!', style: TextStyle(fontSize: 20, color: Helper.brandColors[8], fontWeight: FontWeight.bold)),
            SizedBox(height: 10,),
            Text(errorMsg, style: TextStyle(fontSize: 16, color: Helper.brandColors[8])),
            // TextButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, Search_ItemsPage.routeName, (route) => false), child: Text('Regresar', style: TextStyle(fontSize: 18)))
        ]),
      );
    return page ? Scaffold(
      backgroundColor: Helper.brandColors[1],
      drawer: null,
      body: body
    )
    : 
    body;
  }
}