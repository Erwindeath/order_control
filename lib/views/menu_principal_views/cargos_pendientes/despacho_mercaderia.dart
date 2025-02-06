// ignore_for_file: must_be_immutable, non_constant_identifier_names, unused_local_variable, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/cargos_pendientes/complements/clase.dart';
import 'package:order_control/views/menu_principal_views/cargos_pendientes/complements/claseSonido.dart';
import 'package:order_control/views/menu_principal_views/cargos_pendientes/complements/logica.dart';
import 'package:order_control/views/menu_principal_views/cargos_pendientes/complements/provider.dart';
import 'package:order_control/views/menu_principal_views/cargos_pendientes/complements/sqlite.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'complements/enviando.dart';

class DespachoMercaderias extends ConsumerStatefulWidget {
  Response? data;
  final int codCargo;
  final String fecha;
  final String farmacia;
  final String observacion;
  final String token;
  DespachoMercaderias(
      {this.data, required this.codCargo, required this.fecha, required this.farmacia, required this.observacion, required this.token, Key? key})
      : super(key: key);

  @override
  ConsumerState<DespachoMercaderias> createState() => _DespachoMercaderiaState();
}

class _DespachoMercaderiaState extends ConsumerState<DespachoMercaderias> {
  final StreamController<double> _progressController = StreamController();
  final SoundManager soundManager = SoundManager();
  StreamSubscription<dynamic>? fdwListener;
  final SecureStorage _storage = SecureStorage();
  final TextEditingController bultosControler = TextEditingController();
  var fdw = FlutterDataWedge(profileName: 'FlutterDataWedge');
  int? highlightedIndex;
  ScrollController scrollController = ScrollController();
  final dbHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(enviando);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.farmacia,
          style: const TextStyle(fontSize: 16.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const Home(),
              ),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: !isLoading && ref.watch(despachoMercaderiaProvider).isNotEmpty
                  ? () async {
                      alertaNovedades(context, "Productos con novedades");
                    }
                  : null,
              icon: const Icon(Icons.save))
        ],
      ),
      body: Stack(
        children: <Widget>[
          datos(),
          if (isLoading)
            const CargandoEnvio(
              texto: 'Enviando datos, por favor espere.',
              colorTexto: Colores.esquemaColor,
              width: 300.0,
              height: 300.0,
              tamanoTexto: 14,
            )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadSounds();
    Future.microtask(() async {
      if (mounted) {
        ref.read(despachoMercaderiaProvider.notifier).setData([]);
        await datosIniciales();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    fdwListener?.cancel();
    _progressController.close();
    soundManager.dispose();
    super.dispose();
  }

  void loadSounds() async {
    try {
      await soundManager.loadSound("assets/sonidos/producto.mp3");
      await soundManager.loadSound("assets/sonidos/errorcantidades.mp3");
    } catch (e) {
      // Manejar error de carga de sonidos
      ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "$e",
              confirmButtonText: "Aceptar",
              text: "Comuníquese con el administrador",
              confirmButtonColor: Colores.esquemaColor));
    }
  }

  Future<void> datosIniciales() async {
    try {
      var codigoMovimientoDato = await _storage.readSecureData("codigoMovimiento") ?? "";

      if (codigoMovimientoDato != "") {
        final image = img.Image(200, 100);
        img.fill(image, img.getColor(255, 255, 255));
        drawBarcode(image, Barcode.code128(), codigoMovimientoDato);
        final png = img.encodePng(image);
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/barcode_$codigoMovimientoDato.jpg';
        final file = await File(filePath).writeAsBytes(png);
        await finalizado(context, codigoMovimientoDato, file);
      } else {
        await _storage.deleteSecureData("codigoMovimiento");
        var dato = await dbHelper.getAllProductos();
        ref.read(validaProvider.notifier).state = false;
        ref.read(validaProviderSegundo.notifier).state = false;
        if (dato.isNotEmpty) {
          ref.read(validaProvider.notifier).state = true;
          var valor = await dbHelper.getAllProductos2();
          ref.read(despachoMercaderiaProvider.notifier).setData(valor);
          ref.read(validaProviderSegundo.notifier).state = true;
          iniciarScanner(valor);
        } else {
          ref.read(validaProviderSegundo.notifier).state = true;
          await dbHelper.deleteTable();
          ref.read(despachoMercaderiaProvider.notifier).setData(parseOrdernesPendientes(widget.data!.body));
          final reportItems = ref.watch(despachoMercaderiaProvider);

          final totalItem = reportItems.length;
          for (int i = 0; i < reportItems.length; i++) {
            await dbHelper.insert(reportItems[i]);
            final progress = (i + 1) / totalItem;
            _progressController.sink.add(progress);
          }
          _progressController.sink.add(1.0);
          ref.read(validaProvider.notifier).state = true;
          iniciarScanner(reportItems);
        }
      }
    } catch (e) {
      ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error al obtener los datos: $e",
              confirmButtonText: "Aceptar",
              text: "Comuníquese con el administrador",
              confirmButtonColor: Colores.esquemaColor));
    }
  }

  Widget datos() {
    final valida = ref.watch(validaProvider);
    final valida2 = ref.watch(validaProviderSegundo);
    if (valida == false) {
      return circularPrimero();
    } else if (valida2 == false) {
      return circularSegundo();
    } else {
      return Column(
        children: [
          info(),
          Expanded(child: tablaPrincipal()), // Ahora `Expanded` está dentro de `Column`
          total() // Este widget muestra el total sin ser `Expanded`
        ],
      );
    }
  }

  Widget info() {
    return SizedBox(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Icon(
                          Icons.info,
                          color: Colors.blue,
                        ),
                      ),
                      Text(widget.observacion, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                    ],
                  ),
                  Text(
                    "COD: ${widget.codCargo}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget tablaPrincipal() {
    final reportItems = ref.watch(despachoMercaderiaProvider);
    return SingleChildScrollView(
      controller: scrollController, // Usa el controlador aquí

      scrollDirection: Axis.vertical,
      child: Card(
        child: DataTable(
          columnSpacing: 15,
          showBottomBorder: true,
          headingRowHeight: 40,
          dataRowMaxHeight: 50,
          columns: const [
            DataColumn(label: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('LAB', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Unid', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(reportItems.length, (index) {
            final item = reportItems[index];
            return DataRow(cells: [
              DataCell(SizedBox(
                width: 200,
                child: Text(
                  item.producto,
                  softWrap: true,
                  style: TextStyle(
                    color: index == highlightedIndex ? Colors.white : (item.cantUnidadFinal > 0 ? Colors.green : Colors.black),
                    backgroundColor: index == highlightedIndex ? Colors.blue : Colors.transparent,
                  ),
                ),
              )),
              DataCell(Text(item.siglas.toString())),
              DataCell(TextFormField(
                //initialValue: item.cantUnidadFinal.toString(),
                readOnly: true,
                controller: item.controller,
                //enabled: item.codTipo != "02",
                /*onFieldSubmitted: (value) {
                  ref.read(despachoMercaderiaProvider.notifier).updateUnidad(index, int.parse(value), ref);
                },*/
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
              )),
            ]);
          }),
        ),
      ),
    );
  }

  Widget total() {
    final reportItems = ref.watch(despachoMercaderiaProvider);

    int totalItems = reportItems.length;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Items",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Tiempo",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(totalItems.toString()), Text(ref.watch(tiempoTranscurridoProvider(widget.fecha)))],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void iniciarScanner(List<DespachoMercaderia> reportItems) async {
    int? lastScannedIndex;
    if (Platform.isAndroid) {
      fdwListener = fdw.onScanResult.listen((code) async {
        final codBarra = code.data.toString().trim();
        int index = reportItems.indexWhere((item) => item.codBarra == codBarra);
        if (index != -1) {
          if (reportItems[index].cantUnidad > reportItems[index].cantUnidadFinal) {
            int nuevaCantidad = reportItems[index].cantUnidadFinal + 1;
            // Actualiza la cantidad en el StateNotifier
            ref.read(despachoMercaderiaProvider.notifier).updateUnidad(index, nuevaCantidad, ref);
          } else {
            soundManager.playSoundWithVibration("assets/sonidos/errorcantidades.mp3");
            Fluttertoast.showToast(
              msg: "No puede ingresar más Cantidades de la Transferencia Original",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_LONG,
            );
          }
          if (lastScannedIndex == null || lastScannedIndex != index) {
            // Resaltar solo si el producto es diferente al último escaneado
            double scrollPosition = index * 50.0; // Asumiendo una altura de fila de 50.0
            scrollController.animateTo(
              scrollPosition,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            setState(() {
              highlightedIndex = index;
              // Actualizar el último índice escaneado
            });
            lastScannedIndex = index;
          }
        } else {
          soundManager.playSoundWithVibration("assets/sonidos/producto.mp3");
          Fluttertoast.showToast(
            msg: "Producto no encontrado",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          setState(() {
            highlightedIndex = null;
          });
          lastScannedIndex = null;
        }
      });
    }
  }

  Future<void> alertaNovedades(BuildContext context, String titulo) async {
    final reportItems = ref.read(despachoMercaderiaProvider).where((item) => item.cantUnidad != item.cantUnidadFinal).toList();

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
                  // Aquí está el CustomScrollView
                  Expanded(
                    child: reportItems.isEmpty
                        ? const Center(child: Text("Sin novedad de productos en esta transferencia"))
                        : Scrollbar(
                            thickness: 10.0,
                            radius: const Radius.circular(8.0),
                            child: CustomScrollView(
                              slivers: <Widget>[
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return Card(
                                        elevation: 4,
                                        child: InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                /*Icon(
                                                  Icons.check_box,
                                                  color: filteredValores[index]["estado"] > 0 ? Colors.blue : Colors.grey,
                                                  size: 24.0,
                                                ),*/
                                                Expanded(
                                                  child: Text(
                                                    reportItems[index].producto,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Text((reportItems[index].cantUnidad - reportItems[index].cantUnidadFinal).toString())
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: reportItems.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('CORREGIR'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('GRABAR'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await packing(context);
                  },
                )
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> packing(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
              scrollable: true,
              title: const Text('¿Está seguro de guardar la transferencia?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No podrá volver atrás!'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      controller: bultosControler,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Boxicons.bx_box,
                            size: 24, // Ajusta el tamaño del ícono según tus necesidades
                            color: Colores.esquemaColor, // Cambia el color del ícono si lo deseas
                          ),
                          labelText: 'Número de bultos',
                          hintText: "Número de bultos"),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    ref.read(enviando.notifier).state = false;
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                    child: const Text('GRABAR'),
                    onPressed: () async {
                      if (bultosControler.text == "") {
                        Fluttertoast.showToast(
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          msg: "Error, ingrese el número de bultos",
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      } else if (int.parse(bultosControler.text) < 1) {
                        Fluttertoast.showToast(
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          msg: "Error, la cantidad de bultos no debe ser menor que 1",
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      } else if (int.parse(bultosControler.text) > 999) {
                        Fluttertoast.showToast(
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          msg: "Error, no puede enviar más de 999 bultos",
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      } else {
                        ref.read(enviando.notifier).state = true;
                        Fluttertoast.showToast(
                          backgroundColor: Colors.orange.shade300,
                          textColor: Colors.white,
                          msg: "Enviando datos, espere por favor...",
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT,
                        );
                        Navigator.of(context).pop();
                        await guardar(bultosControler.text, ref.read(despachoMercaderiaProvider));
                      }
                    }),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> guardar(String bultos, List<DespachoMercaderia> productoss) async {
    var jsonGuardar;
    try {
      final SecureStorage _storage = SecureStorage();

      String codUsuario = await _storage.readSecureData("cod_usuario");

      String codSesion = await _storage.readSecureData("codSesion");

      String valorIva = await _storage.readSecureData("valorIva");

      int valor = int.parse(valorIva);

      final List<Map<String, dynamic>> orders = await dbHelper.getAllOrders();

      List<Map<String, dynamic>> datanueva = await calcularCantidadesFaltantes(productoss);
      int validad = datanueva.isNotEmpty ? 1 : 0;
      List<DespachoMercaderia> ordersWithNonZeroCantReal = [];

      List<DespachoMercaderia> ordersWithNonZeroCantRealNOVA = [];

      double totalCero = 0;

      double totalIva = 0;
      double BaseIva = 0;
      double totalCeroNOVA = 0;

      double totalIvaNOVA = 0;
      double BaseIvaNOVA = 0;

      for (var order in productoss) {
        if (order.cantUnidadFinal > 0) {
          ordersWithNonZeroCantReal.add(order);
        }
      }

      for (var order in productoss) {
        int cantidadFaltante = order.cantUnidad - order.cantUnidadFinal;
        if (cantidadFaltante != 0) {
          ordersWithNonZeroCantRealNOVA.add(order);
        }
      }
      for (var order in ordersWithNonZeroCantReal) {
        double precio = double.parse(order.costo.toString());
        double parcialFinal = double.parse((order.cantUnidadFinal).toString());
        double parcial = precio * parcialFinal;
        double parcial2 = precio * parcialFinal;

        int ivaProducto = order.iva;

        if (ivaProducto == 1) {
          BaseIva += parcial2;
          parcial += (parcial * (valor / 100));
          totalIva += parcial;
        } else {
          totalCero += parcial;
        }
      }

      double valorIvaF = BaseIva * (valor / 100);

      for (var order in ordersWithNonZeroCantRealNOVA) {
        int cantidadFaltante = order.cantUnidad - order.cantUnidadFinal;
        double precio = double.parse(order.costo.toString());
        double parcialFinal = double.parse((cantidadFaltante).toString());
        double parcial = precio * cantidadFaltante;
        double parcial2 = precio * cantidadFaltante;

        int ivaProducto = order.iva;

        if (ivaProducto == 1) {
          BaseIvaNOVA += parcial2;
          parcial += (parcial * (valor / 100));
          totalIvaNOVA += parcial;
        } else {
          totalCeroNOVA += parcial;
        }
      }

      double valorIvaFNOVA = BaseIva * (valor / 100);

      var guardarPedidoFinal = await guardarTransferencia(
          widget.token,
          "guardar_cargo_pendiente",
          30,
          175,
          int.parse(codSesion),
          2000,
          widget.codCargo,
          double.parse(totalCero.toStringAsFixed(4)),
          double.parse(BaseIva.toStringAsFixed(4)),
          double.parse(valorIvaF.toStringAsFixed(4)),
          double.parse((totalCero + BaseIva + valorIvaF).toStringAsFixed(4)),
          double.parse(totalCeroNOVA.toStringAsFixed(4)),
          double.parse(BaseIvaNOVA.toStringAsFixed(4)),
          double.parse(valorIvaFNOVA.toStringAsFixed(4)),
          double.parse((totalCeroNOVA + BaseIvaNOVA + valorIvaFNOVA).toStringAsFixed(4)),
          int.parse(codUsuario),
          ordersWithNonZeroCantReal.map((e) => e.toJson()).toList(),
          int.parse(bultos),
          validad,
          datanueva);
      jsonGuardar = jsonDecode(guardarPedidoFinal.body);

      if (jsonGuardar["msg"] != "err" ||
          jsonGuardar["resultado"][0]["Cod_Impresion2"].toString() != "" ||
          !jsonGuardar["resultado"][0]["Cod_Impresion2"]) {
        ref.read(enviando.notifier).state = false;
        Fluttertoast.showToast(
          backgroundColor: Colors.green,
          textColor: Colors.white,
          msg: "Correcto",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
        var codigoMovimiento = jsonGuardar["resultado"][0]["Cod_Impresion2"].toString();

        final image = img.Image(200, 100);
        img.fill(image, img.getColor(255, 255, 255));
        drawBarcode(image, Barcode.code128(), codigoMovimiento);
        final png = img.encodePng(image);
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/barcode_$codigoMovimiento.jpg';
        final file = await File(filePath).writeAsBytes(png);

        ///finalizado
        await _storage.writeSecureData("codigoMovimiento", jsonGuardar["resultado"][0]["Cod_Impresion2"].toString());
        await finalizado(context, codigoMovimiento, file);
      } else {
        ref.read(enviando.notifier).state = false;
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: "Error, comuníquese con el administrador: $jsonGuardar",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error al obtener los datos: $e",
              confirmButtonText: "Aceptar",
              text: "Comuníquese con el administrador: $jsonGuardar,",
              confirmButtonColor: Colores.esquemaColor));
    }
  }

  Future<List<Map<String, dynamic>>> calcularCantidadesFaltantes(List<DespachoMercaderia> listaOrdenes) async {
    List<Map<String, dynamic>> resultados = [];

    for (var orden in listaOrdenes) {
      int cantidadFaltante = orden.cantUnidad - orden.cantUnidadFinal;

      if (cantidadFaltante != 0) {
        // Solo agregar a la lista si hay una cantidad faltante
        resultados.add({
          'Cod_Producto': orden.codProducto,
          'Producto': orden.producto,
          'Cant_U': cantidadFaltante,
          'Cant_F': 0,
          'Costo': orden.costo,
          'Parcial': double.parse((cantidadFaltante * orden.costo).toStringAsFixed(2)),
          'Fraccion': orden.fraccion,
          'Cant_Real': cantidadFaltante,
        });
      }
    }

    return resultados;
  }

  Future<void> finalizado(BuildContext context, String codMovimiento, File _selectedImage) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
                scrollable: true,
                content: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(
                          child: Text(
                        "Orden terminada!!!",
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colores.esquemaColor),
                      )),
                    ),
                    Image.file(_selectedImage),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(
                          child: Text("Escanee el código generado o ingrese este código: $codMovimiento",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('¿Está seguro de terminar la orden?'),
                              content: const Text('No podrá volver atrás'),
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
                                    final SecureStorage _storage = SecureStorage();
                                    // Aquí puedes agregar la lógica que deseas ejecutar cuando se presiona el botón "Aceptar".
                                    await _storage.deleteSecureData("codigoMovimiento");
                                    await _storage.deleteSecureData("codCargo");
                                    await _storage.deleteSecureData("fechaInicio");
                                    await _storage.deleteSecureData("bodegaUsada");
                                    await _storage.deleteSecureData("observacion");
                                    await dbHelper.deleteTable();
                                    Navigator.of(context).pop();
                                    Future.delayed(const Duration(milliseconds: 2), () async {
                                      await Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) => const Home(),
                                        ),
                                        (route) => false,
                                      );
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("Terminar"),
                        SizedBox(
                          width: 5,
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.send,
                            size: 20.0,
                          ),
                        )
                      ]),
                    )
                  ],
                )),
          );
        });
      },
    );
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
                    "Cargando datos de la orden, por favor espere...",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget circularSegundo() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(),
              ),
              Text('Restaurando datos....'),
            ],
          ),
        ],
      ),
    );
  }
}
