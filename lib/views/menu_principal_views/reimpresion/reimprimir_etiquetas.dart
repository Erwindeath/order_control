import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart' as escp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/etiquetar/logica_reimprimir_etiquetas.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:image/image.dart' as img;
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/nuevasUbicaciones/clase/clases.dart';

import 'package:path_provider/path_provider.dart';

import '../../../complements/etiquetar/logica_etiquetar.dart';
import '../nuevasUbicaciones/methods.dart';
import '../nuevasUbicaciones/providers.dart';
// ignore: import_of_legacy_library_into_null_safe

class ReimprimirEtiquetas extends ConsumerStatefulWidget {
  const ReimprimirEtiquetas({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReimprimirEtiquetasState();
}

class _ReimprimirEtiquetasState extends ConsumerState<ReimprimirEtiquetas> {
  List<Map<String, dynamic>> valores = [];

  List<Map<String, dynamic>> filteredValores = [];
  TextEditingController editingController = TextEditingController();
  final SecureStorage _storage = SecureStorage();
  File? _selectedImage;
  int deparmento = 0;

  List<SubBodega> subBodegas = [];
  String nombreDepartamento = "";
  @override
  void initState() {
    datosInciales();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reimprimir Etiquetas')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: dropDown(deparmento, generarSubBodega()),
          ),
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
                await filterSearch(value);
              },
            ),
          ),
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
                              _showDialog(filteredValores[index]['Cod_Bode_Codigo'].toString(), filteredValores[index]['codigo_descripcion']);
                            },
                            title: Text(filteredValores[index]['codigo_descripcion']),
                            trailing: const Icon(
                              Icons.print_rounded,
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
    );
  }

  Widget dropDown(int valores, List<DropdownMenuItem<int>> data) {
    //final departamento = ref.watch(departamentoProvider);

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Bodegas',
        border: OutlineInputBorder(),
      ),
      child: DropdownButton(
        //borderRadius: BorderRadius.circular(5.0),
        underline: Container(),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        value: valores,
        style: const TextStyle(fontSize: 14, color: Color(0xff62242C)),
        items: data,
        onChanged: (int? valor) async {
          String nombre = subBodegas.firstWhere((element) => element.codSubBodega == valor).nombre;
          /*ref.read(departamentoProvider.notifier).seleccionarDepartamento(valor!, nombre);*/
          setState(() {
            deparmento = valor!;
            nombreDepartamento = nombre;
          });
          try {
            if (deparmento > 0) {
              await obtenerDatosBodegaSeleccionada(deparmento);
              /*var data = await obtenerDatosSeleccion(token, 'obtener_bloque', deparmento);

              var json = jsonDecode(data.body);
              if (json["data"] != null) {
                setState(() {
                  bloques = parsearBloquesBodega(data.body);
                });
              } else {
                await ArtSweetAlert.show(
                    barrierDismissible: false,
                    context: context,
                    artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.danger,
                        title: "Error",
                        text: "Error al obtener los bloques",
                        confirmButtonText: "Aceptar",
                        onConfirm: () async {
                          Navigator.pop(context);
                        },
                        confirmButtonColor: Colores.esquemaColor));
              }*/
            }
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }

  Future<void> filterSearch(String query) async {
    List<Map<String, dynamic>> tempList = [];
    if (query.length > 1) {
      for (var item in filteredValores) {
        String descripcion = item['codigo_descripcion'];
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

  List<DropdownMenuItem<int>> generarSubBodega() {
    List<DropdownMenuItem<int>> listadoDepartamentoBodega = [];
    if (deparmento != 0 && nombreDepartamento != "") {
      /*listadoDepartamentoBodega.add(
        const DropdownMenuItem(
          value: 0,
          child: Text("Seleccione una bodega"),
        ),
      );9*/
      for (var elemento in subBodegas) {
        listadoDepartamentoBodega.add(DropdownMenuItem(value: int.parse(elemento.codSubBodega.toString()), child: Text(elemento.nombre.toString())));
      }
      return listadoDepartamentoBodega;
    } else {
      listadoDepartamentoBodega.add(
        const DropdownMenuItem(
          value: 0,
          child: Text("Seleccione una sub bodega"),
        ),
      );
      for (var elemento in subBodegas) {
        listadoDepartamentoBodega.add(DropdownMenuItem(value: int.parse(elemento.codSubBodega.toString()), child: Text(elemento.nombre.toString())));
      }
      return listadoDepartamentoBodega;
    }
  }

  Future<void> datosInciales() async {
    String token = await _storage.readSecureData("token");
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;

    String result = "";
    if (isConnected == "true") {
      result = "true";
    } else {
      result = (await BluetoothThermalPrinter.connect('DC:1D:30:A1:2A:80'))!;
    }
    var dataBodega = await obternerBodegas(token);
    var jsonBodega = jsonDecode(dataBodega.body);
    
    if (jsonBodega["data"] != null && result == "true") {
      ref.read(validaProviderReimprimir.notifier).state = true;
      setState(() {
        subBodegas = parsearDataSubbodega(dataBodega.body);
      });
    } else {
      await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error",
              text: "Sin conexión con la impresora",
              confirmButtonText: "Aceptar",
              onConfirm: () async {
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const Home(),
                  ),
                  (route) => false,
                );
              },
              confirmButtonColor: Colores.esquemaColor));
    }
  }

  Future<void> obtenerDatosBodegaSeleccionada(int codSubBodega) async {
    String token = await _storage.readSecureData("token");
    var data = await obternerEtiquetas(token, codSubBodega);
    var json = jsonDecode(data.body);
    Map<String, dynamic> decodedData = jsonDecode(data.body)["data"];
    List<Map<String, dynamic>> fetchedValores = List<Map<String, dynamic>>.from(decodedData['valores']);
    if (json["data"] != null) {
      setState(() {
        valores = fetchedValores;
        filteredValores = fetchedValores;
      });
    } else {
      await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error",
              text: "No hay ubicaciones registradas en esta bodega",
              confirmButtonText: "Aceptar",
              onConfirm: () async {
                Navigator.pop(context);
                /*  await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const Home(),
                  ),
                  (route) => false,
                );*/
              },
              confirmButtonColor: Colores.esquemaColor));
    }
  }

  Future<void> _showDialog(String data, String letras) async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    //String? isConnected = "true";
    final image = img.Image(400, 200);
    img.fill(image, img.getColor(255, 255, 255));
    drawBarcode(image, Barcode.code128(), data);
    final png = img.encodePng(image);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/barcode.jpg';
    _selectedImage = await File(filePath).writeAsBytes(png);

    /*final int referencia = ubicacion.firstWhere(
        (ubicacion) => ubicacion['id'] == idUbicacion)['referencia'];
    datos = "CON0$deparmento R0$idRack S0$idSeccion A0$idAltura U$referencia";*/
    if (isConnected == "true") {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
                child: Text(
              'Reimprimir Etiquetas',
              style: TextStyle(color: Colores.esquemaColor, fontWeight: FontWeight.bold),
            )),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Image.file(_selectedImage!),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(letras, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    '¿Está seguro de reimprimir esta etiqueta?',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
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
                  //String? isConnectedw ="true";
                  String? isConnectedw = await BluetoothThermalPrinter.connectionStatus;
                  if (isConnectedw == "true") {
                    printImage(_selectedImage!, letras);
                    Navigator.of(context).pop();
                  } else {
                    await ArtSweetAlert.show(
                        barrierDismissible: false,
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.danger,
                            title: "Error",
                            text: "Sin conexión con la impresora",
                            confirmButtonText: "Aceptar",
                            onConfirm: () async {
                              await Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => const Home(),
                                ),
                                (route) => false,
                              );
                            },
                            confirmButtonColor: Colores.esquemaColor));
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error",
              text: "Sin conexión con la impresora",
              confirmButtonText: "Aceptar",
              onConfirm: () async {
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const Home(),
                  ),
                  (route) => false,
                );
              },
              confirmButtonColor: Colores.esquemaColor));
    }
  }

  Future<void> printImage(File file, String datos) async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    List<int> bytes = [];

    List<int> fileBytes = await file.readAsBytes();

    final ByteData data = ByteData.view(Uint8List.fromList(fileBytes).buffer);
    Uint8List bytes2 = data.buffer.asUint8List();

    img.Image? imagen = img.decodeImage(bytes2);
    escp.CapabilityProfile profile = await escp.CapabilityProfile.load();
    final generator = escp.Generator(escp.PaperSize.mm80, profile);
    bytes += generator.reset();
    imagen = img.copyResize(imagen!, width: 380, height: 120);
    bytes += generator.image(imagen, align: escp.PosAlign.center);

    bytes += generator.text(datos,
        styles: const escp.PosStyles(align: escp.PosAlign.center, bold: true, width: escp.PosTextSize.size3, height: escp.PosTextSize.size2),
        containsChinese: true,
        linesAfter: -2);

    bytes += generator.reverseFeed(2);

    bytes += generator.cut(mode: escp.PosCutMode.full);
    if (isConnected == "true") {
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {}
  }
}
