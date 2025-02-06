import 'dart:convert';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart' as escp;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/etiquetar/logica_etiquetar.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:barcode_image/barcode_image.dart';
// ignore: import_of_legacy_library_into_null_safe

class Ubicaciones extends StatefulWidget {
  const Ubicaciones({Key? key}) : super(key: key);

  @override
  State<Ubicaciones> createState() => _UbicacionesState();
}

class _UbicacionesState extends State<Ubicaciones> {
  late SharedPreferences _prefs;
  final SecureStorage _storage = SecureStorage();
  String datos = "";
  File? _selectedImage;
  bool _isEnabled = false;

  //Departamento
  var bodegaDepartamento = [];
  int deparmento = 0;
  String nombreDepartamento = "";

  //Racks
  var racks = [];
  int idRack = 0;
  String nombreRack = "";

  //Seccion
  var secciones = [];
  int idSeccion = 0;
  String nombreSeccion = "";

  //altura
  var alturas = [];
  int idAltura = 0;
  String nombreAltura = "";

  //ubicacion
  var ubicacion = [];
  int idUbicacion = 0;
  String nombreUbicacion = "";

  bool valida = false;

  int idSeleccionado = 1;
  String opcionSeleccionada = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Empezar a etiquetar',
              style: TextStyle(color: Colors.white), //<-- SEE HERE
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: _isEnabled ? _handleButtonPress : null,
              icon: const Icon(
                Icons.print,
                color: Colors.white,
              ))
        ],
      ),
      body: inicial(),
    );
  }

  @override
  void initState() {
    super.initState();

    obtenerPreferenciasUsuario();
    datosIniciales();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleButtonPress() {
    if (datos == "") {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Error, no se pudo imprimir'),
          backgroundColor: Colors.red,
        ));
    } else {
      printImage(_selectedImage!, datos);
    }
  }

  Widget inicial() {
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

  Widget principal() {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff62242C), width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: dropDown(deparmento, generarDepartamento()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff62242C), width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: dropDownRacks(idRack, generarRacks()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff62242C), width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: dropDownSeccion(idSeccion, generarSecciones()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff62242C), width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: dropDownAltura(idAltura, generarAlturas()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff62242C), width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: dropDownUbicacion(idUbicacion, generarUbicaciones()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    child: botonGuardar(),
                  ),
                ],
              ),
            ))
          ],
        ))
      ],
    );
  }

  void validarD() {
    setState(() {
      _isEnabled = false;
      idRack = 0;
      nombreRack = "";
      idSeccion = 0;
      nombreSeccion = "";
      idAltura = 0;
      nombreAltura = "";
      idUbicacion = 0;
      nombreUbicacion = "";
    });
  }

  void validarRack(SharedPreferences sh) {
    sh.remove("idSeccionSeleccionada");
    sh.remove("nombreSeccionSeleccionada");
    sh.remove("idAlturaSeleccionada");
    sh.remove("nombreAlturaSeleccionada");
    setState(() {
      _isEnabled = false;
      idSeccion = 0;
      nombreSeccion = "";
      idAltura = 0;
      nombreAltura = "";
      idUbicacion = 0;
      nombreUbicacion = "";
    });
  }

  void validarSeccion(SharedPreferences sh) {
    sh.remove("idAlturaSeleccionada");
    sh.remove("nombreAlturaSeleccionada");

    setState(() {
      _isEnabled = false;
      idAltura = 0;
      nombreAltura = "";
      idUbicacion = 0;
      nombreUbicacion = "";
    });
  }

  void validarALtura() {
    setState(() {
      _isEnabled = true;
      idUbicacion = 0;
      nombreUbicacion = "";
    });
  }

  void validarVuelta() {
    setState(() {
      _isEnabled = true;
      idUbicacion = 0;
      nombreUbicacion = "";
    });
  }

  Widget dropDown(int valores, List<DropdownMenuItem<int>>? data) {
    return DropdownButton(
      borderRadius: BorderRadius.circular(5.0),
      underline: const SizedBox(),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      value: valores,
      items: data,
      style: const TextStyle(fontSize: 14, color: Color(0xff62242C)),
      onChanged: (int? valor) async {
        _prefs = await SharedPreferences.getInstance();
        await _prefs.clear();
        String nombre = bodegaDepartamento.firstWhere((element) => element["id"] == valor)["nombre"];
        validarD();
        setState(() {
          deparmento = valor!;
          nombreDepartamento = nombre;
        });
        await _prefs.setInt('departamentoSeleccionado', valor!);
        await _prefs.setString('nombreDepartamentoSeleccionado', nombre);
      },
    );
  }

  Widget dropDownRacks(int valores, List<DropdownMenuItem<int>>? data) {
    return DropdownButton(
      borderRadius: BorderRadius.circular(5.0),
      underline: const SizedBox(),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      value: valores,
      items: data,
      style: const TextStyle(fontSize: 14, color: Color(0xff62242C)),
      onChanged: (int? valor) async {
        _prefs = await SharedPreferences.getInstance();
        validarRack(_prefs);
        String nombre = racks.firstWhere((element) => element["id"] == valor)["nombre"];
        setState(() {
          idRack = valor!;
          nombreRack = nombre;
          _prefs.setInt('idRackSeleccionado', valor);
          _prefs.setString('nombreRackSeleccionado', nombre);
        });
      },
    );
  }

  Widget dropDownSeccion(int valores, List<DropdownMenuItem<int>>? data) {
    return DropdownButton(
      borderRadius: BorderRadius.circular(5.0),
      underline: const SizedBox(),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      value: valores,
      items: data,
      style: const TextStyle(fontSize: 14, color: Color(0xff62242C)),
      onChanged: (int? valor) async {
        _prefs = await SharedPreferences.getInstance();
        validarSeccion(_prefs);
        String nombre = secciones.firstWhere((element) => element["id"] == valor)["nombre"];
        setState(() {
          idSeccion = valor!;
          nombreSeccion = nombre;
          _prefs.setInt('idSeccionSeleccionada', valor);
          _prefs.setString('nombreSeccionSeleccionada', nombre);
        });
      },
    );
  }

  Widget dropDownAltura(int valores, List<DropdownMenuItem<int>>? data) {
    return DropdownButton(
      borderRadius: BorderRadius.circular(5.0),
      underline: const SizedBox(),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      value: valores,
      items: data,
      style: const TextStyle(fontSize: 14, color: Color(0xff62242C)),
      onChanged: (int? valor) async {
        if (deparmento != 0 && idRack != 0 && idSeccion != 0) {
          String token = await _storage.readSecureData("token");
          var dataRacks = await obternerRacks(token, deparmento, idRack, idSeccion, valor!);
          var jsonRacks = jsonDecode(dataRacks.body);
          if (jsonRacks["data"] != null) {
            _prefs = await SharedPreferences.getInstance();
            String nombre = "";
            if (alturas.isNotEmpty) {
              var altura = alturas.firstWhere((element) => element["id"] == idAltura, orElse: () => null);
              if (altura != null) {
                nombre = altura["nombre"];
              }
            }
            validarALtura();
            setState(() {
              ubicacion = jsonRacks["data"]["valores"];
              idAltura = valor;
              nombreAltura = nombre;
              _prefs.setInt('idAlturaSeleccionada', valor);
              _prefs.setString('nombreAlturaSeleccionada', nombre);
            });
          }
        } else {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text('Faltan campos por seleccionar'),
              backgroundColor: Colors.red,
            ));
        }
      },
    );
  }

  Widget dropDownUbicacion(int valores, List<DropdownMenuItem<int>>? data) {
    return DropdownButton(
      borderRadius: BorderRadius.circular(5.0),
      underline: const SizedBox(),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      value: valores,
      items: data,
      style: const TextStyle(fontSize: 14, color: Color(0xff62242C)),
      onChanged: (int? valor) async {
        String nombre = ubicacion.firstWhere((element) => element["id"] == valor)["nombre"];
        setState(() {
          _isEnabled = true;
          idUbicacion = valor!;
          nombreUbicacion = nombre;
        });
      },
    );
  }

  Widget botonGuardar() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              if (deparmento == 0) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text('Debe seleccionar un área'),
                    backgroundColor: Colors.red,
                  ));
              } else if (idRack == 0) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text('Debe seleccionar un rack'),
                    backgroundColor: Colors.red,
                  ));
              } else if (idSeccion == 0) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text('Debe seleccionar una sección'),
                    backgroundColor: Colors.red,
                  ));
              } else if (idAltura == 0) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text('Debe seleccionar una altura'),
                    backgroundColor: Colors.red,
                  ));
              } else if (idUbicacion == 0) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text('Debe seleccionar una ubicación'),
                    backgroundColor: Colors.red,
                  ));
              } else {
                String data = deparmento.toString() + idRack.toString() + idSeccion.toString() + idAltura.toString() + idUbicacion.toString();
                setState(() {
                  _isEnabled = !_isEnabled;
                });
                _showDialog(data);
              }
            } catch (error) {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(error.toString())));
            }
          },
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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

  Future<void> datosIniciales() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;

    String result = "";
    if (isConnected == "true") {
      result = "true";
    } else {
      result = (await BluetoothThermalPrinter.connect('DC:1D:30:A1:2A:80'))!;
    }
    String token = await _storage.readSecureData("token");

    var data = await obternerBodegas(token);
    var json = jsonDecode(data.body);
    print(json);
    // print("state conneected $result");
    if (json["data"] != null && result == "true") {
      setState(() {
        valida = true;
        bodegaDepartamento = jsonDecode(json["data"]["valores"][0]["departamento"]);
        /* racks = jsonDecode(json["data"]["valores"][0]["racks"]);
        secciones = jsonDecode(json["data"]["valores"][0]["seccion"]);
        alturas = jsonDecode(json["data"]["valores"][0]["altura"]);*/
      });
    } else {
      valida = false;
      await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error",
              text: "Comuníquese con el administrador",
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

  Future<void> obtenerPreferenciasUsuario() async {
    _prefs = await SharedPreferences.getInstance();
    int? departamentoSeleccionado = _prefs.getInt('departamentoSeleccionado');
    String? nombreDepartamentoSeleccionado = _prefs.getString('nombreDepartamentoSeleccionado');

    int? idRackSeleccionado = _prefs.getInt('idRackSeleccionado');
    String? nombreRackSeleccionado = _prefs.getString('nombreRackSeleccionado');

    int? idSeccionSeleccionado = _prefs.getInt('idSeccionSeleccionada');
    String? nombreSeccionSeleccionado = _prefs.getString('nombreSeccionSeleccionada');

    int? idAlturaSeleccionado = _prefs.getInt('idAlturaSeleccionada');
    String? nombreAlturaSeleccionado = _prefs.getString('nombreAlturaSeleccionada');

    if (departamentoSeleccionado != null ||
        nombreDepartamentoSeleccionado != null ||
        idRackSeleccionado != null ||
        nombreRackSeleccionado != null ||
        idSeccionSeleccionado != null ||
        nombreSeccionSeleccionado != null ||
        idAlturaSeleccionado != null ||
        nombreAlturaSeleccionado != null) {
      setState(() {
        deparmento = departamentoSeleccionado ?? 0;
        nombreDepartamento = nombreDepartamentoSeleccionado ?? "";
        idRack = idRackSeleccionado ?? 0;
        nombreRack = nombreRackSeleccionado ?? "";

        idSeccion = idSeccionSeleccionado ?? 0;
        nombreSeccion = nombreSeccionSeleccionado ?? "";

        idAltura = idAlturaSeleccionado ?? 0;
        nombreAltura = nombreAlturaSeleccionado ?? "";
      });
    }
    validar();
  }

  Future<void> validar() async {
    if (deparmento != 0 && idRack != 0 && idSeccion != 0 && idAltura != 0) {
      String token = await _storage.readSecureData("token");
      var dataRacks = await obternerRacks(token, deparmento, idRack, idSeccion, idAltura);
      var jsonRacks = jsonDecode(dataRacks.body);
      if (jsonRacks["data"] != null) {
        _prefs = await SharedPreferences.getInstance();
        String nombre = "";
        if (alturas.isNotEmpty) {
          var altura = alturas.firstWhere((element) => element["id"] == idAltura, orElse: () => null);
          if (altura != null) {
            nombre = altura["nombre"];
          }
        }
        validarALtura();
        setState(() {
          ubicacion = jsonRacks["data"]["valores"];
          nombreAltura = nombre;
          _prefs.setString('nombreAlturaSeleccionada', nombre);
        });
      }
    }
  }

  Future<void> _showDialog(String data) async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    final image = img.Image(400, 200);
    img.fill(image, img.getColor(255, 255, 255));
    drawBarcode(image, Barcode.code128(), data);
    final png = img.encodePng(image);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/barcode.jpg';
    _selectedImage = await File(filePath).writeAsBytes(png);

    final int referencia = ubicacion.firstWhere((ubicacion) => ubicacion['id'] == idUbicacion)['referencia'];

    if (deparmento == 1) {
      setState(() {
        datos = "CON0$deparmento R0$idRack S0$idSeccion A0$idAltura U$referencia";
      });
    } else if (deparmento == 2) {
      setState(() {
        datos = "FARP10$deparmento R0$idRack S0$idSeccion A0$idAltura U$referencia";
      });
    } else if (deparmento == 3) {
      setState(() {
        datos = "FARP20$deparmento R0$idRack S0$idSeccion A0$idAltura U$referencia";
      });
    } else if (deparmento == 4) {
      setState(() {
        datos = "PS0$deparmento R0$idRack S0$idSeccion A0$idAltura U$referencia";
      });
    } else if (deparmento == 5) {
      setState(() {
        datos = "FR0$deparmento R0$idRack S0$idSeccion A0$idAltura U$referencia";
      });
    }

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
                  /*Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: showData(deparmento.toString(), idRack.toString(), idSeccion.toString(), idAltura.toString(), referencia.toString()),
                  ),*/
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
                  setState(() {
                    _isEnabled = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () async {
                  String? isConnectedw = await BluetoothThermalPrinter.connectionStatus;
                  if (isConnectedw == "true") {
                    String token = await _storage.readSecureData("token");
                    String codUsuario = await _storage.readSecureData("cod_usuario");
                    var data = await registrarEtiquetas(token, deparmento, idRack, idSeccion, idAltura, idUbicacion, int.parse(codUsuario));
                    var mensaje = jsonDecode(data.body);

                    if (mensaje["msg"] != 'err') {
                      final image = img.Image(400, 200);
                      img.fill(image, img.getColor(255, 255, 255));
                      drawBarcode(image, Barcode.code128(), mensaje["respuesta"][0]["resultado"].toString());
                      final png = img.encodePng(image);
                      final directory = await getApplicationDocumentsDirectory();
                      final filePath = '${directory.path}/barcode.jpg';
                      _selectedImage = await File(filePath).writeAsBytes(png);

                      printImage(_selectedImage!, datos);

                      validarVuelta();
                      validar();
                      Navigator.of(context).pop();
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
                                await Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => const Ubicaciones(),
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

  void printImage(File file, String datos) async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    List<int> bytes = [];

    List<int> fileBytes = await file.readAsBytes();

    final ByteData data = ByteData.view(Uint8List.fromList(fileBytes).buffer);
    Uint8List bytes2 = data.buffer.asUint8List();

    img.Image? imagen = img.decodeImage(bytes2);
    escp.CapabilityProfile profile = await escp.CapabilityProfile.load();
    final generator = escp.Generator(escp.PaperSize.mm80, profile);

    imagen = img.copyResize(imagen!, width: 400);
    bytes += generator.image(imagen, align: escp.PosAlign.center);

    bytes += generator.text(datos,
        styles: const escp.PosStyles(align: escp.PosAlign.center, bold: true, width: escp.PosTextSize.size2, height: escp.PosTextSize.size1),
        containsChinese: true);

    bytes += generator.reverseFeed(1);
    bytes += generator.cut(mode: escp.PosCutMode.full);
    if (isConnected == "true") {
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {}
  }

  List<DropdownMenuItem<int>>? generarDepartamento() {
    List<DropdownMenuItem<int>>? listadoDepartamentoBodega = [];
    if (deparmento != 0 && nombreDepartamento != "") {
      for (var elemento in bodegaDepartamento) {
        listadoDepartamentoBodega.add(DropdownMenuItem(value: int.parse(elemento["id"].toString()), child: Text(elemento["nombre"].toString())));
      }
      return listadoDepartamentoBodega;
    } else {
      listadoDepartamentoBodega.add(
        const DropdownMenuItem(
          value: 0,
          child: Text("Seleccione un área"),
        ),
      );
      for (var elemento in bodegaDepartamento) {
        listadoDepartamentoBodega.add(DropdownMenuItem(value: int.parse(elemento["id"].toString()), child: Text(elemento["nombre"].toString())));
      }
      return listadoDepartamentoBodega;
    }
  }

  List<DropdownMenuItem<int>>? generarRacks() {
    List<DropdownMenuItem<int>>? listadoRacks = [];
    if (idRack != 0 && nombreRack != "") {
      for (var elemento in racks) {
        listadoRacks.add(DropdownMenuItem(
          value: int.parse(elemento["id"].toString()),
          child: Text(elemento["nombre"].toString()),
        ));
      }
      return listadoRacks;
    } else {
      listadoRacks.add(const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione un rack"),
      ));
      for (var elemento in racks) {
        listadoRacks.add(DropdownMenuItem(
          value: int.parse(elemento["id"].toString()),
          child: Text(elemento["nombre"].toString()),
        ));
      }
      return listadoRacks;
    }
  }

  List<DropdownMenuItem<int>>? generarSecciones() {
    List<DropdownMenuItem<int>>? listadoSecciones = [];
    if (idSeccion != 0 && nombreSeccion != "") {
      for (var elemento in secciones) {
        listadoSecciones.add(DropdownMenuItem(
          value: int.parse(elemento["id"].toString()),
          child: Text(elemento["nombre"].toString()),
        ));
      }
      return listadoSecciones;
    } else {
      listadoSecciones.add(const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione una sección"),
      ));
      for (var elemento in secciones) {
        listadoSecciones.add(DropdownMenuItem(
          value: int.parse(elemento["id"].toString()),
          child: Text(elemento["nombre"].toString()),
        ));
      }
      return listadoSecciones;
    }
  }

  List<DropdownMenuItem<int>>? generarAlturas() {
    List<DropdownMenuItem<int>>? listadoAlturas = [];
    if (idAltura != 0 && nombreAltura != "") {
      for (var elemento in alturas) {
        listadoAlturas.add(DropdownMenuItem(
          value: int.parse(elemento["id"].toString()),
          child: Text(elemento["nombre"].toString()),
        ));
      }
      return listadoAlturas;
    } else {
      listadoAlturas.add(const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione una altura"),
      ));
      for (var elemento in alturas) {
        listadoAlturas.add(DropdownMenuItem(
          value: int.parse(elemento["id"].toString()),
          child: Text(elemento["nombre"].toString()),
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
          value: int.parse(elemento["id"].toString()),
          child: Text(elemento["nombre"].toString()),
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
          value: int.parse(elemento["id"].toString()),
          child: Text(elemento["nombre"].toString()),
        ));
      }
      return listadoUbicaciones;
    }
  }

  /* @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    obtenerPreferenciasUsuario();
  }*/
}
