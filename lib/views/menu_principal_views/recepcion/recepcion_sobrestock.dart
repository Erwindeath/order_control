// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_const_literals_to_create_immutables, library_prefixes, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:order_control/views/menu_principal_views/recepcion/sadasd.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;

import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/recepcion/logica/clase_cargos.dart';
import 'package:order_control/views/menu_principal_views/recepcion/logica/database/cargos_sobre_stock.dart';
import 'package:order_control/views/menu_principal_views/recepcion/logica/methods.dart';
import 'package:order_control/views/menu_principal_views/recepcion/logica/obtener_cargos.dart';
import 'package:soundpool/soundpool.dart';

class RecepcionSobreStock extends StatefulWidget {
  const RecepcionSobreStock({Key? key}) : super(key: key);

  @override
  State<RecepcionSobreStock> createState() => _RecepcionSobreStockState();
}

class _RecepcionSobreStockState extends State<RecepcionSobreStock> {
  final SecureStorage _storage = SecureStorage();
  bool validacion = false;
  bool datossqlite = false;
  String token = "";
  int cantidadCajas = 0;
  int? selectedRow;
  TextEditingController editingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper();
  List<CargosPendientes> cargosss = [];
  List<dynamic> lotesCombinados = [];
  CargosPendientes? datos;
  CargosPendientes? prueba;
  List<CargosPendientes> dato = [];
  final StreamController<double> _progressController = StreamController();
  bool estadoBoton = true;
  List<Map<String, dynamic>> valores = [];
  List<Map<String, dynamic>> filteredValores = [];
  bool comprobarNuevoValor = false;
  bool validacionInicial = false;
  bool nuevaVerificacion = false;
  StreamSubscription<dynamic>? fdwListener;
  StreamSubscription<dynamic>? fdwListener2;
  var fdw = FlutterDataWedge(profileName: 'FlutterDataWedge');
  var fdw2 = FlutterDataWedge(profileName: 'FlutterDataWedge2');
  List<int?> loteSeleccionados = [];

  List<CargosPendientes> filasAdicionales = [];
  List<TextEditingController> cantidadControllers = [];
  List<int?> dropdownValues = [];

  int idFilaAdicional = 0;
  int? loteSeleccionadoAdicional;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Recepción por sobrestock",
              style: TextStyle(color: Colors.white, fontSize: 15.0), //<-- SEE HERE
            ),
          ],
        ),
        actions: [
          FloatingActionButton(
            backgroundColor: Colors.grey.shade300,
            shape: const RoundedRectangleBorder(),
            onPressed: () async {
              int codBodega = 0;
              List<Map<String, dynamic>> jsonLotes = [];

              List<Map<String, dynamic>> jsonDemas = [];

              List<Map<String, dynamic>> jsonDemenos = [];

              List<Map<String, dynamic>> jsonDestino45 = [];
              List<Map<String, dynamic>> jsonDestino6 = [];

              List<Map<String, dynamic>> destino1 = [];
              List<Map<String, dynamic>> destino2 = [];

              int codSesion = int.parse(await _storage.readSecureData("codSesion"));
              //List<Map<String, dynamic>> jsonDemenos = [];
              dato = await dbHelper.getAllProductos("");
              for (int i = 0; i < dato.length; i++) {
                var ordenActual = dato[i];
                List<dynamic> lotesSeleccionados = ordenActual.lotesSeleccionados;
                //print(lotesSeleccionados);List<dynamic> lotes = ordenActual.lotes;
                codBodega = ordenActual.codBodega;

                Map<String, dynamic> productoMap = {
                  'productoIva': ordenActual.productoIva,
                  'Estacion': 176,
                  "codSesion": codSesion,
                  'Fraccion': ordenActual.fraccion,
                  'Cod_Producto': ordenActual.codProducto,
                  'producto': ordenActual.descripcion,
                  'U_Compara': ordenActual.cantidad,
                  'Cant_Real': ordenActual.cantidad,
                  'LAB': ordenActual.siglas,
                  'Costo': ordenActual.costo,
                  'Precio': ordenActual.costoVenta,
                  'Cant_F': 0,
                  'escaneo': [],
                };

                for (var loteEscaneado in lotesSeleccionados) {
                  {
                    var escaneoMap = {
                      'Cod_Lote': loteEscaneado['Cod_Lote'],
                      'lotes': loteEscaneado['lotes'],
                      'producto': ordenActual.descripcion,
                      'Fecha_Vencimiento': loteEscaneado['Fecha_Vencimiento'],
                      'Fecha': loteEscaneado['Fecha_Vencimiento'],
                      'Cantidad': loteEscaneado['Cantidad'],
                      'Destino': loteEscaneado['Destino'],
                      'Cant_U': loteEscaneado['Cantidad'],
                      'Costo': ordenActual.costo,
                      'Parcial': 0,
                      'F_Compara': 0,
                      'Precio': ordenActual.costoVenta,
                      'Descuento': 0,
                      'Cant_Compara': 0,
                    };

                    productoMap['escaneo'].add(escaneoMap);
                  }
                }

                jsonLotes.add(productoMap);
              }

              for (int i = 0; i < jsonLotes.length; i++) {
                var producto = jsonLotes[i];
                var escaneos = producto['escaneo'];
                var escaneosDestino45 = <Map<String, dynamic>>[];

                for (int j = 0; j < escaneos.length; j++) {
                  var escaneo = escaneos[j];

                  if (escaneo['Destino'] == 4 || escaneo['Destino'] == 5) {
                    // Crear una copia superficial del producto y asignar solo este 'escaneo' a su lista de 'escaneo'
                    var productoConDestino3 = Map<String, dynamic>.from(producto);
                    productoConDestino3['escaneo'] = [escaneo];
                    escaneosDestino45.add(productoConDestino3);
                  }
                }

                // Agregar el producto con los escaneos de destino 4 o 5 a la lista jsonDestino45
                if (escaneosDestino45.isNotEmpty) {
                  jsonDestino45.addAll(escaneosDestino45);
                }
              }
              for (int i = 0; i < jsonLotes.length; i++) {
                var producto = jsonLotes[i];
                var escaneos = producto['escaneo'];
                var escaneosDestino6 = <Map<String, dynamic>>[];

                for (int j = 0; j < escaneos.length; j++) {
                  var escaneo = escaneos[j];

                  if (escaneo['Destino'] == 6) {
                    // Crear una copia superficial del producto y asignar solo este 'escaneo' a su lista de 'escaneo'
                    var productoConDestino6 = Map<String, dynamic>.from(producto);
                    productoConDestino6['escaneo'] = [escaneo];
                    escaneosDestino6.add(productoConDestino6);
                  }
                }
                // Agregar el producto con los escaneos de destino 4 o 5 a la lista jsonDestino45
                if (escaneosDestino6.isNotEmpty) {
                  jsonDestino6.addAll(escaneosDestino6);
                }
              }
              outerLoop:
              for (var producto in jsonLotes) {
                var uCompara = producto['U_Compara'];
                var sumCantidad = 0;
                if (producto['escaneo'].isEmpty) {
                  var nuevoprodueco = {
                    "productoIva": producto['productoIva'],
                    'Cod_Producto': producto['Cod_Producto'],
                    'Producto': producto['producto'],
                    'LAB': producto['LAB'],
                    'Cant_U': producto['U_Compara'],
                    'Cant_F': 0,
                    'Costo': producto['Costo'],
                    'Parcial': producto['U_Compara'] * producto['Costo'],
                    'Fraccion': producto['Fraccion'],
                    'Precio': producto['Precio'],
                    'U_Compara': producto['U_Compara'],
                    'F_Compara': 0, // Reemplazar con el valor real si está disponible
                    'Cant_Real': producto['U_Compara'], // Reemplazar con el valor real si está disponible
                    'Fecha': "",
                    'Lotes': []
                  };
                  jsonDemenos.add(Map<String, dynamic>.from(nuevoprodueco)); // Aquí simplemente estamos añadiendo el producto original
                  continue outerLoop;
                }

                //print("jsonDestino45");

                List<Map<String, dynamic>> lotes = [];
                Map<String, dynamic>? ultimoEscaneo;

                for (var escaneo in producto['escaneo']) {
                  sumCantidad += int.parse(escaneo['Cantidad'].toString());
                  var lote = {
                    'Cod_Lote': escaneo['Cod_Lote'],
                    'lotes': escaneo['lotes'],
                    'Fecha_Vencimiento': escaneo['Fecha_Vencimiento'],
                    'Fecha': escaneo['Fecha'],
                    'Cantidad': escaneo['Cantidad'],
                    'Destino': escaneo['Destino']
                  };
                  lotes.add(lote);
                  ultimoEscaneo = escaneo;
                }

                if (ultimoEscaneo != null) {
                  //if (ultimoEscaneo["Destino"] == 1 || ultimoEscaneo["Destino"] == 2) {
                  if (uCompara < sumCantidad) {
                    var nuevoProducto = {
                      "productoIva": producto['productoIva'],
                      'Cod_Producto': producto['Cod_Producto'],
                      'Producto': producto['producto'],
                      'Cant_U': sumCantidad - producto['U_Compara'],
                      'Cant_Real': sumCantidad - producto['U_Compara'],
                      'LAB': producto['LAB'],
                      'Cant_F': producto['Cant_F'],
                      'Parcial': (sumCantidad - producto['U_Compara']) * ultimoEscaneo['Costo'],
                      'Fraccion': producto['Fraccion'],
                      'Costo': ultimoEscaneo['Costo'],
                      'Precio': ultimoEscaneo['Precio'],
                      'Descuento': ultimoEscaneo['Descuento'],
                      'F_Compara': 0,
                      'CantidadF': sumCantidad
                    };
                    jsonDemas.add(Map<String, dynamic>.from(nuevoProducto));
                  } else if (uCompara > sumCantidad) {
                    var nuevoProducto = {
                      "productoIva": producto['productoIva'],
                      'Cod_Producto': producto['Cod_Producto'],
                      'Producto': producto['producto'],
                      'Cant_U': producto['U_Compara'] - sumCantidad,
                      'Cant_Real': producto['U_Compara'] - sumCantidad,
                      'LAB': producto['LAB'],
                      'Cant_F': producto['Cant_F'],
                      'Parcial': (producto['U_Compara'] - sumCantidad) * producto['Costo'],
                      'Fraccion': producto['Fraccion'],
                      'Costo': producto['Costo'],
                      'Precio': producto['Precio'],
                      'F_Compara': 0,
                      'CantidadF': sumCantidad
                    };
                    jsonDemenos.add(Map<String, dynamic>.from(nuevoProducto));
                  }
                  //}
                }
              }

              for (var producto in jsonLotes) {
                for (var escaneo in producto['escaneo']) {
                  var loteInfo = {
                    'Producto_Iva': producto["productoIva"],
                    'Cod_Producto': producto['Cod_Producto'],
                    'Producto': producto['producto'],
                    'Lab': producto['LAB'],
                    'Costo': producto['Costo'],
                    'Precio': producto['Precio'],
                    'Fraccion': producto['Fraccion'],
                    'U_Compara': producto['U_Compara'],
                    'Cant_F': producto['Cant_F'],
                    ...escaneo
                  };

                  if (escaneo['Destino'] == 1 && escaneo["Cantidad"] > 0) {
                    destino1.add({...loteInfo});
                  } else if (escaneo['Destino'] == 2 && escaneo["Cantidad"] > 0) {
                    destino2.add({...loteInfo});
                  }
                }
              }

              List<Map<String, dynamic>> jsonDetalleCobro = [];
              List<Map<String, dynamic>> jsonDetalleDestino6 = [];
              List<Map<String, dynamic>> jsonDestino1 = [];
              List<Map<String, dynamic>> jsonDestino2 = [];
              int validaDemas = jsonDemas.isEmpty ? 0 : 1;
              int validaDemenos = jsonDemenos.isEmpty ? 0 : 1;
              int validaCobro = jsonDestino45.isEmpty ? 0 : 1;
              jsonDetalleCobro = await formarJsonCobro(jsonDestino45, dato, codSesion);

              jsonDetalleDestino6 = await formarJsonAprobaciom(jsonDestino6, dato, codSesion);

              String tokennuevo = await _storage.readSecureData("token");
              String codCargoPendiente = await _storage.readSecureData("cod_cargo_recepcion");

              Map<String, String> totalesCobroNuevo = await calcularTotalesCobro(jsonDetalleCobro);
              Map<String, String> totalesDistribucion = await calcularTotales(destino1);
              Map<String, String> totalesDevolucion = await calcularTotales(destino2);
              Map<String, String> totalesPorAprobacion = await calcularTotales(jsonDetalleDestino6);

              jsonDestino1 = await formarJson(destino1, dato, codSesion);
              jsonDestino2 = await formarJson(destino2, dato, codSesion);
              List<Map<String, dynamic>> resumenDestinos = [];

              Map<String, int> acumuladoDestinos = {};

              for (var lote in [...destino1, ...destino2]) {
                String key = lote['Cod_Lote'].toString();
                if (acumuladoDestinos.containsKey(key)) {
                  acumuladoDestinos[key] = (acumuladoDestinos[key] ?? 0) + int.parse(lote['Cant_U'].toString());
                } else {
                  acumuladoDestinos[key] = lote['Cant_U'];
                }
              }

              acumuladoDestinos.forEach((key, value) {
                resumenDestinos.add({'Cod_Cargo_Pendiente': int.parse(codCargoPendiente), 'Cod_Lote': key, 'Cant_Unidad': value, 'Cant_Fraccion': 0});
              });

              int validaLotes = resumenDestinos.isEmpty ? 0 : 1;
              int validaDevolucion = destino2.isEmpty ? 0 : 1;
              int validaDistribucion = destino1.isEmpty ? 0 : 1;

              int validaPorAprobacion = jsonDestino6.isEmpty ? 0 : 1;
              Set<String> observacionesUnicas = {};

// Recorremos la lista de detalles de cobro
              for (var detalle in jsonDetalleCobro) {
                // Obtenemos el valor de la clave Destino
                int destino = detalle["Destino"];

                // Verificamos el valor y añadimos la observación correspondiente al Set
                switch (destino) {
                  case 5:
                    observacionesUnicas.add("Cobro por caducidad");
                    break;
                  case 4:
                    observacionesUnicas.add("Cobro por mal estado");
                    break;
                  // Puedes agregar más casos si necesitas más opciones de destino
                }
              }

              String observacion = observacionesUnicas.join(", ");

              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  // Combinando ambas listas en una
                  List<dynamic> combinedList = [];
                  if (jsonDemas.isNotEmpty) combinedList.addAll(jsonDemas);
                  if (jsonDemenos.isNotEmpty) combinedList.addAll(jsonDemenos);
                  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                    return WillPopScope(
                      onWillPop: () async => Future.value(false),
                      child: AlertDialog(
                        title: const Column(
                          children: [
                            Text(
                              'Productos con novedades',
                              style: TextStyle(fontSize: 16.0, color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            Text('Al guardar acepta que estos productos están con esas novedades y no podrá volver atrás',
                                style: TextStyle(fontSize: 14.0)),
                          ],
                        ),
                        content: Column(
                          children: [
                            // Aquí está el CustomScrollView
                            Expanded(
                              child: combinedList.isEmpty
                                  ? const Center(child: Text("Orden sin novedades que mostrar"))
                                  : Scrollbar(
                                      thickness: 10.0,
                                      radius: const Radius.circular(8.0),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: combinedList.length,
                                        itemBuilder: (context, index) {
                                          var productoJson = combinedList[index];

                                          return Card(
                                            elevation: 4,
                                            child: ListTile(
                                              title: Row(
                                                children: [
                                                  Expanded(
                                                    child: Align(
                                                      alignment: Alignment.centerLeft, // Alinea el texto a la izquierda
                                                      child: Text(
                                                        '${productoJson['Producto']} ',
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${productoJson['CantidadF'] ?? 0}/${productoJson["Cant_U"]}',
                                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              // Agrega otros elementos que necesites aquí
                                            ),
                                          );
                                        },
                                      ),
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
                            child: const Text("Guardar"),
                            onPressed: estadoBoton
                                ? () async {
                                    Fluttertoast.showToast(
                                      backgroundColor: Colors.orange.shade300,
                                      textColor: Colors.white,
                                      msg: "Enviando datos, espere por favor",
                                      gravity: ToastGravity.BOTTOM,
                                      toastLength: Toast.LENGTH_SHORT,
                                    );

                                    setState(() {
                                      estadoBoton = false;
                                    });
                                    int codUsuario = int.parse(await _storage.readSecureData("cod_usuario"));
                                    var datosEnvio = await enviarRecepcionDatos2(
                                        tokennuevo,
                                        29,
                                        176,
                                        codSesion,
                                        0,
                                        2000,
                                        codBodega,
                                        int.parse(codCargoPendiente),
                                        validaPorAprobacion,
                                        jsonEncode(jsonDetalleDestino6),
                                        jsonEncode([totalesPorAprobacion]),
                                        observacion,
                                        validaDemas,
                                        jsonEncode(jsonDemas),
                                        validaDemenos,
                                        jsonEncode(jsonDemenos),
                                        validaCobro,
                                        jsonEncode(jsonDetalleCobro),
                                        validaDevolucion,
                                        jsonEncode(jsonDestino2),
                                        validaDistribucion,
                                        jsonEncode(jsonDestino1),
                                        validaLotes,
                                        jsonEncode(resumenDestinos),
                                        jsonEncode([totalesDevolucion]),
                                        jsonEncode([totalesDistribucion]),
                                        jsonEncode([totalesCobroNuevo]),
                                        codUsuario);
                                    var datosdecode = await jsonDecode(datosEnvio.body);

                                    if (datosdecode["msg"] == "err") {
                                      setState(() {
                                        estadoBoton = true;
                                      });
                                      Fluttertoast.showToast(
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        msg: "Ocurrió un error: ${datosdecode["controlador"]["descripcion"]}",
                                        gravity: ToastGravity.BOTTOM,
                                        toastLength: Toast.LENGTH_SHORT,
                                      );

                                      if (datosdecode["controlador"]["nombre"] == "ErrorComprueba") {
                                        await enviarRecepcionSobreStock(codBodega, jsonDetalleCobro, jsonDetalleDestino6, destino1, destino2);
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        msg: "Datos enviados con éxito",
                                        gravity: ToastGravity.BOTTOM,
                                        toastLength: Toast.LENGTH_SHORT,
                                      );

                                      await enviarRecepcionSobreStock(codBodega, jsonDetalleCobro, jsonDetalleDestino6, destino1, destino2);
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                    );
                  });
                },
              );
            },
            child: const Icon(Icons.file_upload_outlined, color: Colors.black),
          )
        ],
      ),
      body: Form(key: _formKey, child: inicial(context)),
    );
  }

  Future<void> imprimir(
      List<Map<String, dynamic>> jsonCobro,
      List<Map<String, dynamic>> jsonDetalle,
      List<Map<String, dynamic>> jsonDetalleCaducado,
      // List<dynamic> jsonMalEstado,
      String codCargoPendiente,
      int codBodega,
      List<Map<String, dynamic>> jsonPorAprobacione) async {
    var nombre = await _storage.readSecureData("Nombre");
    List<Map<String, dynamic>> jsonDetalleFiltrado = jsonDetalle.map((detalle) {
      return {
        "Fecha": detalle["Fecha"],
        "Producto": detalle["Producto"],
        "Lab": detalle["Lab"],
        "lote": detalle["lotes"], // Asegúrate de que la clave es correcta, en tu ejemplo es "lote" con minúscula
        "Cant_U": detalle["Cant_U"],
      };
    }).toList();
    jsonDetalleFiltrado.sort((a, b) {
      int compare = a["Lab"].compareTo(b["Lab"]);
      if (compare == 0) {
        compare = a["Producto"].compareTo(b["Producto"]);
      }
      return compare;
    });
    List<Map<String, dynamic>> jsonDetalleCobro = jsonCobro.map((detalle) {
      return {
        "Fecha": detalle["Fecha"],
        "Producto": detalle["Producto"],
        "Lab": detalle["LAB"],
        "lote": detalle["lote"], // Asegúrate de que la clave es correcta, en tu ejemplo es "lote" con minúscula
        "Cant_U": detalle["Cant_U"],
      };
    }).toList();
    jsonDetalleCobro.sort((a, b) {
      int compare = a["Lab"].compareTo(b["Lab"]);
      if (compare == 0) {
        compare = a["Producto"].compareTo(b["Producto"]);
      }
      return compare;
    });
    List<Map<String, dynamic>> jsonDetalleCaducadoFiltrado = jsonDetalleCaducado.map((detalle) {
      return {
        "Fecha": detalle["Fecha"],
        "Producto": detalle["Producto"],
        "Lab": detalle["Lab"],
        "lote": detalle["lotes"], // Asegúrate de que la clave es correcta, en tu ejemplo es "lote" con minúscula
        "Cant_U": detalle["Cant_U"],
      };
    }).toList();
    jsonDetalleCaducadoFiltrado.sort((a, b) {
      int compare = a["Lab"].compareTo(b["Lab"]);
      if (compare == 0) {
        compare = a["Producto"].compareTo(b["Producto"]);
      }
      return compare;
    });
    List<Map<String, dynamic>> jsonPorAprobacion = jsonPorAprobacione.map((detalle) {
      return {
        "Fecha": detalle["Fecha"],
        "Producto": detalle["Producto"],
        "Lab": detalle["LAB"],
        "lote": detalle["lote"], // Asegúrate de que la clave es correcta, en tu ejemplo es "lote" con minúscula
        "Cant_U": detalle["Cant_U"],
      };
    }).toList();
    jsonPorAprobacion.sort((a, b) {
      int compare = a["Lab"].compareTo(b["Lab"]);
      if (compare == 0) {
        compare = a["Producto"].compareTo(b["Producto"]);
      }
      return compare;
    });
    String path = await generatePdf(jsonDetalleCobro, jsonDetalleFiltrado, jsonDetalleCaducadoFiltrado, /*, jsonMalEstado,*/ codCargoPendiente,
        codBodega, nombre, jsonPorAprobacion);

    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => PdfViewScreen(path: path),
      ),
      (route) => false,
    );
  }

  Future<String> generatePdf(
      List<Map<String, dynamic>> jsonCobro,
      List<Map<String, dynamic>> jsonDetalle,
      List<Map<String, dynamic>> jsonDetalleCaducado,
      //  List<dynamic> jsonMalEstado,
      String codCargoPendiente,
      int codBodega,
      String nombre,
      List<Map<String, dynamic>> jsonPorAprobacion) async {
    int codbodegaNuevo = codBodega < 17 ? codBodega - 1 : codBodega;
    final pdf = pdfWidgets.Document();

    Future<void> addPage(List<dynamic> jsonData, String title, String TipoMovimiento, String numeroOrden, String codFarmacia, bool firmas,
        String destino, String nombreRealiza, String nombreRecibe) async {
      int rowsPerPageFirstPage = 40; // filas por página para la primera página

      int totalRows = jsonData.length;
      int totalPages = (totalRows / rowsPerPageFirstPage).ceil();

      final String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());

      int startRow = 0;
      for (int i = 0; i < totalPages; i++) {
        int rowsPerPage = rowsPerPageFirstPage;
        int endRow = startRow + rowsPerPage - 1;
        if (endRow >= totalRows) {
          endRow = totalRows - 1;
        }

        // Extrae un fragmento de jsonData para esta página
        var pageData = jsonData.sublist(startRow, endRow + 1);
        await Future.delayed(const Duration(milliseconds: 1000));
        startRow = endRow + 1;
        pdf.addPage(
          pdfWidgets.Page(
            build: (pdfWidgets.Context context) => pdfWidgets.Column(
              children: [
                if (i == 0) // Encabezado solo en la primera página
                  pdfWidgets.Column(
                    children: [
                      pdfWidgets.Center(
                        child: pdfWidgets.Text(
                          "FARMACIAS SAN GREGORIO",
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        ),
                      ),
                      pdfWidgets.SizedBox(height: 8.0),
                      pdfWidgets.Text("SOCIEDAD CIVIL DE HECHO DENOMINADO GRUPO USCOCOVICH"),
                      pdfWidgets.SizedBox(height: 5.0),
                      pdfWidgets.Text("FARMACIA SAN GREGORIO # $codFarmacia"),
                      pdfWidgets.SizedBox(height: 14.0),
                      pdfWidgets.Row(
                        crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                        mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
                        children: [
                          pdfWidgets.Text("Fecha movimiento: $formattedDate"),
                        ],
                      ),
                      pdfWidgets.SizedBox(height: 5.0),
                      pdfWidgets.Row(
                        mainAxisAlignment: pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.Text("Tipo Movimiento: $TipoMovimiento"),
                        ],
                      ),
                      pdfWidgets.SizedBox(height: 5.0),
                      pdfWidgets.Row(
                        mainAxisAlignment: pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.Text("Destino: $destino"),
                        ],
                      ),
                      pdfWidgets.SizedBox(height: 5.0),
                      pdfWidgets.Row(
                        mainAxisAlignment: pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.Text("Número de orden: $numeroOrden"),
                        ],
                      ),
                      pdfWidgets.SizedBox(height: 20),
                    ],
                  ),

                // Aquí comienza la tabla
                pdfWidgets.Table(
                  border: pdfWidgets.TableBorder.all(),
                  defaultColumnWidth: const pdfWidgets.FlexColumnWidth(1), // Ajuste por defecto
                  columnWidths: {
                    0: const pdfWidgets.FlexColumnWidth(4),
                    1: const pdfWidgets.FlexColumnWidth(1), // Descripcion
                    2: const pdfWidgets.FlexColumnWidth(1.7), // Lote
                    3: const pdfWidgets.FlexColumnWidth(1), // Fecha vencimiento
                    4: const pdfWidgets.FlexColumnWidth(0.5), // Cantidad
                  },
                  children: [
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Center(
                            child: pdfWidgets.Text(
                          "Producto",
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        )),
                        pdfWidgets.Center(
                            child: pdfWidgets.Text(
                          "LAB",
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        )),
                        pdfWidgets.Center(
                            child: pdfWidgets.Text(
                          "Lote",
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        )),
                        pdfWidgets.Center(
                            child: pdfWidgets.Text(
                          "Fecha vence",
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        )),
                        pdfWidgets.Center(
                            child: pdfWidgets.Text(
                          "Cant",
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                    for (var item in pageData)
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Container(
                            padding: const pdfWidgets.EdgeInsets.only(left: 5.0),
                            alignment: pdfWidgets.Alignment.topLeft,
                            child: pdfWidgets.Text(
                              item['Producto'].length > 38 ? item["Producto"].substring(0, 38) : item["Producto"],
                              style: const pdfWidgets.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: pdfWidgets.TextAlign.left,
                            ),
                          ),
                          pdfWidgets.Container(
                            padding: const pdfWidgets.EdgeInsets.only(left: 5.0),
                            alignment: pdfWidgets.Alignment.topLeft,
                            child: pdfWidgets.Text(
                              item['Lab'] ?? '',
                              style: const pdfWidgets.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: pdfWidgets.TextAlign.left,
                            ),
                          ),
                          pdfWidgets.Container(
                              padding: const pdfWidgets.EdgeInsets.only(left: 5.0),
                              alignment: pdfWidgets.Alignment.topLeft,
                              child: pdfWidgets.Text(
                                item['lote'].length > 15 ? item["lote"].substring(0, 15) : item["lote"],
                                style: const pdfWidgets.TextStyle(
                                  fontSize: 10,
                                ),
                              )),
                          pdfWidgets.Container(
                              padding: const pdfWidgets.EdgeInsets.only(left: 5.0),
                              alignment: pdfWidgets.Alignment.topLeft,
                              child: pdfWidgets.Text(
                                item['Fecha'].toString(),
                                style: const pdfWidgets.TextStyle(
                                  fontSize: 10,
                                ),
                              )),
                          pdfWidgets.Container(
                              padding: const pdfWidgets.EdgeInsets.only(right: 5.0),
                              alignment: pdfWidgets.Alignment.topRight,
                              child: pdfWidgets.Text(
                                item['Cant_U'].toString(),
                                style: const pdfWidgets.TextStyle(
                                  fontSize: 10,
                                ),
                              )),
                        ],
                      ),
                  ],
                ),

                pdfWidgets.SizedBox(height: 50), // Espacio extra al final

                if (i == totalPages - 1 && firmas)
                  // Firmas solo en la última página
                  pdfWidgets.Column(
                    children: [
                      pdfWidgets.Row(
                        mainAxisAlignment: pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.Column(
                            crossAxisAlignment: pdfWidgets.CrossAxisAlignment.center,
                            children: [
                              pdfWidgets.Container(
                                width: 200,
                                height: 1,
                              ),
                              pdfWidgets.SizedBox(height: 5),
                              pdfWidgets.Text("__________________________"),
                              pdfWidgets.Text(nombreRealiza),
                            ],
                          ),
                          pdfWidgets.Column(
                            crossAxisAlignment: pdfWidgets.CrossAxisAlignment.center,
                            children: [
                              pdfWidgets.Container(
                                width: 200,
                                height: 1,
                              ),
                              pdfWidgets.SizedBox(height: 5),
                              pdfWidgets.Text("__________________________"),
                              pdfWidgets.Text(nombreRecibe),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                pdfWidgets.Spacer(),
                pdfWidgets.Row(
                  mainAxisAlignment: pdfWidgets.MainAxisAlignment.end,
                  children: [
                    pdfWidgets.Text(
                      "${i + 1}/$totalPages",
                      style: const pdfWidgets.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }

    if (jsonCobro.isNotEmpty) {
      await addPage(
          jsonCobro, 'Título para jsonCobro', 'Cobro por mal estado o caducado', codCargoPendiente, codbodegaNuevo.toString(), false, "", "", "");
      await addPage(
          jsonCobro, 'Título para jsonCobro', 'Cobro por mal estado o caducado', codCargoPendiente, codbodegaNuevo.toString(), false, "", "", "");
    }
    if (jsonDetalle.isNotEmpty) {
      await addPage(jsonDetalle, 'Título para jsonDetalle', 'Cargo por baja rotación', codCargoPendiente, codbodegaNuevo.toString(), true,
          "Bodega de distribución", nombre, "MIGUEL INTRIAGO PEÑAFIEL");
      await addPage(jsonDetalle, 'Título para jsonDetalle', 'Cargo por baja rotación', codCargoPendiente, codbodegaNuevo.toString(), true,
          "Bodega de distribución", nombre, "MIGUEL INTRIAGO PEÑAFIEL");
    }
    if (jsonDetalleCaducado.isNotEmpty) {
      await addPage(jsonDetalleCaducado, 'Título para jsonDetalleCaducado', 'Cargo por baja rotación', codCargoPendiente, codbodegaNuevo.toString(),
          true, "Bodega devoluciones", nombre, "WILMER MENDOZA AVENDAÑO");
      await addPage(jsonDetalleCaducado, 'Título para jsonDetalleCaducado', 'Cargo por baja rotación', codCargoPendiente, codbodegaNuevo.toString(),
          true, "Bodega devoluciones", nombre, "WILMER MENDOZA AVENDAÑO");
    }
    if (jsonPorAprobacion.isNotEmpty) {
      await addPage(jsonPorAprobacion, 'Título para jsonDetalleCaducado', 'Cargo por aprobación', codCargoPendiente, codbodegaNuevo.toString(), false,
          "Bodega inservible", nombre, "WILMER MENDOZA AVENDAÑO");
      await addPage(jsonPorAprobacion, 'Título para jsonDetalleCaducado', 'Cargo por aprobación', codCargoPendiente, codbodegaNuevo.toString(), false,
          "Bodega inservible", nombre, "WILMER MENDOZA AVENDAÑO");
    }
    /*if (jsonMalEstado.isNotEmpty) {
      addPage(jsonMalEstado, 'Título para jsonMalEstado', 'Devolucion por mal estado', codCargoPendiente,
          codBodega.toString(), false, "Farmacia #${codBodega.toString()}", "", "");
      addPage(jsonMalEstado, 'Título para jsonMalEstado', 'Devolucion por mal estado', codCargoPendiente,
          codBodega.toString(), false, "Farmacia #${codBodega.toString()}", "", "");
    }*/
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<Map<String, String>> calcularTotales(List<Map<String, dynamic>> listaProductos) async {
    double base0 = 0.0;
    double baseIva = 0.0;
    double iva = 0.0;
    String valorIva = await _storage.readSecureData("valorIva");
    int valor = int.parse(valorIva);
    for (var producto in listaProductos) {
      var prodIvaTrimmed = (producto['Producto_Iva'] as String).trim();
      if (prodIvaTrimmed == '') {
        base0 += producto['Costo'] * producto['Cant_U'].toDouble();
      } else if (prodIvaTrimmed == '*') {
        double base = (producto['Costo'] / ((valor / 100) + 1)) * producto['Cant_U'].toDouble();
        baseIva += base;
        iva += (base * (valor / 100));
      }
    }

    double total = base0 + iva + baseIva;

    return {
      "Total": total.toStringAsFixed(2),
      "Base_0": base0.toStringAsFixed(2),
      "Iva": iva.toStringAsFixed(2),
      "Base_Iva": baseIva.toStringAsFixed(2),
    };
  }

  Future<Map<String, String>> calcularTotalesCobro(List<Map<String, dynamic>> listaProductos) async {
    double base0 = 0.0;
    double baseIva = 0.0;
    double iva = 0.0;
    String valorIva = await _storage.readSecureData("valorIva");
    int valor = int.parse(valorIva);
    for (var producto in listaProductos) {
      var prodIvaTrimmed = (producto['Producto_Iva'] as String).trim();
      if (prodIvaTrimmed == '') {
        base0 += producto['Precio'] * producto['Cant_U'].toDouble();
      } else if (prodIvaTrimmed == '*') {
        double base = (producto['Precio'] / ((valor / 100) + 1)) * producto['Cant_U'].toDouble();
        baseIva += base;
        iva += (base * (valor / 100));
      }
    }

    double total = base0 + iva + baseIva;

    return {
      "Total": total.toStringAsFixed(2),
      "Base_0": base0.toStringAsFixed(2),
      "Iva": iva.toStringAsFixed(2),
      "Base_Iva": baseIva.toStringAsFixed(2),
    };
  }

  Future<List<Map<String, dynamic>>> formarJson(List<dynamic> jsonDato, List<CargosPendientes> dato, int codSesion) async {
    List<Map<String, dynamic>> jsonNuevo2 = [];
    List<Map<String, dynamic>> jsonCobroFiltrado = [];

    for (var item in jsonDato) {
      var filteredItem = Map.from(item).cast<String, dynamic>();
      var cargosPendientes = dato.firstWhere((element) => element.codProducto == item['Cod_Producto'],
          orElse: () => CargosPendientes(
              codBarra: 'NOT_FOUND',
              codProducto: -1,
              descripcion: 'NOT_FOUND',
              cantidad: -1,
              fraccion: 0,
              costo: 0.0,
              parcial: 0.0,
              cantReal: 0,
              costoVenta: 0.0,
              codBodega: 0,
              documento: '',
              fecha: DateTime.now(),
              observacion: '',
              total: 0.0,
              siglas: '',
              productoIva: '',
              politica: '',
              valorPolitica: '',
              cajasEscaneadas: 0,
              precioPublico: 0.0));

      if (cargosPendientes != null) {
        jsonNuevo2.add({
          'Producto_Iva': cargosPendientes.productoIva,
          'estacion': 176,
          'codSesion': codSesion,
          'Cod_Producto': cargosPendientes.codProducto,
          'Cod_Lote': item['Cod_Lote'],
          'lote': item['lotes'],
          'Cant_U': item['Cant_U'],
          'Cant_F': 0,
          'Precio': item['Precio'],
          'Descuento': 0,
          'Costo': item['Costo'],
          'Cant_Real': item['Cant_U'],
          'Parcial': item["Costo"] * item['Cant_U'],
          'PrecioPublico': cargosPendientes.precioPublico,
          'TipoMf': "",
          'Base': 0,
          'Bonificacion': 0,
          'Fraccion': item["Fraccion"],
          'id_broanet_invoicing': null,
          'Lab': cargosPendientes.siglas,
          'Producto': item['Producto'],
          'Fecha': item['Fecha']
        });
      }

      jsonCobroFiltrado.add(filteredItem);
    }

    return jsonNuevo2;
  }

  Future<List<Map<String, dynamic>>> formarJsonCobro(List<dynamic> jsonDato, List<CargosPendientes> dato, int codSesion) async {
    List<Map<String, dynamic>> jsonNuevo2 = [];
    List<Map<String, dynamic>> jsonCobroFiltrado = [];

    for (var item in jsonDato) {
      for (var escaneo in item['escaneo']) {
        var filteredItem = Map.from(escaneo).cast<String, dynamic>();
        var cargosPendientes = dato.firstWhere((element) => element.codProducto == item['Cod_Producto'],
            orElse: () => CargosPendientes(
                codBarra: 'NOT_FOUND',
                codProducto: -1,
                descripcion: 'NOT_FOUND',
                cantidad: -1,
                fraccion: 0,
                costo: 0.0,
                parcial: 0.0,
                cantReal: 0,
                costoVenta: 0.0,
                codBodega: 0,
                documento: '',
                fecha: DateTime.now(),
                observacion: '',
                total: 0.0,
                siglas: '',
                productoIva: '',
                politica: '',
                valorPolitica: '',
                cajasEscaneadas: 0,
                precioPublico: 0.0));

        if (cargosPendientes != null) {
          jsonNuevo2.add({
            'Producto_Iva': cargosPendientes.productoIva,
            'estacion': 176,
            'codSesion': codSesion,
            'Cod_Producto': cargosPendientes.codProducto,
            'Cod_Lote': escaneo['Cod_Lote'],
            'lote': escaneo['lotes'],
            'Cant_U': escaneo['Cantidad'],
            'Cant_F': 0,
            'Precio': escaneo['Precio'],
            'Descuento': 0,
            'Costo': escaneo['Costo'],
            'Cant_Real': escaneo['Cantidad'],
            'Parcial': escaneo["Precio"] * escaneo['Cantidad'],
            'PrecioPublico': cargosPendientes.precioPublico,
            'TipoMf': "",
            'Base': 0,
            'Bonificacion': 0,
            'Fraccion': item["Fraccion"],
            'id_broanet_invoicing': null,
            'U_Compara': escaneo['Cantidad'],
            'LAB': cargosPendientes.siglas,
            'Producto': escaneo['producto'],
            'Fecha': escaneo['Fecha'],
            'Destino': escaneo['Destino']
          });
        }

        jsonCobroFiltrado.add(filteredItem);
      }
    }

    return jsonNuevo2;
  }

  Future<List<Map<String, dynamic>>> formarJsonAprobaciom(List<dynamic> jsonDato, List<CargosPendientes> dato, int codSesion) async {
    List<Map<String, dynamic>> jsonNuevo2 = [];
    List<Map<String, dynamic>> jsonCobroFiltrado = [];

    for (var item in jsonDato) {
      for (var escaneo in item['escaneo']) {
        var filteredItem = Map.from(escaneo).cast<String, dynamic>();
        var cargosPendientes = dato.firstWhere((element) => element.codProducto == item['Cod_Producto'],
            orElse: () => CargosPendientes(
                codBarra: 'NOT_FOUND',
                codProducto: -1,
                descripcion: 'NOT_FOUND',
                cantidad: -1,
                fraccion: 0,
                costo: 0.0,
                parcial: 0.0,
                cantReal: 0,
                costoVenta: 0.0,
                codBodega: 0,
                documento: '',
                fecha: DateTime.now(),
                observacion: '',
                total: 0.0,
                siglas: '',
                productoIva: '',
                politica: '',
                valorPolitica: '',
                cajasEscaneadas: 0,
                precioPublico: 0.0));

        if (cargosPendientes != null) {
          jsonNuevo2.add({
            'Producto_Iva': cargosPendientes.productoIva,
            'estacion': 176,
            'codSesion': codSesion,
            'Cod_Producto': cargosPendientes.codProducto,
            'Cod_Lote': escaneo['Cod_Lote'],
            'lote': escaneo['lotes'],
            'Cant_U': escaneo['Cantidad'],
            'Cant_F': 0,
            'Precio': escaneo['Precio'],
            'Descuento': 0,
            'Costo': escaneo['Costo'],
            'Cant_Real': escaneo['Cantidad'],
            'Parcial': escaneo["Costo"] * escaneo['Cantidad'],
            'PrecioPublico': cargosPendientes.precioPublico,
            'TipoMf': "",
            'Base': 0,
            'Bonificacion': 0,
            'Fraccion': item["Fraccion"],
            'id_broanet_invoicing': null,
            'U_Compara': escaneo['Cantidad'],
            'LAB': cargosPendientes.siglas,
            'Producto': escaneo['producto'],
            'Fecha': escaneo['Fecha'],
            'Destino': escaneo['Destino']
          });
        }

        jsonCobroFiltrado.add(filteredItem);
      }
    }

    return jsonNuevo2;
  }

  Future<void> enviarRecepcionSobreStock(
    int codBodega,
    List<Map<String, dynamic>> jsonCobros,
    List<Map<String, dynamic>> jsonporaprobacion,
    List<Map<String, dynamic>> jsonDetalle,
    List<Map<String, dynamic>> jsonDetalleCaducados,
    /*List<dynamic> jsonMalEstado,*/
  ) async {
    String codCargo = await _storage.readSecureData("cod_cargo_recepcion");

    // if (json["msg"] == "ok") {
    if (jsonCobros.isEmpty && jsonDetalle.isEmpty && jsonDetalleCaducados.isEmpty /*&& jsonMalEstado.isEmpty*/ && jsonporaprobacion.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // El usuario debe tocar un botón para cerrar el cuadro de diálogo.
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No hay datos para imprimir'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('¿Finalizar?'),
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
                  // await _storage.deleteSecureData("path");
                  await _storage.deleteSecureData("cod_cargo_recepcion");

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
    } else {
      await _storage.writeSecureData("validacion", "okenviado");
      await _storage.writeSecureData("jsonCobros", jsonEncode(jsonCobros));
      await _storage.writeSecureData("jsonporaprobar", jsonEncode(jsonporaprobacion));
      await _storage.writeSecureData("jsonDetalle", jsonEncode(jsonDetalle));
      await _storage.writeSecureData("jsonDetalleCaducados", jsonEncode(jsonDetalleCaducados));
      // await _storage.writeSecureData("jsonMalEstado", jsonEncode(jsonMalEstado));
      await _storage.writeSecureData("codCargoPendiente", codCargo);
      await _storage.writeSecureData("codigoBodega", codBodega.toString());
      imprimir(jsonCobros, jsonDetalle, jsonDetalleCaducados, /*jsonMalEstado,*/ codCargo, codBodega, jsonporaprobacion);
    }
  }

  Widget inicial(BuildContext context) {
    if (!validacion) {
      return circularPrimero();
    } else {
      return buildPrincipal(context);
    }
  }

  Widget buildPrincipal(BuildContext context) {
    return FutureBuilder<Widget>(
      future: !validacionInicial ? inicio() : card(context),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else if (snapshot.hasError) {
          // Manejar el error en caso de que ocurra
          return Text('Error: ${snapshot.error}');
        } else {
          // Mientras el futuro se resuelve, puedes mostrar un indicador de carga
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<Widget> card(BuildContext context) async {
    if (datos == null) {
      // Si no se ha encontrado un producto, puedes mostrar un mensaje o un widget indicando que no se encontró el producto.
      return inicio();
    } else {
      final ordenes = datos;
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: 60,
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: AssetImage('assets/images/medicamentos.png'),
                                                radius: 35,
                                              )
                                            ],
                                          ),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width - 165,
                                                child: Text(
                                                  ordenes!.descripcion,
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colores.esquemaColor,
                                                  ),
                                                  maxLines: 2,
                                                  softWrap: true,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  await ArtSweetAlert.show(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      artDialogArgs: ArtDialogArgs(
                                                          type: ArtSweetAlertType.info,
                                                          title: "Política de devolución",
                                                          text:
                                                              "El producto ${datos!.descripcion} tiene la politica de devolución de ${datos!.politica} ",
                                                          confirmButtonText: "Aceptar",
                                                          onConfirm: () async {
                                                            Navigator.pop(context);
                                                          },
                                                          confirmButtonColor: Colores.esquemaColor));

                                                  // Aquí puedes agregar la lógica que se ejecutará cuando se presione el botón.
                                                },
                                                icon: const Icon(
                                                  Icons.add_alert_outlined,
                                                  color: Colores.esquemaColor,
                                                  size: 30.0,
                                                ), // Puedes cambiar "Nombre del Botón" por el texto que desees mostrar.
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(padding: const EdgeInsets.all(8.0), child: Text("Cantidad: ${ordenes.cantidad}")),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        adicional(ordenes, context)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Future<Widget> inicio() async {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              iconSize: 90.0,
              onPressed: () async {
                cargosss = await dbHelper.getAllProductos("0");

                setState(() {
                  filteredValores = CargosPendientes.convertirAlistaEspecial(cargosss);
                });
                if (filteredValores.isNotEmpty) {
                  alertaBusquedaManual(context, "Proceso manual");
                } else {
                  //print("error");
                }
              },
            ),
            const Text("Escanee un producto para continuar...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ],
        ),
      ),
    );
  }

  Future<void> alertaAgregarProducto(
    BuildContext context,
    String titulo,
  ) async {
    TextEditingController editingController = TextEditingController();

    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
              title: Text(titulo),
              content: Column(
                children: [
                  // Aquí está el TextField de búsqueda fuera del CustomScrollView
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TextField(
                            controller: editingController,
                            decoration: const InputDecoration(
                              labelText: "Código de barras",
                              hintText: "Buscar",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.search))
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () async {
                    await recargarDatos();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () async {
                    await recargarDatos();
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> alertaBusquedaManual(
    BuildContext context,
    String titulo,
  ) async {
    TextEditingController editingController = TextEditingController();

    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
              title: Text(titulo),
              content: Column(
                children: [
                  // Aquí está el TextField de búsqueda fuera del CustomScrollView
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: editingController,
                      decoration: const InputDecoration(
                        labelText: "Buscar",
                        hintText: "Buscar",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) async {
                        await filterSearch(value, setState);
                      },
                    ),
                  ),
                  // Aquí está el CustomScrollView
                  Expanded(
                    child: filteredValores.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Scrollbar(
                            thickness: 10.0,
                            radius: const Radius.circular(8.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredValores.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 4,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      buscarProducto("", filteredValores[index]["codProducto"]);
                                    },
                                    title: Text(filteredValores[index]['producto'] ?? filteredValores[index]['Descripcion']),
                                    trailing: const Icon(
                                      Icons.send,
                                      color: Colores.esquemaColor,
                                    ),
                                  ),
                                );
                              },
                            ),
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
                )
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> filterSearch(String query, StateSetter setState) async {
    List<Map<String, dynamic>> tempList = [];
    if (query.isNotEmpty) {
      for (var item in filteredValores) {
        String descripcion = item['producto'] ?? item['Descripcion'];
        if (descripcion.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(item);
        }
      }
      setState(() {
        filteredValores = tempList;
      });
    } else {
      setState(() {
        filteredValores = List.from(valores); // Restaura la lista original si no hay filtro
      });
    }
  }

  List<int?> obtenerLotesSeleccionadosSin(int? excluido) {
    return loteSeleccionados.where((lote) => lote != excluido).toList();
  }

  void mostrarAlertaEdicion(
      BuildContext context, String loteActual, String codLote, String fecha, CargosPendientes cargos, int codProducto, Function onUpdated) {
    TextEditingController _controller = TextEditingController(text: loteActual);
    TextEditingController _controllerFecha = TextEditingController(text: fecha);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("Editar lote"),
          content: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Lote",
                  hintText: "Ingresa el nuevo valor del lote",
                ),
              ),
              TextField(
                controller: _controllerFecha,
                decoration: const InputDecoration(
                  labelText: "Fecha",
                  hintText: "Ingresar la nueva fecha",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Guardar"),
              onPressed: () async {
                String nuevoLote = _controller.text;
                String nuevaFecha = _controllerFecha.text;
                // Actualizar el lote directamente en datos.lotes usando Cod_Lote
                if (nuevoLote != "" || nuevaFecha != "") {
                  for (var lote in datos!.lotes) {
                    if (lote['Cod_Lote'].toString() == codLote) {
                      lote['lotes'] = nuevoLote;
                      lote['Fecha_Vencimiento'] = nuevaFecha;
                      break;
                    }
                  }
                  for (var lote in datos!.lotesSeleccionados) {
                    if (lote['Cod_Lote'].toString() == codLote) {
                      lote['lotes'] = nuevoLote;
                      lote['Fecha_Vencimiento'] = nuevaFecha;
                      break;
                    }
                  }

                  // Actualizar el lote directamente en datos.loteslist usando Cod_Lote
                  for (var lote in datos!.loteslist) {
                    if (lote['Cod_Lote'].toString() == codLote) {
                      lote['lotes'] = nuevoLote;
                      lote['Fecha_Vencimiento'] = nuevaFecha;
                      break;
                    }
                  }

                  //await dbHelper.updateLote(nuevoLote, nuevaFecha, codLote, codProducto);

                  onUpdated();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<int?>>? generarBodegasDistribucion(
      List<dynamic> dato, BuildContext context, CargosPendientes cargos, int codProducto, int? loteExcluido) {
    List<int?> lotesUsados = obtenerLotesSeleccionadosSin(loteExcluido);
    List<DropdownMenuItem<int?>>? listadoBodegasDistribucion = [];

    for (var elemento in dato) {
      int? codLote = elemento["Cod_Lote"] != null ? int.parse(elemento["Cod_Lote"].toString()) : null; // Puede ser null

      if (!lotesUsados.contains(codLote)) {
        listadoBodegasDistribucion.add(
          DropdownMenuItem(
            value: codLote, // Este puede ser null
            child: GestureDetector(
              onLongPress: () {
                mostrarAlertaEdicion(
                    context,
                    elemento["lotes"].toString(),
                    elemento["Cod_Lote"]?.toString() ?? "", // Usamos el operador ?. para manejar null
                    elemento["Fecha_Vencimiento"].toString(),
                    cargos,
                    codProducto, () {
                  setState(() {});
                });
              },
              child: Text(elemento["lotes"].toString()),
            ),
          ),
        );
      }
    }
    return listadoBodegasDistribucion;
  }

  Widget adicional(CargosPendientes cargos, BuildContext context) {
    late int totalLotesDisponibles;

    var lotesParaMapear = cargos.lotesSeleccionados.isNotEmpty ? cargos.lotesSeleccionados : cargos.lotes;

    bool habilita = false;
    // print("aqui estoy ");
    loteSeleccionados = List<int?>.from(List.filled(lotesParaMapear.length, null, growable: true));
    if (loteSeleccionados.isEmpty) {
      loteSeleccionados = List<int?>.from(List.filled(lotesParaMapear.length, null, growable: true));
      if (lotesParaMapear.length == 1) {
        loteSeleccionados[0] = lotesParaMapear[0]['Cod_Lote'];
        selectedRow = 0;
        escaneer2();
      }
    }
    // Inicialización de loteSeleccionados con valores actuales si son null
    for (int i = 0; i < lotesParaMapear.length; i++) {
      if (loteSeleccionados[i] == null) {
        loteSeleccionados[i] = lotesParaMapear[i]['Cod_Lote'];
      }
    }

    lotesCombinados.clear();
    lotesCombinados.addAll(cargos.loteslist);
    for (var loteOriginal in lotesParaMapear) {
      if (!lotesCombinados.any((lote) => lote['Cod_Lote'] == loteOriginal['Cod_Lote'])) {
        lotesCombinados.add(loteOriginal);
      }
      //print(loteOriginal["Cantidad"]);
      if (loteOriginal["Cantidad"] != null) {
        loteSeleccionados.add(loteOriginal['Cod_Lote']);
        dropdownValues.add(loteOriginal['Destino']);

        TextEditingController controller = TextEditingController();
        controller.text = loteOriginal['Cantidad'].toString();
        cantidadControllers.add(controller);
      }
    }
    for (int i = 0; i < lotesParaMapear.length; i++) {
      cantidadControllers.add(TextEditingController());
    }
    for (int i = 0; i < lotesParaMapear.length; i++) {
      dropdownValues.add(1); // O puedes inicializarlo con un valor por defecto si es necesario
    }
    totalLotesDisponibles = lotesCombinados.length;
    //}

    // Comprueba si todos los lotes ya han sido seleccionados
    bool todosLosLotesSeleccionados = loteSeleccionados.length >= totalLotesDisponibles;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 14.0,
                    columns: [
                      DataColumn(label: Container(padding: const EdgeInsets.only(left: 0.0), child: const Text("Check"))),
                      const DataColumn(label: Text("Lote")),
                      const DataColumn(label: Text("Caduca")),
                      const DataColumn(label: Text("Cantidad")),
                      const DataColumn(label: Text("Destino")),
                    ],
                    rows: [
                      ...lotesParaMapear.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var loteObj = entry.value;
                        bool isEnabled = selectedRow == idx;
                        habilita = selectedRow == idx;
                        return DataRow(
                          selected: isEnabled,
                          cells: [
                            DataCell(Checkbox(
                              shape: const CircleBorder(),
                              value: isEnabled,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedRow = idx;
                                    escaneer2();
                                  } else {
                                    selectedRow = null;
                                  }
                                });
                              },
                            )),
                            DataCell(
                              DropdownButton<int?>(
                                value: loteSeleccionados[idx] ??
                                    (lotesParaMapear[idx]['Cod_Lote'] != null ? int.parse(lotesParaMapear[idx]['Cod_Lote']) : null),
                                items: generarBodegasDistribucion(
                                    lotesCombinados,
                                    context,
                                    cargos,
                                    cargos.codProducto,
                                    loteSeleccionados[idx] ??
                                        (lotesParaMapear[idx]['Cod_Lote'] != null ? int.parse(lotesParaMapear[idx]['Cod_Lote']) : null)),
                                onChanged: isEnabled
                                    ? (int? value) {
                                        var loteElegido;

                                        setState(() {
                                          loteSeleccionados[idx] = value; // Actualiza el valor en la lista
                                          if (value != null) {
                                            loteElegido = lotesCombinados.firstWhere((lote) => lote['Cod_Lote'] == value, orElse: () => {});
                                            loteObj['Cod_Lote'] = loteElegido['Cod_Lote'];
                                            loteObj['lotes'] = loteElegido['lotes'];
                                            loteObj['Fecha_Vencimiento'] = loteElegido['Fecha_Vencimiento']; // Esta línea actualiza la fecha
                                          } else {
                                            loteObj['Cod_Lote'] = null;
                                            loteObj['lotes'] = null;
                                            loteObj['Fecha_Vencimiento'] = null;
                                          }
                                        });
                                        DateTime currentDate = DateTime.now();
                                        int currentYear = currentDate.year;
                                        int currentMonth = currentDate.month;

                                        int monthLimit;
                                        int yearLimit;
                                        int targetMonth = (currentMonth - 1 - 1 + 12) % 12 + 1;
                                        int targetYear = currentYear + ((currentMonth - 1 - 1) ~/ 12);

                                        switch (datos!.valorPolitica) {
                                          case 'Mismo mes':
                                            // Añade 2 meses al mes actual para obtener el mes límite
                                            monthLimit = (currentMonth + 2 - 1) % 12 + 1;
                                            yearLimit = currentYear + ((currentMonth + 2 - 1) ~/ 12);
                                            break;

                                          case '0':
                                            // Añade 3 meses al mes actual para obtener el mes límite
                                            monthLimit = (currentMonth + 3 - 1) % 12 + 1;
                                            yearLimit = currentYear + ((currentMonth + 3 - 1) ~/ 12);
                                            break;

                                          case '1':
                                            // Añade 4 meses al mes actual para obtener el mes límite
                                            monthLimit = (currentMonth + 4 - 1) % 12 + 1;
                                            yearLimit = currentYear + ((currentMonth + 4 - 1) ~/ 12);
                                            break;

                                          case '2':
                                            // Añade 5 meses al mes actual para obtener el mes límite
                                            monthLimit = (currentMonth + 5 - 1) % 12 + 1;
                                            yearLimit = currentYear + ((currentMonth + 5 - 1) ~/ 12);
                                            break;

                                          case '3':
                                            // Añade 6 meses al mes actual para obtener el mes límite
                                            monthLimit = (currentMonth + 6 - 1) % 12 + 1;
                                            yearLimit = currentYear + ((currentMonth + 6 - 1) ~/ 12);
                                            break;

                                          case '4':
                                            // Añade 7 meses al mes actual para obtener el mes límite
                                            monthLimit = (currentMonth + 7 - 1) % 12 + 1;
                                            yearLimit = currentYear + ((currentMonth + 7 - 1) ~/ 12);
                                            break;

                                          case '5':
                                            // Añade 8 meses al mes actual para obtener el mes límite
                                            monthLimit = (currentMonth + 8 - 1) % 12 + 1;
                                            yearLimit = currentYear + ((currentMonth + 8 - 1) ~/ 12);
                                            break;

                                          case '6':
                                            // Añade 9 meses al mes actual para obtener el mes límite
                                            monthLimit = (currentMonth + 9 - 1) % 12 + 1;
                                            yearLimit = currentYear + ((currentMonth + 9 - 1) ~/ 12);
                                            break;

                                          default:
                                            return; // Salir del método si la política es desconocida
                                        }

                                        // Verificar cada lote

                                        // var dato = datos!.lotes.isNotEmpty ? datos!.lotes : datos!.loteslist;
                                        if (loteElegido.isNotEmpty) {
                                          DateTime fechaVencimiento = DateTime.parse(loteElegido['Fecha_Vencimiento']);
                                          DateTime fechaVencimientoMinusOneMonth = DateTime(
                                            fechaVencimiento.year,
                                            fechaVencimiento.month - 1,
                                            fechaVencimiento.day,
                                          );

                                          if (fechaVencimiento.year < yearLimit ||
                                              (fechaVencimiento.year == yearLimit && fechaVencimiento.month < monthLimit)) {
                                            setState(() {
                                              dropdownValues[idx] = 2;
                                            });
                                            Fluttertoast.showToast(
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              msg: "El lote: ${loteElegido["lotes"]} se encuentra caducado",
                                              gravity: ToastGravity.BOTTOM,
                                              toastLength: Toast.LENGTH_SHORT,
                                            );
                                          } else {
                                            setState(() {
                                              dropdownValues[idx] = 1;
                                            });
                                          }
                                          if (fechaVencimientoMinusOneMonth.isBefore(currentDate)) {
                                            setState(() {
                                              dropdownValues[idx] = 5;
                                            });
                                          }
                                        }
                                      }
                                    : null,
                              ),
                            ),
                            DataCell(Text(loteObj['Fecha_Vencimiento'] ?? "")),
                            DataCell(TextFormField(
                                enabled: isEnabled,
                                controller: cantidadControllers[idx],
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly, // sólo permite dígitos
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Error';
                                  }
                                  if (int.parse(value) < 0) {
                                    return 'Error';
                                  }
                                  return null;
                                })),
                            DataCell(
                              DropdownButton<int>(
                                value: dropdownValues[idx],
                                items: [
                                  const DropdownMenuItem<int>(value: 1, child: Text("Distribución")),
                                  const DropdownMenuItem<int>(value: 2, child: Text("Devolución")),
                                  const DropdownMenuItem<int>(value: 3, child: Text("Mal estado")),
                                  const DropdownMenuItem<int>(value: 4, child: Text("Cobro mal estado")),
                                  const DropdownMenuItem<int>(value: 5, child: Text("Cobro caducado")),
                                  const DropdownMenuItem<int>(value: 6, child: Text("Por aprobación")),
                                ],
                                onChanged: isEnabled
                                    ? (int? value) {
                                        setState(() {
                                          dropdownValues[idx] = value; // Actualiza el valor para esta fila
                                        });
                                      }
                                    : null,
                                hint: const Text("Seleccione"),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                if (!todosLosLotesSeleccionados)
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    color: Colores.esquemaColor,
                                    onPressed: () {
                                      setState(() {
                                        lotesParaMapear.add(<String, dynamic>{});

                                        loteSeleccionados.add(null);
                                      });
                                    },
                                  ),
                                // Solo muestra el botón remove_circle si hay una fila seleccionada
                              ],
                            ),
                          ),
                          DataCell(
                            IconButton(
                                icon: const Icon(Icons.remove_circle),
                                color: Colores.esquemaColor,
                                onPressed: habilita
                                    ? () {
                                        setState(() {
                                          lotesParaMapear.removeAt(selectedRow!);
                                          cargos.loteslist.removeAt(selectedRow!); // Elimina la fila seleccionada de cargos.lotes
                                          loteSeleccionados.removeAt(selectedRow!); // Elimina el valor seleccionado de loteSeleccionados
                                          selectedRow = null; // Establece la fila seleccionada en null
                                        });
                                      }
                                    : null),
                          ),
                          const DataCell(Text("")),
                          const DataCell(Text("")),
                          const DataCell(Text("")),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: () async {
                    List<Map<String, dynamic>> lotesSeleccionados = [];

                    // Usamos la longitud de cargos.lotes como la base
                    if (_formKey.currentState!.validate()) {
                      // Si el Form es válido, muestra un snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Procesando Datos'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      for (int i = 0; i < lotesParaMapear.length; i++) {
                        var loteActual = lotesParaMapear[i];
                        int? codLoteSeleccionado = (i < loteSeleccionados.length) ? loteSeleccionados[i] : null;

                        if (codLoteSeleccionado != null) {
                          Map<String, dynamic> lote = {
                            'Cod_Lote': codLoteSeleccionado,
                            'lotes': loteActual['lotes'],
                            'Fecha_Vencimiento': loteActual['Fecha_Vencimiento'],
                            'Cantidad': int.parse(cantidadControllers[i].text), // Aquí recogemos el valor real
                            'Destino': dropdownValues[i] // Aquí debes poner el valor real
                          };
                          lotesSeleccionados.add(lote);
                        }
                      }
                    }

                    setearvalores();
                    await recargarDatos();
                    await dbHelper.updateColumnLotesSeleccionados(cargos.codProducto, jsonEncode(lotesSeleccionados));
                  },
                  label: const Text("Guardar producto"),
                  icon: const Icon(Icons.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> recargarDatos() async {
    cargosss.clear();
    lotesCombinados.clear();
    loteSeleccionados.clear();
    filasAdicionales.clear();

    final dbHelper = DatabaseHelper();
    /*var dato = await dbHelper.getAllProductos("0");
    if (dato.isEmpty) {
      await Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const Home()), (Route<dynamic> route) => false);
    }
    producto = await dbHelper.getAllProductos2();*/

    /* if (producto.isEmpty) {
      await Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const NovedadesInventario()), (Route<dynamic> route) => false);
    } else {*/
    dataInicial(false);
    //}
  }

  Future<void> setearvalores() async {
    await fdwListener!.cancel();
    await fdwListener2!.cancel();
    setState(() {
      selectedRow = null;
      validacionInicial = false;
      cantidadControllers.clear();
      filasAdicionales.clear();
      dropdownValues.clear();
      editingController.text = "";
      cantidadCajas = 0;
      validacionInicial = false;
      nuevaVerificacion = false;
    });
  }

  Widget circularPrimero() {
    return StreamBuilder<double>(
        stream: _progressController.stream,
        initialData: 0.0,
        builder: (context, snapshot) {
          final progresses = snapshot.data ?? 0.0;
          return SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        strokeWidth: 13.0,
                        value: progresses,
                        color: const Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                    Text('${(progresses * 100).toStringAsFixed(0)}%'),
                  ],
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Cargando orden, por favor espere...",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();

    dataInicial(true);
  }

  @override
  void dispose() {
    _progressController.close();

    super.dispose();
  }

  Future<void> dataInicial(bool noti) async {
    var dato = await _storage.readSecureData("cod_cargo_recepcion");
    var impreso = await _storage.readSecureData("validacion");
    /*cargosss = await dbHelper.getAllProductos("");
    for (var a = 0; a < cargosss.length; a++) {
      print(cargosss[a]);
    }*/

    if (impreso != null) {
      var rawJsonCobro = await _storage.readSecureData("jsonCobros") ?? '[]';
      var rawJsonPorAprobacion = await _storage.readSecureData("jsonporaprobar") ?? '[]';
      var rawJsonDetalle = await _storage.readSecureData("jsonDetalle") ?? '[]';
      var rawJsonDetalleCaducado = await _storage.readSecureData("jsonDetalleCaducados") ?? '[]';
      //var rawJsonMalEstado = await _storage.readSecureData("jsonMalEstado") ?? '[]';
      String codCargoPendiente = await _storage.readSecureData("codCargoPendiente");
      String codBodega = await _storage.readSecureData("codigoBodega");

      List<Map<String, dynamic>> decodedJsonCobro = (jsonDecode(rawJsonCobro) as List).cast<Map<String, dynamic>>();
      List<Map<String, dynamic>> decodedJsonAprobacion = (jsonDecode(rawJsonPorAprobacion) as List).cast<Map<String, dynamic>>();
      List<Map<String, dynamic>> decodedJsonDetalle = (jsonDecode(rawJsonDetalle) as List).cast<Map<String, dynamic>>();
      List<Map<String, dynamic>> decodedJsonDetalleCaducado = (jsonDecode(rawJsonDetalleCaducado) as List).cast<Map<String, dynamic>>();
      //List<dynamic> decodedJsonMalEstado = jsonDecode(rawJsonMalEstado);

      if (decodedJsonCobro.isEmpty &&
              decodedJsonDetalle.isEmpty &&
              decodedJsonDetalleCaducado.isEmpty &&
              decodedJsonAprobacion.isEmpty /*&&
          decodedJsonMalEstado.isEmpty*/
          ) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // El usuario debe tocar un botón para cerrar el cuadro de diálogo.
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No hay datos para imprimir'),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('¿Finalizar?'),
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
      } else {
        await imprimir(
            decodedJsonCobro,
            decodedJsonDetalle,
            decodedJsonDetalleCaducado,
            //  decodedJsonMalEstado,
            codCargoPendiente,
            int.parse(codBodega),
            decodedJsonAprobacion);
      }
    } else {
      if (dato == null) {
        await dbHelper.deleteTable();
        token = await _storage.readSecureData("token");
        await _showAlertDialogTipoTransferencia(context, "Número de orden", token);
        final totalItem = cargosss.length;
        for (int i = 0; i < cargosss.length; i++) {
          await dbHelper.insert(cargosss[i]);
          final progress = (i + 1) / totalItem;
          _progressController.sink.add(progress);
        }
        _progressController.sink.add(1.0);
        setState(() {
          validacion = true;
        });

        iniciarScanner();
      } else {
        setState(() {
          validacion = true;
        });
        cargosss = await dbHelper.getAllProductos("");
        setState(() {
          valores = CargosPendientes.convertirAlistaEspecial(cargosss);
        });

        iniciarScanner();
        if (noti) {
          await ArtSweetAlert.show(
              barrierDismissible: false,
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.info,
                  title: "Pedido restaurado!!!",
                  text: "Usted tiene una recepción pendiente",
                  confirmButtonText: "Aceptar",
                  onConfirm: () async {
                    Navigator.pop(context);
                  },
                  confirmButtonColor: Colores.esquemaColor));
        }
      }
    }
  }

  void iniciarScanner() async {
    if (Platform.isAndroid) {
      fdwListener = fdw.onScanResult.listen((code) async {
        final codBarra = code.data.toString().trim();

        await buscarProducto(codBarra, 0);
      });
    }
  }

  Future<void> escaneer2() async {
    await fdwListener?.cancel();
    await fdwListener2?.cancel(); // Cancela cualquier escuchador previo
    final ordenes = datos;
    //print(ordenes);
    fdwListener2 = fdw2.onScanResult.listen((code) async {
      final codBarra = code.data.toString().trim();
      if (ordenes!.codBarra.trim() == codBarra || ordenes.codBarra.contains(codBarra)) {
        if (selectedRow != null) {
          TextEditingController controller = cantidadControllers[selectedRow!];
          int currentValue = int.tryParse(controller.text) ?? 0;
          currentValue++; // Incrementa el valor
          controller.text = currentValue.toString(); // Actualiza el controlador del TextField
          setState(() {}); // Re-renderiza el widget
        }
      } else {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: "El producto escaneado no es correcto",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );

        sounidoErrorProducto();
      }

      // Solo incrementa la cantidad si hay una fila seleccionada
    });
  }

  Future<void> sounidoErrorProducto() async {
    Soundpool pool = Soundpool.fromOptions(options: const SoundpoolOptions(streamType: StreamType.notification));

    int soundId = await rootBundle.load("assets/sonidos/producto.mp3").then((ByteData soundData) {
      return pool.load(soundData);
    });
    int streamId = await pool.play(soundId);
  }

  final notFound = CargosPendientes(
      codBarra: 'NOT_FOUND',
      codProducto: -1,
      descripcion: 'NOT_FOUND',
      cantidad: -1,
      fraccion: -1,
      costo: -1.0,
      parcial: -1.0,
      cantReal: -1,
      codBodega: -1,
      costoVenta: -1.0,
      documento: 'NOT_FOUND',
      fecha: DateTime.now(),
      observacion: 'NOT_FOUND',
      total: -1.0,
      siglas: 'NOT_FOUND',
      productoIva: 'NOT_FOUND',
      codBarraAdicional: [],
      lotes: [],
      loteslist: [],
      lotesSeleccionados: [],
      politica: "",
      valorPolitica: "",
      cajasEscaneadas: 0,
      precioPublico: 0.0);

  Future<void> buscarProducto(String codigoBarra, int codProductos) async {
    /* CargosPendientes productoEncontradoTemp = cargosss.firstWhere(
        (ordenes) => (ordenes.codBarra == codigoBarra || ordenes.codBarraAdicional.contains(codigoBarra) || ordenes.codProducto == codProductos),
        orElse: () => notFound);*/
    late CargosPendientes productoEncontradoTemp;
    if (codigoBarra != "") {
      productoEncontradoTemp = cargosss.firstWhere((ordenes) => (ordenes.codBarra == codigoBarra || ordenes.codBarraAdicional.contains(codigoBarra)),
          orElse: () => notFound // devuelve el producto ficticio si no se encuentra ningún producto
          );
    } else {
      productoEncontradoTemp = cargosss.firstWhere((ordenes) => (ordenes.codProducto == codProductos),
          orElse: () => notFound // devuelve el producto ficticio si no se encuentra ningún producto
          );
    }

    if (productoEncontradoTemp.codBarra != 'NOT_FOUND') {
      setState(() {
        datos = productoEncontradoTemp;
        validacionInicial = true;
        nuevaVerificacion = true;
      });

      if (datos != null) {
        DateTime currentDate = DateTime.now();
        int currentYear = currentDate.year;
        int currentMonth = currentDate.month;

        int monthLimit;
        int yearLimit;

        switch (datos!.valorPolitica) {
          case 'Mismo mes':
            // Añade 2 meses al mes actual para obtener el mes límite
            monthLimit = (currentMonth + 2 - 1) % 12 + 1;
            yearLimit = currentYear + ((currentMonth + 2 - 1) ~/ 12);
            break;

          case '0':
            // Añade 3 meses al mes actual para obtener el mes límite
            monthLimit = (currentMonth + 3 - 1) % 12 + 1;
            yearLimit = currentYear + ((currentMonth + 3 - 1) ~/ 12);
            break;

          case '1':
            // Añade 4 meses al mes actual para obtener el mes límite
            monthLimit = (currentMonth + 4 - 1) % 12 + 1;
            yearLimit = currentYear + ((currentMonth + 4 - 1) ~/ 12);
            break;

          case '2':
            // Añade 5 meses al mes actual para obtener el mes límite
            monthLimit = (currentMonth + 5 - 1) % 12 + 1;
            yearLimit = currentYear + ((currentMonth + 5 - 1) ~/ 12);
            break;

          case '3':
            // Añade 6 meses al mes actual para obtener el mes límite
            monthLimit = (currentMonth + 6 - 1) % 12 + 1;
            yearLimit = currentYear + ((currentMonth + 6 - 1) ~/ 12);
            break;

          case '4':
            // Añade 7 meses al mes actual para obtener el mes límite
            monthLimit = (currentMonth + 7 - 1) % 12 + 1;
            yearLimit = currentYear + ((currentMonth + 7 - 1) ~/ 12);
            break;

          case '5':
            // Añade 8 meses al mes actual para obtener el mes límite
            monthLimit = (currentMonth + 8 - 1) % 12 + 1;
            yearLimit = currentYear + ((currentMonth + 8 - 1) ~/ 12);
            break;

          case '6':
            // Añade 9 meses al mes actual para obtener el mes límite
            monthLimit = (currentMonth + 9 - 1) % 12 + 1;
            yearLimit = currentYear + ((currentMonth + 9 - 1) ~/ 12);
            break;

          default:
            return; // Salir del método si la política es desconocida
        }

        // Verificar cada lote

        // var dato = datos!.lotes.isNotEmpty ? datos!.lotes : datos!.loteslist;
        for (var lote in datos!.lotes.isNotEmpty ? datos!.lotes : datos!.loteslist) {
          DateTime fechaVencimiento = DateTime.parse(lote['Fecha_Vencimiento']);
          if (fechaVencimiento.year < yearLimit || (fechaVencimiento.year == yearLimit && fechaVencimiento.month < monthLimit)) {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: "El lote: ${lote["lotes"]} se encuentra con novedad",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
            );
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              msg: "Producto con lotes sin novedades",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        }
      }
      //procesarCodBarra(codigoBarra);
    } else {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Este producto ya fué agregado anteriormente o no pertenece a esta orden",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<Widget> _showAlertDialogTipoTransferencia(BuildContext context, String titulo, String token) async {
    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
              title: Text(titulo),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: editingController,
                      decoration: const InputDecoration(
                        labelText: "Número de orden",
                        hintText: "Ingrese el número de la orden",
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
                  onPressed: () async {
                    await Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const Home(),
                      ),
                      (route) => false,
                    );
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
                        var datos = await obtenerCargos(token, int.parse(editingController.text));

                        cargosss = parseCargos(datos.body);
                        await _storage.writeSecureData("cod_cargo_recepcion", editingController.text);
                        Navigator.pop(context);
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
        });
      },
    );
    return const SizedBox(); //Aquí se devuelve un SizedBox como valor por defecto, se puede cambiar por otro Widget si se desea.
  }
}
