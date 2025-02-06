// ignore_for_file: unnecessary_null_comparison, import_of_legacy_library_into_null_safe, must_be_immutable

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/recepcion/logica/database/cargos_sobre_stock.dart';
import 'package:order_control/views/menu_principal_views/recepcion/logica/obtener_cargos.dart';

class PdfViewScreen extends StatelessWidget {
  final String path;
  PdfViewScreen({Key? key, required this.path}) : super(key: key);
  final SecureStorage _storage = SecureStorage();

  final dbHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: path,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _printPdf(context),
        tooltip: 'Imprimir PDF',
        child: const Icon(Icons.print),
      ),
    );
  }

  Future<bool> printPdfOverNetwork(Uint8List pdfData, String impresora) async {
    //const String printerIp = '192.168.0.42';
    const int printerPort = 9100;
    bool printSuccess = false;

    try {
      final socket = await Socket.connect(impresora, printerPort);

      if (socket != null) {
        socket.add(pdfData);
        await Future.delayed(const Duration(seconds: 5)); // Esperar un poco
        socket.destroy();

        printSuccess = true;
      } else {
        Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Error de conexión con la impresora",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      }
    } catch (e) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Error de conexión con la impresora: $e",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }

    return printSuccess;
  }

  Future<void> _printPdf(BuildContext context) async {
    String token = await _storage.readSecureData("token");
    int tipo = 1;
    var datos = await obtenerImpresora(token, tipo);

    var mensaje = await jsonDecode(datos.body);

    if (mensaje["msg"] == "ok") {
      String impresora = mensaje["data"][0]["Direccion"];
      final pdfData = await File(path).readAsBytes();
      bool printSuccess = await printPdfOverNetwork(pdfData, impresora);
      if (printSuccess) {
        // Muestra el cuadro de diálogo de confirmación si la impresión es exitosa
        _showConfirmationDialog(context);
      }
    } else {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Error al obtener la impresora",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe tocar un botón para cerrar el cuadro de diálogo.
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Impresión enviada con éxito'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('¿Deseas terminar el proceso?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                await _storage.deleteSecureData("validacion");
                await _storage.deleteSecureData("jsonCobros");
                await _storage.deleteSecureData("jsonporaprobar");
                await _storage.deleteSecureData("jsonDetalle");
                await _storage.deleteSecureData("jsonDetalleCaducados");
                await _storage.deleteSecureData("jsonMalEstado");
                await _storage.deleteSecureData("codCargoPendiente");
                await _storage.deleteSecureData("codigoBodega");
                // await _storage.deleteSecureData("path");
                await _storage.deleteSecureData("cod_cargo_recepcion");
                await dbHelper.deleteTable();
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const Home(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
