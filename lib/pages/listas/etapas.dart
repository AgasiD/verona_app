import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:verona_app/models/etapa.dart';
import 'package:verona_app/pages/listas/asigna_etapas_extras.dart';
import 'package:verona_app/pages/listas/tareas.dart';
import 'package:verona_app/services/obra_service.dart';
import 'package:verona_app/widgets/custom_widgets.dart';

class EtapasObra extends StatelessWidget {
  EtapasObra({Key? key}) : super(key: key);
  static final routeName = 'EtapasObra';

  @override
  Widget build(BuildContext context) {
    final _obraService = Provider.of<ObraService>(context);
    return Scaffold(
      backgroundColor: Helper.brandColors[1],
      body: _Etapas(etapas: _obraService.obra.etapas),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, EtapasExtrasPage.routeName),
        backgroundColor: Helper.brandColors[8],
        mini: true,
        child: Icon(Icons.add),
        splashColor: null,
      ),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class _Etapas extends StatelessWidget {
  _Etapas({Key? key, required this.etapas}) : super(key: key);
  List<Etapa> etapas;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 100,
        child: ListView.builder(
          itemCount: etapas.length,
          itemBuilder: (context, index) {
            return _EtapaCard(etapa: etapas[index] as Etapa);
          },
        ),
      ),
    );
  }
}

class _EtapaCard extends StatelessWidget {
  _EtapaCard({Key? key, required this.etapa}) : super(key: key);

  Etapa etapa;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Helper.brandColors[2],
        boxShadow: [
          BoxShadow(
              color: Helper.brandColors[0],
              blurRadius: 4,
              offset: Offset(10, 8))
        ],
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: ListTile(
          onTap: () => Navigator.pushNamed(context, TareasCheckList.routeName,
              arguments: {"etapaId": etapa.id}),
          leading: Container(
            width: 50,
            child: Center(
              child: Row(
                children: [
                  Icon(
                      etapa.porcentajeRealizado < 99
                          ? Icons.check_box_outline_blank_outlined
                          : Icons.check_box,
                      color: Helper.brandColors[3]),
                ],
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.0),
            child: Text(
              etapa.descripcion,
              style: TextStyle(color: Helper.brandColors[4], fontSize: 18),
            ),
          ),
          subtitle: Row(
            // mainAxisAlignment: MainAxisAlignment.,
            children: [
              Container(
                margin: EdgeInsets.only(right: 15),
                width: 100,
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: etapa.porcentajeRealizado / 100,
                  color: Helper.brandColors[8],
                ),
              ),
              Text(
                '${etapa.porcentajeRealizado} %',
                style: TextStyle(color: Helper.brandColors[4]),
              ),
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              color: Helper.brandColors[8]),
        ),
      ),
    );
  }
}