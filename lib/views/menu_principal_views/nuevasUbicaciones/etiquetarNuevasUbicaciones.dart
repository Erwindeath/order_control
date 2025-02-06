// ignore_for_file: avoid_print, override_on_non_overriding_member

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/etiquetar/logica_etiquetar.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/nuevasUbicaciones/clase/clases.dart';
import 'package:order_control/views/menu_principal_views/nuevasUbicaciones/methods.dart';
import 'package:order_control/views/menu_principal_views/nuevasUbicaciones/providers.dart';
import 'package:image/image.dart' as img;
import 'package:order_control/widget/show_data_etiqueta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart' as escp;

class NuevasUbicacionesEtiquetas extends ConsumerStatefulWidget {
  const NuevasUbicacionesEtiquetas({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NuevasUbicacionesEtiquetasState();
}

class _NuevasUbicacionesEtiquetasState
    extends ConsumerState<NuevasUbicacionesEtiquetas> {
  @override
  final SecureStorage storage = SecureStorage();
  int deparmento = 0;
  int idRack = 0;
  int idAltura = 0;
  String token = "";
  String nombreDepartamento = "";
  String nombreRack = "";
  String nombreAltura = "";
  int idUbicacion = 0;
  String nombreUbicacion = "";
  List<SubBodega> subBodegas = [];
  List<Bloques> bloques = [];
  List<Niveles> nivel = [];
  List<Ubicaciones> ubicacion = [];
  File? _selectedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Etiquetar bodega',
              style: TextStyle(color: Colors.white), //<-- SEE HERE
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const Home(),
              ),
              (route) => false,
            );
          }, // Esto lleva al usuario a la pantalla anterior
        ),
        actions: [
          IconButton(
              onPressed: () {
                _handleButtonPress();
              }, //_isEnabled ? _handleButtonPress : null,
              icon: const Icon(
                Icons.print,
                color: Colors.white,
              ))
        ],
      ),
      body: inicial(),
    );
  }

  Widget inicial() {
    final valida = ref.watch(validaProvider);
    if (valida == false) {
      return const Center(
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.blueGrey,
          ),
        ),
      );
    } else {
      return principal();
    }
  }

  @override
  void dispose() {
    super.dispose();
    //datosIniciales(); // Asumiendo que este método recarga los datos necesarios

    /*limpiardatos();
    ref.read(validaProvider.notifier).state = false;*/
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        datosIniciales();
      }
    });
  }
  /*@override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Tu lógica de carga de datos aquí
  }*/

  Future<void> datosIniciales() async {
    try {
      ref.read(validaProvider.notifier).state = false;
      //ref.read(departamentoProvider.notifier).limpiarDepartamentos();
      ref.read(ubicacionProviderNuevo.notifier).loadValuesFromStorage(storage);
      String? isConnected = await BluetoothThermalPrinter.connectionStatus;

      String result = "";
      if (isConnected == "true") {
        result = "true";
      } else {
        result = (await BluetoothThermalPrinter.connect('DC:1D:30:A1:2A:80'))!;
      }
      if (result == "true") {
        token = await storage.readSecureData("token");
        var data = await obternerBodegas(token);
        var json = jsonDecode(data.body);

        if (json["data"] != null) {
          ref.read(validaProvider.notifier).state = true;
          subBodegas = parsearDataSubbodega(data.body);
        } else {
          ref.read(validaProvider.notifier).state = false;
          await ArtSweetAlert.show(
              barrierDismissible: false,
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "Error",
                  text: "Error al obtener los datos",
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
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Error, ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
    }
  }

  Widget principal() {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: SizedBox(
                      width: double.infinity,
                      /*decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff62242C), width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),*/
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: dropDown(deparmento, generarSubBodega()),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: SizedBox(
                      width: double.infinity,
                      /*decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff62242C), width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),*/
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: bloques.isNotEmpty
                            ? dropDownBloques(idRack, generarBloque())
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: SizedBox(
                      width: double.infinity,
                      /*decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff62242C), width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),*/
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: nivel.isNotEmpty
                            ? dropDownAltura(idAltura, generarAlturas())
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: SizedBox(
                      width: double.infinity,
                      /*decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff62242C), width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),*/
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ubicacion.isNotEmpty
                            ? dropDownUbicacion(
                                idUbicacion, generarUbicaciones())
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    child: ref.watch(ubicacionProvider).id != 0 &&
                            ubicacion.isNotEmpty
                        ? botonGuardar()
                        : null,
                  ),
                ],
              ),
            ))
          ],
        ))
      ],
    );
  }

  Future<void> limpiardatos() async {
    ref.read(bloquesProvider.notifier).limpiarBloques();
    bloques.clear();
    nivel.clear();
    ref.read(alturaProvider.notifier).limpiarAltura();
    ubicacion.clear();
    ref.read(ubicacionProvider.notifier).limpiarUbicacion();
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
          await limpiardatos();
          String nombre = subBodegas
              .firstWhere((element) => element.codSubBodega == valor)
              .nombre;
          /*ref.read(departamentoProvider.notifier).seleccionarDepartamento(valor!, nombre);*/
          setState(() {
            deparmento = valor!;
            nombreDepartamento = nombre;
          });
          try {
            if (deparmento > 0) {
              var data = await obtenerDatosSeleccion(
                  token, 'obtener_bloque', deparmento);

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
              }
            }
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }

  Widget dropDownBloques(int valores, List<DropdownMenuItem<int>>? data) {
    final bloquesValue = ref.watch(bloquesProvider);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Bloques',
        border: OutlineInputBorder(),
      ),
      child: DropdownButton(
        //borderRadius: BorderRadius.circular(5.0),
        underline: Container(),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        value: bloquesValue.id,
        items: data,
        style: const TextStyle(fontSize: 14, color: Color(0xff62242C)),
        onChanged: (int? valor) async {
          nivel.clear();
          ref.read(alturaProvider.notifier).limpiarAltura();
          String nombre = bloques
              .firstWhere((element) => element.codBloque == valor)
              .nombre;
          ref.read(bloquesProvider.notifier).seleccionarBloque(valor!, nombre);
          try {
            var data =
                await obtenerDatosSeleccion(token, 'obtener_niveles', valor);

            var json = jsonDecode(data.body);
            if (json["data"] != null) {
              setState(() {
                nivel = parsearNiveles(data.body);

                

              });
            } else {
              await ArtSweetAlert.show(
                  barrierDismissible: false,
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.danger,
                      title: "Error",
                      text: "Error al obtener las alturas",
                      confirmButtonText: "Aceptar",
                      onConfirm: () async {
                        Navigator.pop(context);
                      },
                      confirmButtonColor: Colores.esquemaColor));
            }
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }

  Widget dropDownAltura(int valores, List<DropdownMenuItem<int>>? data) {
    final alturasValue = ref.watch(alturaProvider);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Altura',
        border: OutlineInputBorder(),
      ),
      child: DropdownButton(
        //borderRadius: BorderRadius.circular(5.0),
        underline: Container(),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        value: alturasValue.id,
        items: data,
        style: const TextStyle(fontSize: 14, color: Color(0xff62242C)),
        onChanged: (int? valor) async {
          ref.read(ubicacionProvider.notifier).limpiarUbicacion();

          String nombre =
              nivel.firstWhere((element) => element.codNivel == valor).nombre;
          ref.read(alturaProvider.notifier).seleccionarAltura(valor!, nombre);
          try {
            var data = await obtenerDatosSeleccion(
                token, 'obtener_ubicaciones_referencia', valor);
            var json = jsonDecode(data.body);
            if (json["data"] != null) {
              setState(() {
                ubicacion = parsearUbicaciones(data.body);
              });
            } else {
              await ArtSweetAlert.show(
                  barrierDismissible: false,
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.danger,
                      title: "Error",
                      text: "Error al obtener las ubicaciones",
                      confirmButtonText: "Aceptar",
                      onConfirm: () async {
                        Navigator.pop(context);
                      },
                      confirmButtonColor: Colores.esquemaColor));
            }
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }

  Widget dropDownUbicacion(int valores, List<DropdownMenuItem<int>>? data) {
    final ubicacionValue = ref.watch(ubicacionProvider);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Ubicación',
        border: OutlineInputBorder(),
      ),
      child: DropdownButton(
        //borderRadius: BorderRadius.circular(5.0),
        //borderRadius: BorderRadius.circular(5.0),
        underline: Container(),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        value: ubicacionValue.id,
        items: data,
        style: const TextStyle(fontSize: 14, color: Color(0xff62242C)),
        onChanged: (int? valor) async {
          String nombre = ubicacion
              .firstWhere((element) => element.codUbicacion == valor)
              .nombre;
          ref
              .read(ubicacionProvider.notifier)
              .seleccionarUbicacion(valor!, nombre);
          /*setState(() {
            _isEnabled = true;
            idUbicacion = valor!;
            nombreUbicacion = nombre;
          });*/
        },
      ),
    );
  }

  Widget botonGuardar() {
    final ubicacionValue = ref.watch(ubicacionProvider);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              if (ubicacionValue.id == 0) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text('Debe seleccionar una ubicación'),
                    backgroundColor: Colors.red,
                  ));
              } else {
                /*  
                setState(() {
                  _isEnabled = !_isEnabled;
                });
                _showDialog(data);*/
                String data = (ref.read(bloquesProvider).nombre +
                        "-" +
                        ref.watch(ubicacionProvider).nombre.trim() +
                        "-" +
                        ref.watch(alturaProvider).nombre.trim())
                    .toString();
                String dataReal = (ref.read(bloquesProvider).nombre +
                        ref.watch(alturaProvider).nombre.trim() +
                        ref.watch(ubicacionProvider).nombre.trim())
                    .toString();
                _showDialog(data, dataReal, token);
              }
            } catch (error) {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(error.toString())));
            }
          },
          child:
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Registrar Ubicación"),
            SizedBox(
              width: 5,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.save,
                size: 20.0,
              ),
            )
          ]),
        ),
      ),
    );
  }

  Future<void> _handleButtonPress() async {
    if (ref.watch(ubicacionProviderNuevo).codUbicacion == "" ||
        ref.watch(ubicacionProviderNuevo).codUbicacion.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Error, no se pudo imprimir'),
          backgroundColor: Colors.red,
        ));
    } else {
      final image = img.Image(400, 200);
      img.fill(image, img.getColor(255, 255, 255));
      drawBarcode(image, Barcode.code128(),
          ref.watch(ubicacionProviderNuevo).codUbicacion);
      final png = img.encodePng(image);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/barcode.jpg';
      _selectedImage = await File(filePath).writeAsBytes(png);
      printImage(
          _selectedImage!, ref.watch(ubicacionProviderNuevo).nombreUbicacion);
    }
  }

  Future<void> _showDialog(String data, String datoReal, String token) async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    final image = img.Image(400, 150);
    img.fill(image, img.getColor(255, 255, 255));
    drawBarcode(image, Barcode.code128(), datoReal);
    final png = img.encodePng(image);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/barcode.jpg';
    _selectedImage = await File(filePath).writeAsBytes(png);

    if (isConnected == "true") {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Registro de ubicaciones'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Image.file(_selectedImage!),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: showData(data),
                  ),
                  const Text(
                    '¿Está seguro de registrar esta ubicación?',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  /* setState(() {
                    _isEnabled = false;
                  });*/
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () async {
                  String? isConnectedw =
                      await BluetoothThermalPrinter.connectionStatus;
                  if (isConnectedw == "true") {
                    // String token = await _storage.readSecureData("token");

                    var data = await registrarEtiquetasNuevo(
                        token,
                        ref.watch(ubicacionProvider).nombre.trim(),
                        ref.watch(alturaProvider).id);
                    var mensaje = jsonDecode(data.body);

                    if (mensaje["msg"] != 'err' &&
                        mensaje["respuesta"] != null &&
                        mensaje["respuesta"].isNotEmpty) {
                      final image = img.Image(400, 150);
                      img.fill(image, img.getColor(255, 255, 255));
                      drawBarcode(image, Barcode.code128(),
                          mensaje["respuesta"][0]["codUbicacion"].toString());
                      final png = img.encodePng(image);
                      final directory =
                          await getApplicationDocumentsDirectory();
                      final filePath = '${directory.path}/barcode.jpg';
                      _selectedImage = await File(filePath).writeAsBytes(png);
                      await printImage(
                          _selectedImage!,
                          mensaje["respuesta"][0]["nombreUbicacion"]
                              .toString());
                      Fluttertoast.showToast(
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        msg: "Unicación impresa y registrada correctamente",
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_LONG,
                      );
                      await updateAndStoreData(
                          mensaje["respuesta"][0]["codUbicacion"].toString(),
                          mensaje["respuesta"][0]["nombreUbicacion"]
                              .toString());
                      ubicacion.clear();
                      ref.read(ubicacionProvider.notifier).limpiarUbicacion();
                      Navigator.pop(context);
                    } else {
                      await ArtSweetAlert.show(
                          barrierDismissible: false,
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                              type: ArtSweetAlertType.warning,
                              title: "Error",
                              text: "Esta ubicación se encuentra registrada",
                              confirmButtonText: "Aceptar",
                              onConfirm: () async {
                                Navigator.pop(context);
                              },
                              confirmButtonColor: Colores.esquemaColor));
                    }
                  } else {
                    await ArtSweetAlert.show(
                        barrierDismissible: false,
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.warning,
                            title: "Error",
                            text: "Sin conexión con la impresora",
                            confirmButtonText: "Aceptar",
                            onConfirm: () async {
                              await Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const Home(),
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
              type: ArtSweetAlertType.warning,
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

  Future<void> updateAndStoreData(String cod, String nombre) async {
    ref.read(ubicacionProviderNuevo.notifier).setCodUbicacion(cod);
    ref.read(ubicacionProviderNuevo.notifier).setNombreUbicacion(nombre);
    ref.read(ubicacionProviderNuevo.notifier).saveValuesToStorage(storage);
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
        styles: const escp.PosStyles(
            align: escp.PosAlign.center,
            bold: true,
            width: escp.PosTextSize.size3,
            height: escp.PosTextSize.size2),
        containsChinese: true,
        linesAfter: -2);

    bytes += generator.reverseFeed(2);

    bytes += generator.cut(mode: escp.PosCutMode.full);
    if (isConnected == "true") {
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {}
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
        listadoDepartamentoBodega.add(DropdownMenuItem(
            value: int.parse(elemento.codSubBodega.toString()),
            child: Text(elemento.nombre.toString())));
      }
      return listadoDepartamentoBodega;
    } else {
      listadoDepartamentoBodega.add(
        const DropdownMenuItem(
          value: 0,
          child: Text("Seleccione una bodega"),
        ),
      );
      for (var elemento in subBodegas) {
        listadoDepartamentoBodega.add(DropdownMenuItem(
            value: int.parse(elemento.codSubBodega.toString()),
            child: Text(elemento.nombre.toString())));
      }
      return listadoDepartamentoBodega;
    }
  }

  List<DropdownMenuItem<int>>? generarBloque() {
    List<DropdownMenuItem<int>>? listadoRacks = [];
    if (bloques.isNotEmpty) {
      listadoRacks.add(const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione un bloque"),
      ));
      for (var elemento in bloques) {
        listadoRacks.add(DropdownMenuItem(
          value: int.parse(elemento.codBloque.toString()),
          child: Text(elemento.nombre.toString()),
        ));
      }
      return listadoRacks;
    } else {
      listadoRacks.add(const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione un bloque"),
      ));
      for (var elemento in bloques) {
        listadoRacks.add(DropdownMenuItem(
          value: int.parse(elemento.codBloque.toString()),
          child: Text(elemento.nombre.toString()),
        ));
      }
      return listadoRacks;
    }
  }

  List<DropdownMenuItem<int>>? generarAlturas() {
    List<DropdownMenuItem<int>>? listadoAlturas = [];
    if (idAltura != 0 && nombreAltura != "") {
      for (var elemento in nivel) {
        listadoAlturas.add(DropdownMenuItem(
          value: int.parse(elemento.codNivel.toString()),
          child: Text(elemento.nombre.toString()),
        ));
      }
      return listadoAlturas;
    } else {
      listadoAlturas.add(const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione una altura"),
      ));
      for (var elemento in nivel) {
        listadoAlturas.add(DropdownMenuItem(
          value: int.parse(elemento.codNivel.toString()),
          child: Text(elemento.nombre.toString()),
        ));
      }
      return listadoAlturas;
    }
  }

  List<DropdownMenuItem<int>>? generarUbicaciones() {
    List<DropdownMenuItem<int>>? listadoUbicaciones = [];
    if (idUbicacion != 0 && nombreUbicacion != "") {
      for (var elemento in ubicacion) {
        listadoUbicaciones.add(DropdownMenuItem(
          value: int.parse(elemento.codUbicacion.toString()),
          child: Text(elemento.nombre.toString()),
        ));
      }
      return listadoUbicaciones;
    } else {
      listadoUbicaciones.add(const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione una ubicación"),
      ));
      for (var elemento in ubicacion) {
        listadoUbicaciones.add(DropdownMenuItem(
          value: int.parse(elemento.codUbicacion.toString()),
          child: Text(elemento.nombre.toString()),
        ));
      }
      return listadoUbicaciones;
    }
  }
}
