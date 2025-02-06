// ignore_for_file: dead_code

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/barrasAlternativos/logica/logicaAlternativos.dart';
import 'package:order_control/views/menu_principal_views/barrasAlternativos/logica/methods.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_control/views/menu_principal_views/barrasAlternativos/logica/provider.dart';
import 'package:order_control/views/ordenes_pendientes/logica_ordener_pendientes.dart';
import '../../../complements/colors.dart';
import 'logica/claseAlternativos.dart';

class CodigosBarrasAlternativos extends ConsumerStatefulWidget {
  const CodigosBarrasAlternativos({Key? key}) : super(key: key);

  @override
  ConsumerState<CodigosBarrasAlternativos> createState() => _CodigosBarrasAlternativosState();
}

TextEditingController buscarProductos = TextEditingController();
final SecureStorage _storage = SecureStorage();
//bool hasSearched = false;
List<Busqueda> productoPrueba = [];
StreamSubscription<dynamic>? fdwListener;
var fdw = FlutterDataWedge(profileName: 'FlutterDataWedgeDatos');

class _CodigosBarrasAlternativosState extends ConsumerState<CodigosBarrasAlternativos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Códigos de barras alternativos",
            style: TextStyle(fontSize: 16.0),
          ),
          leading: IconButton(
              onPressed: () async {
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const Home(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.arrow_back))),
      body: inicio(),
    );
  }

  void iniciarScannerManual() async {
    if (Platform.isAndroid) {
      fdwListener = fdw.onScanResult.listen((code) async {});
    }
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
              content: Consumer(builder: (context, ref, child) {
                final hasSearched = ref.watch(hasSearchedProvider);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        // readOnly: hasSearched,
                        controller: editingController,
                        decoration: const InputDecoration(
                          labelText: "Buscar ",
                          hintText: "Buscar",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          if (value == "" || value.trim().length <= 2) {
                            ref.read(hasSearchedProvider.notifier).state = false;
                          }
                        },
                        onSubmitted: (text) async {
                          if (!hasSearched) {
                            if (text.trim().length >= 4) {
                              await busquedaProducto(text);
                            } else {
                              Fluttertoast.showToast(
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                msg: "Debe ingresar mínimo 4 letras para buscar un producto",
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            }
                          } else {
                            ref.read(hasSearchedProvider.notifier).state = false;

                            editingController.clear();
                          }
                        },
                        /*onChanged: (value) async {
                            //await filterSearch(value, setState);
                          },*/
                      ),
                    ),
                    if (hasSearched)
                      Flexible(
                        child: _buildSearchResults(), // Usando Flexible para que ocupe el espacio restante
                      ), // Asegúrate de que esta condición se evalúe correctamente.

                    // Aquí está el CustomScrollView
                  ],
                );
              }),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    productoPrueba.clear();
                    ref.read(hasSearchedProvider.notifier).state = false;
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

  Future<void> codigoBarras(BuildContext context, Busqueda busqueda) async {
    final TextEditingController barrasControler = TextEditingController();
    final focusNode = FocusNode();
    bool valida = true;
    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        fdwListener?.cancel();
        iniciarScannerManual();
        return StatefulBuilder(builder: (context, setState) {
          /* WidgetsBinding.instance.addPostFrameCallback((_) {
            FocusScope.of(context).requestFocus(focusNode);
          });*/

          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              scrollable: true,
              title: const Text('Añadir código de barra adicional'),
              content: Builder(builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(busqueda.name),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextField(
                        enableSuggestions: false,
                        autocorrect: false,

                        keyboardType: TextInputType.number,
                        controller: barrasControler,
                        focusNode: focusNode, // Establecer el focusNode aquí
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Boxicons.bx_barcode,
                            size: 24,
                            color: Colores.esquemaColor,
                          ),
                          labelText: 'Código de barra',
                          hintText: "Código de barra",
                        ),
                      ),
                    ),
                  ],
                );
              }),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    productoPrueba.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Guardar'),
                  onPressed: valida
                      ? () async {
                          setState(() {
                            valida = false;
                          });
                          String token = await _storage.readSecureData("token");
                          String codUsuario = await _storage.readSecureData("cod_usuario");
                          String text = barrasControler.text;

                          if (text == "" || text.length < 7) {
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              msg: "Error al ingresar el código de barra",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          } else {
                            try {
                              var guardarBarra = await agregarCodBarra(
                                  token, 'agregar_cod_barra_adicional', 25, barrasControler.text, int.parse(codUsuario), busqueda.codProducto);
                              var decodificado = jsonDecode(guardarBarra.body);
                              if (decodificado["msg"] == "ok") {
                                setState(() {
                                  valida = true;
                                });
                                await ArtSweetAlert.show(
                                    barrierDismissible: false,
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.success,
                                        text: "Codigo de barras añadido correctamente",
                                        confirmButtonText: "Aceptar",
                                        onConfirm: () async {
                                          await Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) => const CodigosBarrasAlternativos(),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        confirmButtonColor: Colores.esquemaColor));
                              } else {
                                setState(() {
                                  valida = true;
                                });
                                Fluttertoast.showToast(
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  msg: "Error al guardar el código de barra",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              }
                            } on TimeoutException catch (e) {
                              setState(() {
                                valida = true;
                              });
                              await ArtSweetAlert.show(
                                  barrierDismissible: false,
                                  context: context,
                                  artDialogArgs: ArtDialogArgs(
                                      type: ArtSweetAlertType.danger,
                                      title: "Error: $e",
                                      text: "Comuníquese con el administrador",
                                      confirmButtonText: "Aceptar",
                                      onConfirm: () async {
                                        Navigator.pop(context);
                                      },
                                      confirmButtonColor: Colores.esquemaColor));
                            }
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
  }

  void iniciarScanner() async {
    if (Platform.isAndroid) {
      await fdw.initialize();
      fdwListener = fdw.onScanResult.listen((ScanResult code) async {
        await busquedaProductoBarra(code.data.toString().trim());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        iniciarDatos();
      }
    });
  }

  Future<void> iniciarDatos() async {
    iniciarScanner();
  }

  Future<void> busquedaProducto(String descripcion) async {
    String token = await _storage.readSecureData("token");

    var datos = await buscarProducto(token, descripcion);
    var decodigo = jsonDecode(datos.body);

    if (decodigo["msg"] == "ok") {
      productoPrueba = parsearBusqueda(datos.body);
      ref.read(hasSearchedProvider.notifier).state = true;
    } else {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Error producto no encontrado",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> busquedaProductoBarra(String descripcion) async {
    String token = await _storage.readSecureData("token");

    var datos = await buscarProductoBarra(token, descripcion);
    var decodigo = jsonDecode(datos.body);

    if (decodigo["msg"] == "ok") {
      productoPrueba = parsearBusqueda(datos.body);
      codigoBarras(context, productoPrueba[0]);
      //ref.read(hasSearchedProvider.notifier).state = true;
    } else {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Error producto no encontrado",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Widget inicio() {
    //final dbHelper = DatabaseHelper();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: "Buscqueda manual",
                iconSize: 90.0,
                onPressed: () async {
                  alertaBusquedaManual(context, "Buscar producto");
                },
              ),
              const Text("Escanee el producto a buscar...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      height: 325, // Ajusta según el espacio que quieras para mostrar resultados
      child: ListView.separated(
        itemCount: productoPrueba.length,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(); // Este es el separador entre filas
        },
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              productoPrueba[index].name,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "codBarra: ${productoPrueba[index].codBarra}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
            onTap: () async {
              Navigator.of(context).pop();
              codigoBarras(context, productoPrueba[index]);
            },
          );
        },
      ),
    );
  }
}
