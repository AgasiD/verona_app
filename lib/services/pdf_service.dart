import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:verona_app/models/pedido.dart';

import '../helpers/helpers.dart';

class PDFService {
  static Future<dynamic> generarPDFPedido(Pedido pedido) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Container(
            child: pw.Column(children: [
              pw.Text(pedido.titulo, style: pw.TextStyle(fontSize: 35)),
              pw.SizedBox(height: 30),
              pw.Text('Solicitado por ' + pedido.nombreUsuario,
                  style: pw.TextStyle(fontSize: 22)),
              pw.SizedBox(height: 30),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    Text('Prioridad:' +
                        ['ALTA', 'MEDIA', 'BAJA'][pedido.prioridad - 1]),
                    Text('Fecha deseada:' + pedido.fechaDeseada),
                    Text('Fecha estimada:' + pedido.fechaEstimada)
                  ]),
              pw.SizedBox(height: 50),
              pw.Text('Detalle del pedido',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 25),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Text(pedido.nota,
                    style: pw.TextStyle(fontSize: 18),
                    overflow: pw.TextOverflow.clip)
              ])
            ]),
          ),
        ),
      );
      final genero = await generarPDF(pdf, pedido.titulo.replaceAll(' ', ''));
      if (!genero[0]) {
        throw Exception(genero[1]);
      }
      return [true, genero[1]];
    } catch (err) {
      return [false, err.toString()];
    }
  }

  static Future<dynamic> generarPDF(Document pdf, String nombre) async {
    try {
      var dir = await getTemporaryDirectory();
      String tempPath = dir!.path;
      final pathFile = '${tempPath}/$nombre.pdf';
      final file = await File(pathFile).create(recursive: true);

      await file.writeAsBytes(await pdf.save());
      return [true, pathFile];
    } catch (err) {
      return [false, err.toString()];
    }
  }
}
