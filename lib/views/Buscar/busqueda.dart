import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:fluttertoast/fluttertoast.dart';
// ignore: import_of_legacy_library_into_null_safe
// ignore: implementation_imports
import 'package:http/src/response.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/Buscar/logica_buscar.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/nuevasUbicaciones/etiquetarNuevasUbicaciones.dart';

class BuscarProductos extends StatefulWidget {
  const BuscarProductos({Key? key}) : super(key: key);

  @override
  State<BuscarProductos> createState() => _BuscarProductosState();
}

class _BuscarProductosState extends State<BuscarProductos> with SingleTickerProviderStateMixin {
  String datoInicial = "";
  StreamSubscription<dynamic>? fdwListener;
  var fdw = FlutterDataWedge(profileName: 'FlutterDataWedge');

  late AnimationController controller;
  bool seleccionTipoBusqueda = false;
  List<Map<String, dynamic>> opciones = [
    {'Codigo': 1, 'Nombre': "Productos"},
    {'Codigo': 2, 'Nombre': "Ubicación"}
  ];
  int tipoSeleccionado = 0;
  final SecureStorage _storage = SecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Verificación de producto"),
        ),
        body: datos());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eleccionTipo();
    });
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  Widget datos() {
    if (!seleccionTipoBusqueda) {
      return circularPrimero();
    } else {
      return principal();
    }
  }

  @override
  void dispose() {
    controller.dispose(); // Detiene y desecha el controller
    fdwListener?.cancel(); // Detiene cualquier suscripción pendiente
    super.dispose();
  }

  Widget principal() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            alignment: Alignment.center,
            scale: Tween(begin: 1.0, end: 1.5).animate(controller),
            child: IconButton(
                alignment: Alignment.center,
                onPressed: () => eleccionTipo(),
                icon: const Icon(
                  Icons.search_rounded,
                  color: Colores.esquemaColor,
                  size: 50,
                )),
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              datoInicial,
              style: const TextStyle(
                fontSize: 18.0, // Tamaño de fuente de 18 pixeles
                // Color de fuente personalizado
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget circularPrimero() {
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
              Text('Esperando elección....'),
            ],
          ),
        ],
      ),
    );
  }

  void iniciarScanner() async {
    Response resultado;
    Response resultadoNuevo;
    String token = await _storage.readSecureData("token");
    if (tipoSeleccionado == 1) {
      if (Platform.isAndroid) {
        fdwListener = fdw.onScanResult.listen((code) async {
          resultado = await buscarProductos(token, "busqueda_productos", 5, code.data.toString());

          if (jsonDecode(resultado.body)['msg'] != "err") {
            String descripcionProducto = jsonDecode(resultado.body)['respuesta'][0]["Descripcion"];
            String codigo = jsonDecode(resultado.body)['respuesta'][0]["Cod_Bode_Codigo"].toString();
            if (codigo == '0') {
              await showDialog<void>(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        scrollable: true,
                        title: const Text('Producto sin ubicación asiganada'),
                        content: const SingleChildScrollView(child: Text("¿Desea crearle una ubicación?")),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Aceptar'),
                            onPressed: () async {
                              await Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => NuevasUbicacionesEtiquetas(key: UniqueKey()),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  });
                },
              );

              setState(() {
                datoInicial = "El producto $descripcionProducto, no tiene ubicación asignada";
              });
            } else {
              setState(() {
                datoInicial =
                    "El producto $descripcionProducto, pertenece a la ubicación: " + jsonDecode(resultado.body)['respuesta'][0]["codigo_descripcion"];
              });
            }
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: "El producto escaneado no existe ",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        });
      }
    } else if (tipoSeleccionado == 2) {
      if (Platform.isAndroid) {
        fdwListener = fdw.onScanResult.listen((code) async {
          //resultado = await buscarProductos(token, "busqueda_ubicacion", 5, code.data.toString());
          resultadoNuevo = await buscarProductos(token, "busqueda_ubicacaion_nueva", 5, code.data.toString()); //verifica por el nuevo método

          /* if (jsonDecode(resultado.body)['msg'] != "err") {
            String descripcionUbicacion = jsonDecode(resultado.body)['respuesta'][0]["codigo_descripcion"];
            setState(() {
              datoInicial =
                  "La ubicación $descripcionUbicacion, tiene asignado el producto: " + jsonDecode(resultado.body)['respuesta'][0]["Descripcion"];
            });
          } else */
          if (jsonDecode(resultadoNuevo.body)['msg'] != "err") {
            //verifica por el nuevo método
            String descripcionUbicacion = jsonDecode(resultadoNuevo.body)['respuesta'][0]["codigo_descripcion"];

            setState(() {
              datoInicial =
                  "La ubicación $descripcionUbicacion, tiene asignado el producto: " + jsonDecode(resultadoNuevo.body)['respuesta'][0]["Descripcion"];
            });
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: "La ubicación escaneada no tiene producto asignado",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
            );

            setState(() {
              datoInicial = "La ubicación escaneada no tiene producto asignado";
            });
          }
        });
      }
    }
  }

  Future<void> eleccionTipo() async {
    await _showAlertDialogTipoTransferencia(context, [
      {'Codigo': 1, 'Nombre': "Productos"},
      {'Codigo': 2, 'Nombre': "Ubicación"}
    ]).then((_) {
      // Nueva línea
      setState(() {
        seleccionTipoBusqueda = true;
      });
    });
  }

  Future<Widget> _showAlertDialogTipoTransferencia(BuildContext context, List<Map<String, dynamic>> items) async {
    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              scrollable: true,
              title: const Text('Seleccione el tipo de busqueda'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: items.map((item) {
                    final int codigo = item['Codigo'];
                    return RadioListTile(
                      title: Text(
                        item['Nombre'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      groupValue: tipoSeleccionado,
                      onChanged: (value) {
                        setState(() {
                          tipoSeleccionado = codigo;
                        });
                      },
                      value: codigo,
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () async {
                    Navigator.of(context).pop();
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
                    if (tipoSeleccionado == 0) {
                      Fluttertoast.showToast(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        msg: "Debe seleccionar el tipo de busqueda",
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    } else {
                      if (tipoSeleccionado == 1) {
                        setState(() {
                          datoInicial = "Escanee un producto..";
                        });
                      } else {
                        setState(() {
                          datoInicial = "Escanee una ubicación..";
                        });
                      }
                      iniciarScanner();

                      // obtenerDatosArea();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        });
      },
    );
    return const SizedBox(); //Aquí se devuelve un SizedBox como valor por defecto, se puede cambiar por otro Widget si se desea.
  }
}
