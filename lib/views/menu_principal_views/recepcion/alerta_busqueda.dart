// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/views/menu_principal_views/recepcion/logica/clase_cargos.dart';
import 'package:order_control/views/menu_principal_views/recepcion/logica/methods.dart';
import 'package:order_control/views/menu_principal_views/recepcion/logica/obtener_cargos.dart';

class AlertaBusquedaManual extends StatefulWidget {
  final String titulo;
  final String token;

  const AlertaBusquedaManual({Key? key, required this.titulo, required this.token}) : super(key: key);

  @override
  _AlertaBusquedaManualState createState() => _AlertaBusquedaManualState();
}

class _AlertaBusquedaManualState extends State<AlertaBusquedaManual> {
  TextEditingController editingController = TextEditingController();
  List<CargosPendientes> cargos = [];
  final StreamController<double> _progressController = StreamController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => Future.value(false),
      child: AlertDialog(
        title: Text(widget.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: editingController,
                decoration: const InputDecoration(
                  labelText: "Número de cargo",
                  hintText: "Ingrese el número del cargo",
                  suffixIcon: Icon(Icons.file_copy),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () async {
              if (editingController.text == "") {
                Fluttertoast.showToast(
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  msg: "Debe ingresar un valor valido",
                  gravity: ToastGravity.BOTTOM,
                  toastLength: Toast.LENGTH_SHORT,
                );
              } else {
                try {
                  var datos = await obtenerCargos(widget.token, int.parse(editingController.text));
                  cargos = parseCargos(datos.body);
                  final totalItem = cargos.length;
                  for (int i = 0; i < cargos.length; i++) {
                    //await dbHelper.insert(cargos[i]);
                    final progress = (i + 1) / totalItem;
                    _progressController.sink.add(progress);
                  }
                  _progressController.sink.add(1.0);
                } catch (e) {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: "El cargo ingresado no es correcto",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              }
            },
          )
        ],
      ),
    );
  }
}
