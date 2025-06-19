import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/MyResponse.dart';
import 'package:verona_app/models/config.dart';
import 'package:verona_app/pages/error.dart';
import 'package:verona_app/services/config_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static final routeName = 'Settings';
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

late ConfigService _configService;

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    _configService = Provider.of<ConfigService>(context, listen: false);

    return Scaffold(
      backgroundColor: Helper.brandColors[1],
      body: FutureBuilder(
          future: _configService.obtener_config(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return Loading(mensaje: 'Cargando información...');
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasError) {
              return ErrorPage(errorMsg: snapshot.error.toString());
            }

            final config =
                Config.fromJson(snapshot.data as Map<String, dynamic>);
            return Settings_Form(
              config: config,
            );
          }),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class Settings_Form extends StatefulWidget {
  Settings_Form({Key? key, required this.config}) : super(key: key);
  Config config;

  @override
  State<Settings_Form> createState() => _Settings_FormState();
}

class _Settings_FormState extends State<Settings_Form> {
  double sizebox_height = 25;
  double fontsize = 17;
  late bool habilita_reporte;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    habilita_reporte = widget.config.send_ws_reports;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Habilitar envío de reportes',
                  style: TextStyle(
                      color: Helper.brandColors[4], fontSize: fontsize),
                ),
                Switch(
                    value: habilita_reporte,
                    activeColor: Helper.brandColors[3],
                    activeTrackColor: Helper.brandColors[8],
                    inactiveTrackColor: Helper.brandColors[3],
                    onChanged: (value) => habilitar_reporte(value))
              ],
            ),
            SizedBox(
              height: sizebox_height,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Horario envío de reporte',
            //       style: TextStyle(
            //           color: Helper.brandColors[4], fontSize: fontsize),
            //     ),
            //   ],
            // ),
            // SizedBox(
            //   height: sizebox_height,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Horario guardado backup',
            //       style: TextStyle(
            //           color: Helper.brandColors[4], fontSize: fontsize),
            //     ),
            //     // Switch(
            //     //     value: habilita_reporte,
            //     //     onChanged: (value) => habilitar_reporte(value))
            //   ],
            // ),
          ],
        ),
      ),
    ));
  }

  habilitar_reporte(habilitado) async {
    bool loading = false;

    try {
      openLoadingDialog(mensaje: 'Actualizando...');
      loading = true;
      widget.config.send_ws_reports = habilitado;
      final response = await _configService.actualizar(widget.config.toMap());
      closeLoadingDialog();
      habilita_reporte = widget.config.send_ws_reports;
      setState(() {});
    } catch (err) {
      closeLoadingDialog();
      openAlertDialog( 'Error al actualizar',
          subMensaje: err.toString());
    }
  }
}
