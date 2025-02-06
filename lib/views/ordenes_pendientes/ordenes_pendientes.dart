// ignore_for_file: import_of_legacy_library_into_null_safe, unused_local_variable, non_constant_identifier_names, unnecessary_null_comparison, unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';

import 'package:order_control/views/home/home.dart';
import 'package:image/image.dart' as img;
import 'package:barcode_image/barcode_image.dart';
import 'package:order_control/views/ordenes_pendientes/clase_generar.dart';
import 'package:order_control/views/ordenes_pendientes/clase_novedades_ordenes.dart';
import 'package:order_control/views/ordenes_pendientes/logica_adicional.dart';
import 'package:order_control/views/ordenes_pendientes/methods/metodos.dart';
import 'package:order_control/views/ordenes_pendientes/sqlite_ordenes.dart';
import 'package:path_provider/path_provider.dart';

import 'logica_ordener_pendientes.dart';

class OrdenesPendientes extends StatefulWidget {
  const OrdenesPendientes({Key? key}) : super(key: key);

  @override
  State<OrdenesPendientes> createState() => _OrdenesPendientesState();
}

class _OrdenesPendientesState extends State<OrdenesPendientes> {
  final SecureStorage _storage = SecureStorage();
  var tipoTransferencia = [];
  int tipoSeleccionado = 0;
  double tamanoTitulo = 18.0;
  double tamanoDescripcion = 15.0;
  String nombreSeleccionado = "";
  int _currentIndex = 0;
  int indiceNovedades = 0;
  late int productosDataIndex;
  bool validaContinuar = true;
  bool validaSaltar = true;
  int contador = 0;
  bool desabilitaBoton = true;
  bool activaManual = false;
  int cantidad = 0;
  bool validad = false;
  String codUsuario = "";
  int cantidadFaltantes = 0;
  bool valida = false;
  List<Ordenes> producto = [];
  List<Ordenes> copiaProductos = [];
  List<Novedades> novedad = [];
  String documento = "";
  bool seleccionoTipoTransferencia = false;
  double expandedContainerHeight = 350.0;
  double imageHeight = 225.0;
  double expandedContainerOffsetY = -20.0;
  bool activar = false;
  bool activarNovedades = false;
  bool comprobarEjecutado = false;
  bool comprobarNuevoValor = false;
  double alto = 170;
  double ancho = 350;
  File? _selectedImage;
  bool isExpanded = false;
  String codMovimiento = "";
  List<String> codigosUsuariosAutorizados = [];

  /*ESCANNER */
  StreamSubscription<dynamic>? fdwListener;
  var fdw = FlutterDataWedge(profileName: 'FlutterDataWedgeDatos');
  bool primerEscaneo = true; // Variable para verificar el primer escaneo
  bool agregarBarraAdicional = false;
  bool mensajeEscaneo = true;
  /*Ultima parte */
  final TextEditingController bultosControler = TextEditingController();
  final TextEditingController barrasControler = TextEditingController();
  final TextEditingController barrasManual = TextEditingController();
  final TextEditingController cantidadManual = TextEditingController();
  bool boton = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              documento,
              style: const TextStyle(color: Colors.white, fontSize: 15.0), //<-- SEE HERE
            ),
          ],
        ),
      ),
      body: datos(),
    );
  }

  @override
  void initState() {
    super.initState();
    datosIniciales();
  }

  @override
  void dispose() {
    fdwListener?.cancel();
    super.dispose();
  }

  NavigatorState? _navigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigator = Navigator.of(context);
  }

  Widget datos() {
    if (!seleccionoTipoTransferencia) {
      return circularPrimero();
    } else if (!valida) {
      return circularSegundo();
    } else {
      return principal();
    }
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
              Text('Cargando datos....'),
            ],
          ),
        ],
      ),
    );
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
              Text('Generando pedido....'),
            ],
          ),
        ],
      ),
    );
  }

  Widget principal() {
    Widget buildCardSecundario() {
      return FutureBuilder<Widget>(
        future: card(),
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

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < 0 && !isExpanded) {
          setState(() {
            expandedContainerHeight = 750.0;
            imageHeight = 125.0;
            expandedContainerOffsetY = -20.0;
            isExpanded = true;
            alto = 265.0;
            ancho = 350;
          });
        } else if (details.delta.dy > 0 && isExpanded) {
          setState(() {
            expandedContainerHeight = 350.0;
            imageHeight = 225.0;
            expandedContainerOffsetY = -20.0;
            alto = 150.0;
            ancho = 350;
            isExpanded = false;
          });
        }
      },
      child: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/imagen.png',
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10.0,
                right: 10.0,
                child: barra(_currentIndex, producto.length),
              ),
            ],
          ),
          Expanded(
            child: Transform.translate(
              offset: Offset(0.0, expandedContainerOffsetY),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: expandedContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(child: buildCardSecundario()),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget botonNotificar() {
    final productos = producto[_currentIndex];
    return IconButton(
        tooltip: "Notificar",
        color: Colors.red,
        onPressed: () async {
          var prueba = await notificarBoton(productos.rack, productos.clasificacion, productos.codProducto, int.parse(productos.codCargo.trim()),
              productos.codRecorrido, productos.codCodigo, productos.descripcion, productos.cantidad, cantidad, 2);
          var deco = jsonDecode(prueba.body);
          if (deco["msg"] == "ok") {
            Fluttertoast.showToast(
              backgroundColor: Colors.green,
              textColor: Colors.white,
              msg: "Notificación enviada",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
            );
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: "Ocurrió un error al notificar",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        },
        icon: const Icon(
          Icons.notifications,
        ));
  }

  Widget ubicacion() {
    final productos = producto[_currentIndex];
    return Row(
      children: [
        IconButton(color: Colores.esquemaColor, onPressed: () {}, icon: const Icon(Icons.location_on_rounded)),
        Text(productos.codRecorrido, style: const TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor, fontSize: 16.0)),
      ],
    );
  }

  Future<void> comprobar() async {
    final dbHelper = DbHeleprOrdernes();
    final List<Map<String, dynamic>> orders = await dbHelper.getAllOrders();
    List<Ordenes> productosFiltrados = [];

    for (var product in producto) {
      bool isProductInSQLite = orders.any((order) => order['Cod_Producto'] == product.codProducto);

      if (isProductInSQLite) {
        List<Map<String, dynamic>> ordersToRemove =
            orders.where((order) => order['Cod_Producto'] == product.codProducto && order['Cant_Real'] < product.cantidad).toList();

        if (ordersToRemove.isNotEmpty) {
          for (var order in ordersToRemove) {
            novedad.add(Novedades(
              codProducto: order['Cod_Producto'],
              producto: order['Producto'],
              lab: order['Lab'],
              cantidadFaltante: (product.cantidad - order['Cant_Real']).toInt(),
              cantidadEscaneada: order['Cant_Real'],
              cantidadFinal: product.cantidad,
            ));
          }
        } else {
          productosFiltrados.add(product);
        }
      } else {
        productosFiltrados.add(product);
      }
    }
    //print(productosFiltrados);
    if (productosFiltrados.isNotEmpty) {
      setState(() {
        copiaProductos = List.from(producto);
      });
      //producto.retainWhere((product) => productosFiltrados.contains(product));
      producto.removeWhere((product) => productosFiltrados.contains(product));
    }
    //producto=productosFiltrados;

    // print("novedades");
    // print(producto);
    if (novedad.isEmpty) {
      contador = producto.length;
      activarNovedades = false;
      comprobarNuevoValor = false;
    } else {
      _currentIndex = 0;
      contador = 1;
      activarNovedades = true;
      comprobarNuevoValor = true;
    }
  }

  Future<Widget> card() async {
    if (contador == producto.length || comprobarNuevoValor == true) {
      // Mostrar un widget en blanco o no hacer nada si se alcanza el final de la lista
      if (!activar) {
        if (!comprobarEjecutado) {
          await comprobar();
          comprobarEjecutado = true;
        }

        if (activarNovedades && comprobarNuevoValor) {
          return novedades();
        } else {
          return packing();
        }
      } else {
        return finalizado();
      }
    } else {
      final productos = producto[_currentIndex];

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: ubicacion(),
              ),
              /*Expanded(
                flex: 1,
                child: botonNotificar(),
              ),*/
            ],
          ),
          if (isExpanded) textosOpcionales(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(width: 1, color: Color.fromARGB(255, 230, 230, 230))),
                          ),
                          child: Card(
                            elevation: 0,
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
                                                Icon(Icons.shopping_cart_rounded, color: Colores.esquemaColor, size: 60),
                                              ],
                                            ),
                                          )),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 250,
                                                child: Text(
                                                  productos.descripcion,
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
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Text(productos.laboratorio),
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      botonAgregar(),
                                      if (activaManual) botonAgregarManualmente(),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 13.0),
                                        child: Text(
                                          'Cantidad: $cantidad/${productos.cantidad}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      IconButton(
                                        tooltip: "Saltar",
                                        onPressed: boton
                                            ? null
                                            : () async {
                                                setState(() {
                                                  boton = true;
                                                });

                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (BuildContext context) {
                                                    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                                      return AlertDialog(
                                                        scrollable: true,
                                                        title: const Text('¿Está seguro de saltar el producto?'),
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
                                                            onPressed: validaSaltar
                                                                ? () async {
                                                                    Fluttertoast.showToast(
                                                                      backgroundColor: Colors.orange.shade300,
                                                                      textColor: Colors.white,
                                                                      msg: "Espere un momento por favor...",
                                                                      gravity: ToastGravity.BOTTOM,
                                                                      toastLength: Toast.LENGTH_SHORT,
                                                                    );

                                                                    setState(() {
                                                                      validaSaltar = false;
                                                                    });
                                                                    if (codigosUsuariosAutorizados.contains(codUsuario)) {
                                                                      await insertarDatos(cantidad);
                                                                      _nextProduct();
                                                                      setState(() {
                                                                        validaSaltar = true;
                                                                      });
                                                                      // Aquí puedes agregar la lógica que deseas ejecutar cuando se presiona el botón "Aceptar"
                                                                      Navigator.of(context).pop();
                                                                    } else {
                                                                      var prueba = await notificar(
                                                                        productos.rack,
                                                                        productos.clasificacion,
                                                                        productos.codProducto,
                                                                        int.parse(productos.codCargo.trim()),
                                                                        productos.codRecorrido,
                                                                        productos.codCodigo,
                                                                        productos.descripcion,
                                                                        productos.cantidad,
                                                                        cantidad,
                                                                        1,
                                                                      );

                                                                      if (prueba != null) {
                                                                        var deco = jsonDecode(prueba.body);
                                                                        if (deco["msg"] == "ok") {
                                                                          await insertarDatos(cantidad);
                                                                          _nextProduct();
                                                                          setState(() {
                                                                            validaSaltar = true;
                                                                          });
                                                                          // Aquí puedes agregar la lógica que deseas ejecutar cuando se presiona el botón "Aceptar"
                                                                          Navigator.of(context).pop();
                                                                        } else {
                                                                          Fluttertoast.showToast(
                                                                            backgroundColor: Colors.red,
                                                                            textColor: Colors.white,
                                                                            msg: "Error comuníquese con el administrador",
                                                                            gravity: ToastGravity.BOTTOM,
                                                                            toastLength: Toast.LENGTH_SHORT,
                                                                          );
                                                                        }
                                                                      } else {
                                                                        Fluttertoast.showToast(
                                                                          backgroundColor: Colors.red,
                                                                          textColor: Colors.white,
                                                                          msg: "El producto no está asignado correctamente",
                                                                          gravity: ToastGravity.BOTTOM,
                                                                          toastLength: Toast.LENGTH_SHORT,
                                                                        );
                                                                        await insertarDatos(cantidad);
                                                                        _nextProduct();
                                                                        setState(() {
                                                                          validaSaltar = true;
                                                                        });
                                                                        // Aquí puedes agregar la lógica que deseas ejecutar cuando se presiona el botón "Aceptar"
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                    }
                                                                  }
                                                                : null,
                                                          ),
                                                        ],
                                                      );
                                                    });
                                                  },
                                                ).then((_) {
                                                  setState(() {
                                                    boton = false;
                                                  });
                                                });
                                              },
                                        icon: const Icon(
                                          Icons.keyboard_double_arrow_right_sharp,
                                          color: Colores.esquemaColor,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        cardSecundario(),
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

  Widget novedades() {
    final noved = novedad[_currentIndex];
    fdwListener?.cancel();
    // print(_currentIndex);
    cantidad = noved.cantidadEscaneada;
    cantidadFaltantes = noved.cantidadFaltante;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: Center(
                child: Text(
                  "Productos con novedades",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colores.esquemaColor,
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(width: 1, color: Color.fromARGB(255, 230, 230, 230))),
              ),
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
                                Icon(Icons.shopping_cart_rounded, color: Colores.esquemaColor, size: 60),
                              ],
                            ),
                          )),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 250,
                                child: Text(
                                  noved.producto,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colores.esquemaColor,
                                  ),
                                  maxLines: 3,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(noved.lab),
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //
                      botonAgregarManualmente2(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 13.0),
                        child: Text(
                          'Cantidad: ${noved.cantidadEscaneada} /${noved.cantidadFinal}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      IconButton(
                          tooltip: "Saltar",
                          onPressed: () async {
                            //  print("Contador $contador");
                            //  print("Longitud ${producto.length}");
                            if (contador == producto.length) {
                              setState(() {
                                activarNovedades = false;
                              });
                            }
                            _nextProduct();
                            // Aquí puedes agregar la lógica que deseas ejecutar cuando se presiona el botón "Aceptar"
                          },
                          icon: const Icon(Icons.keyboard_double_arrow_right_sharp, color: Colores.esquemaColor, size: 30)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget botonAgregar() {
    final focusNode = FocusNode();
    final productos = producto[_currentIndex];
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: IconButton(
        tooltip: "Agregar",
        onPressed: () async {
          setState(() {
            agregarBarraAdicional = true;
          });

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              fdwListener?.cancel();
              iniciarScannerManual();
              return StatefulBuilder(builder: (context, setState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FocusScope.of(context).requestFocus(focusNode);
                });

                return WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    scrollable: true,
                    title: const Text('Añadir código de barra adicional'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text("Escanee el producto a agregar"),
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
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          setState(() {
                            agregarBarraAdicional = false;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Aceptar'),
                        onPressed: () async {
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
                                  token, 'agregar_cod_barra_adicional', 10, barrasControler.text, int.parse(codUsuario), productos.codProducto);
                              var decodificado = jsonDecode(guardarBarra.body);
                              if (decodificado["msg"] == "ok") {
                                setState(() {
                                  agregarBarraAdicional = false;
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
                                              builder: (BuildContext context) => const OrdenesPendientes(),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        confirmButtonColor: Colores.esquemaColor));
                              } else {
                                Fluttertoast.showToast(
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  msg: "Error al guardar el código de barra",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              }
                            } on TimeoutException catch (e) {
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
                        },
                      ),
                    ],
                  ),
                );
              });
            },
          );
        },
        icon: const Icon(
          Boxicons.bx_plus_circle,
          color: Colores.esquemaColor,
          size: 25,
        ),
      ),
    );
  }

  Widget botonAgregarManualmente2() {
    iniciarScannerManual();
    final productos = producto[_currentIndex];
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: IconButton(
        tooltip: "Agregar",
        onPressed: () async {
          setState(() {
            agregarBarraAdicional = true;
          });
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    scrollable: true,
                    title: const Text('Ingrese el código de barras'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text("Código de barra"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextField(
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.number,
                            controller: barrasManual,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextField(
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.number,
                            controller: cantidadManual,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Boxicons.bxs_cart_add,
                                size: 24,
                                color: Colores.esquemaColor,
                              ),
                              labelText: 'Cantidad',
                              hintText: "Cantidad",
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
                        child: const Text('Aceptar'),
                        onPressed: () async {
                          String text = barrasManual.text;
                          int cantidadM = int.parse(cantidadManual.text);
                          if ((productos.codBarra.trim() == text || productos.codBarraAdicional.contains(text)) &&
                              (cantidadFaltantes >= cantidadM && cantidadM > 0)) {
                            cantidad = cantidad + cantidadM;

                            DbHeleprOrdernes _dbhelper = DbHeleprOrdernes();
                            await _dbhelper.updateProductQuantityReal(productos.codProducto, cantidad);
                            if (contador == producto.length) {
                              setState(() {
                                activarNovedades = false;
                              });
                            }
                            Navigator.of(context).pop();
                            _nextProduct();
                          } else {
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              msg: "El producto no es correcto o la cantidad no corresponde",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              });
            },
          );
        },
        icon: const Icon(
          Boxicons.bx_notepad,
          color: Colores.esquemaColor,
          size: 25,
        ),
      ),
    );
  }

  Widget botonAgregarManualmente() {
    final productos = producto[_currentIndex];
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: IconButton(
        tooltip: "Agregar",
        onPressed: () async {
          setState(() {
            agregarBarraAdicional = true;
          });
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              fdwListener?.cancel();
              iniciarScannerManual();
              return StatefulBuilder(builder: (context, setState) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    scrollable: true,
                    title: const Text('Ingrese el código de barras'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text("Código de barra"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextField(
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.number,
                            controller: barrasManual,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextField(
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.number,
                            controller: cantidadManual,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Boxicons.bxs_cart_add,
                                size: 24,
                                color: Colores.esquemaColor,
                              ),
                              labelText: 'Cantidad',
                              hintText: "Cantidad",
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          setState(() {
                            agregarBarraAdicional = false;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Aceptar'),
                        onPressed: () async {
                          String text = barrasManual.text;
                          int cantidadM = int.parse(cantidadManual.text);
                          if ((productos.codBarra.trim() == text || productos.codBarraAdicional.contains(text)) &&
                              (productos.cantidad >= cantidadM && cantidadM > 0)) {
                            await insertarDatos(cantidadM);
                            setState(() {
                              agregarBarraAdicional = false;
                            });
                            if (cantidadM < productos.cantidad) {
                              var prueba = await notificar(
                                  productos.rack,
                                  productos.clasificacion,
                                  productos.codProducto,
                                  int.parse(productos.codCargo.trim()),
                                  productos.codRecorrido,
                                  productos.codCodigo,
                                  productos.descripcion,
                                  productos.cantidad,
                                  cantidadM,
                                  1);
                              var dato = jsonDecode(prueba.body);
                              if (dato["msg"] != "ok") {
                                Fluttertoast.showToast(
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  msg: "No se pudo enviar la notificación",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              }
                            }
                            fdwListener?.cancel();
                            Navigator.of(context).pop();
                            _nextProduct();
                            iniciarScanner();
                          } else {
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              msg: "El producto no es correcto o la cantidad no corresponde",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              });
            },
          );
        },
        icon: const Icon(
          Boxicons.bx_notepad,
          color: Colores.esquemaColor,
          size: 25,
        ),
      ),
    );
  }

  Widget packing() {
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
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: Center(
                                  child: Text(
                                    "Esperando proceso de packing..",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colores.esquemaColor,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Image.asset(
                                  'assets/images/nomo.gif',
                                  width: ancho,
                                  height: alto,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                            return AlertDialog(
                                              scrollable: true,
                                              title: const Text('¿Está seguro de continuar el proceso?'),
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
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Aceptar'),
                                                  onPressed: validaContinuar
                                                      ? () async {
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
                                                          } else if (int.parse(bultosControler.text) > 40) {
                                                            Fluttertoast.showToast(
                                                              backgroundColor: Colors.red,
                                                              textColor: Colors.white,
                                                              msg: "Error, no puede enviar más de 40 bultos",
                                                              gravity: ToastGravity.BOTTOM,
                                                              toastLength: Toast.LENGTH_SHORT,
                                                            );
                                                          } else {
                                                            if (producto.isNotEmpty) {
                                                              setState(() {
                                                                validaContinuar = false;
                                                              });
                                                              Fluttertoast.showToast(
                                                                backgroundColor: Colors.orange.shade300,
                                                                textColor: Colors.white,
                                                                msg: "Enviando datos, espere por favor...",
                                                                gravity: ToastGravity.BOTTOM,
                                                                toastLength: Toast.LENGTH_SHORT,
                                                              );

                                                              await guardar(bultosControler.text, producto);
                                                              Navigator.of(context).pop();
                                                              Fluttertoast.showToast(
                                                                backgroundColor: Colors.green,
                                                                textColor: Colors.white,
                                                                msg: "Correcto",
                                                                gravity: ToastGravity.BOTTOM,
                                                                toastLength: Toast.LENGTH_SHORT,
                                                              );
                                                            } else {
                                                              String dato = await _storage.readSecureData("codRecorridos");
                                                              String token = await _storage.readSecureData("token");

                                                              var jsonDataArea = await verificarOrdenesCargadas(
                                                                  token, "obtener_data_por_usuario", 10, documento, int.tryParse(dato) ?? 0);

                                                              List<Ordenes> nuevoProducto = parseOrdernes(jsonDataArea.body);
                                                              Fluttertoast.showToast(
                                                                backgroundColor: Colors.orange.shade300,
                                                                textColor: Colors.white,
                                                                msg: "Enviando datos, espere por favor...",
                                                                gravity: ToastGravity.BOTTOM,
                                                                toastLength: Toast.LENGTH_SHORT,
                                                              );

                                                              setState(() {
                                                                validaContinuar = false;
                                                              });
                                                              await guardar(bultosControler.text, nuevoProducto);
                                                              Navigator.of(context).pop();
                                                              Fluttertoast.showToast(
                                                                backgroundColor: Colors.green,
                                                                textColor: Colors.white,
                                                                msg: "Correcto",
                                                                gravity: ToastGravity.BOTTOM,
                                                                toastLength: Toast.LENGTH_SHORT,
                                                              );

                                                              //producto = ;
                                                            }
                                                          }
                                                          /* await insertarDatos(cantidad);
                                                  _nextProduct();*/
                                                          // Aquí puedes agregar la lógica que deseas ejecutar cuando se presiona el botón "Aceptar"
                                                        }
                                                      : null,
                                                ),
                                              ],
                                            );
                                          });
                                        },
                                      );
                                    },
                                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Text("Continuar"),
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
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Future<List<Map<String, dynamic>>> calcularCantidadesFaltantes(List<Ordenes> listaOrdenes, List<Map<String, dynamic>> orders) async {
    List<Map<String, dynamic>> resultados = [];

    for (var orden in listaOrdenes) {
      var ordenEncontrada = orders.firstWhere(
        (o) => o['Cod_Producto'] == orden.codProducto,
        orElse: () => {},
      );

      if (ordenEncontrada.isNotEmpty) {
        int cantU = ordenEncontrada['Cant_U'] ?? 0;
        int cantidadFaltante = orden.cantidad - cantU;

        resultados.add({
          'codProducto': orden.codProducto,
          'cantidadFaltante': cantidadFaltante,
        });
      }
    }

    return resultados;
  }

  Future<void> guardar(String bultos, List<Ordenes> productoss) async {
    final productos = productoss[0];

    final dbHelper = DbHeleprOrdernes();

    String token = await _storage.readSecureData("token");

    int bodegaDestino = productos.codBodega;
    int bodegaOrigen = productos.codBodegaTran;

    String observacion = productos.observacionOrden;

    String codUsuario = await _storage.readSecureData("cod_usuario");
    String codSesion = await _storage.readSecureData("codSesion");
    String valorIva = await _storage.readSecureData("valorIva");
    int valor = int.parse(valorIva);
    String cedulaTransportista = productos.cedula;
    String razonSocial = productos.razonSocial;
    String placa = productos.placa;
    int confirmacionIngreso = productos.cargarDestino;
    final List<Map<String, dynamic>> orders = await dbHelper.getAllOrders();

    List<Map<String, dynamic>> datanueva = await calcularCantidadesFaltantes(copiaProductos.isNotEmpty ? copiaProductos : producto, orders);
    int validad = datanueva.isNotEmpty ? 1 : 0;
    List<Map<String, dynamic>> ordersWithNonZeroCantReal = [];
    double totalCero = 0;
    double totalIva = 0;
    double BaseIva = 0;

    for (var order in orders) {
      if (order['Cant_Real'] > 0) {
        ordersWithNonZeroCantReal.add(order);
      }
    }
    for (var order in ordersWithNonZeroCantReal) {
      double parcial = order['Parcial'];
      double parcial2 = order['Parcial'];

      int ivaProducto = order['ivaProducto'];

      if (ivaProducto == 1) {
        BaseIva += parcial2;
        parcial += (parcial * (valor / 100));
        totalIva += parcial;
      } else {
        totalCero += parcial;
      }
    }

    var guardarPedidoFinal = await guardarPedido(
        token,
        "guardar_pedido",
        10,
        175,
        int.parse(codSesion),
        bodegaOrigen,
        bodegaDestino,
        documento,
        totalCero,
        totalIva,
        totalIva * (valor / 100),
        totalCero + totalIva + totalIva * (valor / 100),
        observacion,
        3,
        int.parse(codUsuario),
        cedulaTransportista.trim(),
        placa.trim(),
        ordersWithNonZeroCantReal,
        razonSocial,
        int.parse(bultos),
        10,
        confirmacionIngreso,
        validad,
        datanueva);
    var jsonGuardar = jsonDecode(guardarPedidoFinal.body);

    if (jsonGuardar["msg"] != "err") {
      await _storage.deleteSecureData("codigoMovimiento");
      await _storage.deleteSecureData("codRecorridos");
      await _storage.writeSecureData("codigoMovimiento", jsonGuardar["resultado"][0]["Cod_Impresion2"].toString());
      final dbHelper = DbHeleprOrdernes();

      await dbHelper.clearProductos();
      datosIniciales();
      /*await generarImagen(jsonGuardar["resultado"][0]["Cod_Impresion2"].toString());
      setState(() {
        activar = true;
      });*/
    } else {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Error, comuníquese con el administrador",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Widget finalizado() {
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
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Center(
                                    child: Text(
                                  "Orden terminada!!!",
                                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colores.esquemaColor),
                                )),
                              ),
                              Image.file(_selectedImage!),
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
                                              final dbHelper = DbHeleprOrdernes();
                                              // Aquí puedes agregar la lógica que deseas ejecutar cuando se presiona el botón "Aceptar".
                                              await _storage.deleteSecureData("codigoMovimiento");
                                              await _storage.deleteSecureData("codRecorridos");
                                              await dbHelper.clearProductos();
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
                          ),
                        ),
                      ),
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

  Widget textosOpcionales() {
    final productosData = producto[_currentIndex];

    return Container(
      height: 70,
      alignment: Alignment.center,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nombreSeleccionado,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: tamanoTitulo),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Rack: ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: tamanoTitulo),
                      ),
                      Text(
                        productosData.rack.toString(),
                        style: TextStyle(fontSize: tamanoDescripcion),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Sección: ",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: tamanoTitulo),
                      ),
                      Text(productosData.seccion.toString(), style: TextStyle(fontSize: tamanoDescripcion)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Altura: ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: tamanoTitulo),
                      ),
                      Text(productosData.altura.toString(), style: TextStyle(fontSize: tamanoDescripcion))
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Ubicación: ",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: tamanoTitulo),
                      ),
                      Text(productosData.ubicacion.toString(), style: TextStyle(fontSize: tamanoDescripcion))
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget cardSecundario() {
    final index = _currentIndex + 1;
    final hasNextProduct = index < producto.length;
    final comprueba = index == producto.length;
    if (hasNextProduct) {
      final product = producto[index];
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Siguiente producto",
                            style: TextStyle(fontSize: 10.0),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 280,
                            child: Text(
                              product.descripcion,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colores.esquemaColor,
                              ),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colores.esquemaColor,
                          ),
                          Text(product.codRecorrido),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                  const Icon(Icons.shopping_cart_rounded, size: 20.0, color: Colores.esquemaColor)
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      setState(() {
        desabilitaBoton = false;
      });
      return const Center(
        child: Text("Último producto"),
      );
    }
  }

  Widget barra(int progreso, int total) {
    if (total == 0) {
      // No hay progreso, muestra una barra vacía
      return const SizedBox.shrink();
    }

    final double value = progreso.toDouble() / total.toDouble();

    if (value.isNaN || value.isInfinite) {
      // Valor no válido, muestra una barra vacía
      return const SizedBox.shrink();
    }
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          LinearProgressIndicator(
            value: progreso / total,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Future<dynamic> notificar(int rack, int clasificacion, int codProducto, int codCargo, String ubicacion, int codUbicacion,
      String descripcionProducto, int cantidadReal, int cantidadEscaneada, int tipo) async {
    // var canales=[];
    //FSGCANALJEFEBODEGA001
    String token = await _storage.readSecureData("token");
    var canal = await obtenerCanales(token, "obtener_canal", 8, rack, clasificacion);
    String orden = await _storage.readSecureData("codRecorridos");
    var response = jsonDecode(canal.body);

// Verifica si 'resultado' existe y tiene al menos un elemento
    if (response.containsKey("resultado") && response["resultado"].isNotEmpty) {
      var canalDecodificado = response["resultado"][0]["Canal_Notificacion"];

      // Continúa con el resto de tu lógica si canalDecodificado no es null
      if (canalDecodificado != null) {
        var usuario = jsonDecode(canal.body)["resultado"][0]["Cod_Usuario"];

        String codUsuario = await _storage.readSecureData("cod_usuario");
        //String canal = await _storage.readSecureData("canal");
        String nombre = await _storage.readSecureData("Nombre");
        String tokenUsuario = await _storage.readSecureData("token_firebase");
        var dato = await enviarNotificacion(usuario, token, "enviar-notificacion", 9, ubicacion, int.parse(codUsuario), nombre, codProducto,
            codUbicacion, tokenUsuario, codCargo, descripcionProducto, canalDecodificado, cantidadReal, cantidadEscaneada, int.parse(orden), tipo);
        return dato;
      } else {
        // Manejo del caso donde canalDecodificado es null
        return null;
      }
    } else {
      // Manejo del caso donde 'resultado' no existe o está vacío
      return null;
    }
  }

  Future<dynamic> notificarBoton(int rack, int clasificacion, int codProducto, int codCargo, String ubicacion, int codUbicacion,
      String descripcionProducto, int cantidadReal, int cantidadEscaneada, int tipo) async {
    String token = await _storage.readSecureData("token");
    var canal = await obtenerCanales(token, "obtener_canal", 8, rack, clasificacion);
    String orden = await _storage.readSecureData("codRecorridos");
    var canalDecodificado = jsonDecode(canal.body)["resultado"][0]["Canal_Notificacion"];
    var usuario = jsonDecode(canal.body)["resultado"][0]["Cod_Usuario"];

    String codUsuario = await _storage.readSecureData("cod_usuario");
    //String canal = await _storage.readSecureData("canal");
    String nombre = await _storage.readSecureData("Nombre");
    String tokenUsuario = await _storage.readSecureData("token_firebase");
    var dato = await enviarNotificacion(usuario, token, "enviar-notificacion-normal", 9, ubicacion, int.parse(codUsuario), nombre, codProducto,
        codUbicacion, tokenUsuario, codCargo, descripcionProducto, canalDecodificado, cantidadReal, cantidadEscaneada, int.parse(orden), tipo);
    return dato;
  }

  void _nextProduct() {
    setState(() {
      productosDataIndex = productosDataIndex + 1;
      contador = contador + 1;
      barrasManual.text = "";
      cantidadManual.text = "";
      _currentIndex = (_currentIndex + 1) % producto.length;
      cantidad = 0;
      primerEscaneo = true;
      validad = false;
      activaManual = false;
    });
  }

  Future<void> obtenerDatosArea() async {
    String token = await _storage.readSecureData("token");
    String codUsuario = await _storage.readSecureData("cod_usuario");
    final dbHelper = DbHeleprOrdernes();
    await _storage.deleteSecureData("codigoMovimiento");
    await _storage.deleteSecureData("codRecorridos");
    await dbHelper.clearProductos();
    try {
      var obtenerRecorrido = await obtenerDatosReccorrido(token, "obtener_recorridos", 10);
      var datos = jsonDecode(obtenerRecorrido.body);
      print("Recorrido");
      print(datos);
      int valor = 0;
      if (datos["msg"] == "ok" && datos["respuesta"] == null) {
        setState(() {
          valor = 1;
        });
        await _storage.writeSecureData("codRecorridos", valor.toString());
      } else if (datos["msg"] == "ok" && datos["respuesta"][0]["Cod_Bode_Recorrido"] == 1) {
        setState(() {
          valor = 2;
        });
        await _storage.writeSecureData("codRecorridos", valor.toString());
      } else if (datos["msg"] == "ok" && datos["respuesta"][0]["Cod_Bode_Recorrido"] == 2) {
        setState(() {
          valor = 1;
        });
        await _storage.writeSecureData("codRecorridos", valor.toString());
      } else if (tipoSeleccionado == 1 && datos["msg"] == "ok" && datos["respuesta"][0]["Cod_Bode_Recorrido"] == 3) {
        setState(() {
          valor = 1;
        });
        await _storage.writeSecureData("codRecorridos", valor.toString());
      } else if (tipoSeleccionado == 1 && datos["msg"] == "ok" && datos["respuesta"][0]["Cod_Bode_Recorrido"] == 4) {
        setState(() {
          valor = 1;
        });
        await _storage.writeSecureData("codRecorridos", valor.toString());
      } else if (tipoSeleccionado == 1 && datos["msg"] == "ok" && datos["respuesta"][0]["Cod_Bode_Recorrido"] == 5) {
        setState(() {
          valor = 1;
        });
        await _storage.writeSecureData("codRecorridos", valor.toString());
      }
      if (tipoSeleccionado == 4) {
        setState(() {
          valor = 4;
        });
        await _storage.writeSecureData("codRecorridos", valor.toString());
      }
      if (tipoSeleccionado == 5) {
        setState(() {
          valor = 5;
        });
        await _storage.writeSecureData("codRecorridos", valor.toString());
      }
      var jsonDataArea = await obtenerDatosPorArea(token, "obtener_data_por_area_seleccionada", 20, codUsuario, tipoSeleccionado, valor);
      var msgPlanificacioneArea = jsonDecode(jsonDataArea.body)["msg"];
      var decodificado = jsonDecode(jsonDataArea.body);

      if (msgPlanificacioneArea != "err") {
        await enviarRecorrido(token, "enviar_recorrido", 10, codUsuario, valor);

        producto = parseOrdernes(jsonDataArea.body);
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Orden generada!",
                text: "Su recorrido empieza por el Rack: ${jsonDecode(jsonDataArea.body)["respuesta"][0]["Rack"]}",
                confirmButtonText: "Aceptar",
                onConfirm: () async {
                  Navigator.pop(context);
                },
                confirmButtonColor: Colores.esquemaColor));

        iniciarScanner();
        setState(() {
          documento = jsonDecode(jsonDataArea.body)["respuesta"][0]["Cod_Cargo"];
          valida = true;
        });
        await generarImagen(documento);
      } else {
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                text: decodificado["mensaje"].toString(),
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
    } on TimeoutException catch (e) {
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

  Future<void> datosIniciales() async {
    try {
      String token = await _storage.readSecureData("token");

      codUsuario = await _storage.readSecureData("cod_usuario");

      codMovimiento = await _storage.readSecureData("codigoMovimiento") ?? "";

      if (codMovimiento != "") {
        await generarImagen(codMovimiento);
        setState(() {
          activar = true;
          seleccionoTipoTransferencia = true;
          valida = true;
        });
      } else {
        var verificacion = await verificarOrdenes(token, "verificar_ordenes", 10, codUsuario);

        if (jsonDecode(verificacion.body)["msg"] == "ok") {
          obtenerDatoUsuario(token, jsonDecode(verificacion.body)["tipoTranferencia"][0]["Cod_Cargo"]);
        } else {
          var jsonPlanificaciones = await obtenerOrdenesDatosIniciales(token, "obtener_tipo_transferencia", 10);

          var msgPlanificaciones = jsonDecode(jsonPlanificaciones.body)["msg"];
          if (msgPlanificaciones != "err") {
            var usuariosAutorizadoss = await obtenerUsuariosAutorizados(token, "obtener_usuario_autorizados", 10);
            var decodifica = jsonDecode(usuariosAutorizadoss.body);
            var usuariosAutorizados = decodifica['usuariosAutorizados'] as List;
            setState(() {
              codigosUsuariosAutorizados = usuariosAutorizados.map((u) => u['Cod_Usuario'].toString()).toList();
              tipoTransferencia = jsonDecode(jsonPlanificaciones.body)["tipoTranferencia"];

              /*if (codUsuario != "263" && codUsuario != "508" && codUsuario != "457") {
                tipoTransferencia.removeWhere((element) => element["Codigo"] == 4 || element["Codigo"] == 5);
              }*/
              if (!codigosUsuariosAutorizados.contains(codUsuario)) {
                tipoTransferencia.removeWhere((element) => element["Codigo"] == 4 || element["Codigo"] == 5);
              }

              _showAlertDialogTipoTransferencia(
                context,
                tipoTransferencia.cast<Map<String, dynamic>>(),
              ).then((_) {
                // Nueva línea
                setState(() {
                  seleccionoTipoTransferencia = true;
                });
              });
            });
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: "Error, comuníquese con el administrador",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        }
      }
    } on TimeoutException catch (e) {
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

  Future<void> obtenerDatoUsuario(String token, String codCargo) async {
    try {
      // Obtener los datos del usuario mediante una llamada asíncrona
      String dato = await _storage.readSecureData("codRecorridos");
      //print(dato);
      var jsonDataArea = await verificarOrdenesCargadas(token, "obtener_data_por_usuario", 10, codCargo, int.parse(dato));

      final dbHelper = DbHeleprOrdernes();

      // await dbHelper.updateProductQuantityReal(68, 0);
      // Extraer el mensaje de la respuesta obtenida

      var msgPlanificacioneArea = jsonDecode(jsonDataArea.body)["msg"];

      //print(jsonDecode(jsonDataArea.body));
      if (msgPlanificacioneArea != "err") {
        // Parsear los datos obtenidos y asignarlos a la variable "producto"
        producto = parseOrdernes(jsonDataArea.body);

        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.info,
                title: "Orden Restaurada!!!",
                text: "Usted Tiene un pedido pendiente",
                confirmButtonText: "Aceptar",
                onConfirm: () async {
                  Navigator.pop(context);
                },
                confirmButtonColor: Colores.esquemaColor));
        // Obtener todos los pedidos de la base de datos SQLite
        List<Map<String, dynamic>> orders = await dbHelper.getAllOrders();

        // Verificar si el producto actual está presente en SQLite
        bool isProductInSQLite = orders.any((order) => order['Cod_Producto'] == producto[_currentIndex].codProducto);

        // Si el producto está presente, hace un recorrido por todos hasta que no encuentre uno e incremental los indices
        if (isProductInSQLite) {
          while (_currentIndex < producto.length && orders.any((order) => order['Cod_Producto'] == producto[_currentIndex].codProducto)) {
            _currentIndex++; // Pasar al siguiente producto
          }
          setState(() {
            contador = _currentIndex;
          });
        }

        // Iniciar el escáner
        iniciarScanner();
        // Actualizar el estado de las variables
        setState(() {
          documento = jsonDecode(jsonDataArea.body)["respuesta"][0]["Cod_Cargo"];
          valida = true;
          seleccionoTipoTransferencia = true;
        });
        // Generar la imagen
        await generarImagen(documento);
      } else {
        // Mostrar una alerta de error
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: "Error, comuníquese con el administrador",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } on TimeoutException catch (e) {
      // Mostrar una alerta de error en caso de que ocurra un TimeOut
      await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error $e",
              text: "Comuníquese con el administrador",
              confirmButtonText: "Aceptar",
              onConfirm: () async {
                Navigator.pop(context);
              },
              confirmButtonColor: Colores.esquemaColor));
    }
  }

  void iniciarScanner() async {
    if (Platform.isAndroid) {
      await fdw.initialize();
      fdwListener = fdw.onScanResult.listen((ScanResult code) async {
        if (comprobarNuevoValor) {
          final productosData = producto[_currentIndex];
          final codBarra = code.data.toString().trim();
          if (productosData.codBarra.trim() == codBarra || productosData.codBarraAdicional.contains(codBarra)) {
            cantidad = cantidad + 1;
            //print(cantidad);
            if (productosData.cantidad == cantidad) {
              final dbHelper = DbHeleprOrdernes();

              await dbHelper.updateProductQuantityReal(productosData.codProducto, cantidad);
              _nextProduct();
            }
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: "El producto escaneado no es correcto",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
            );
          }
          if (contador == producto.length) {
            setState(() {
              activarNovedades = false;
            });
          }
        } else {
          final productosData = producto[_currentIndex];
          /*if (primerEscaneo && !agregarBarraAdicional && !validad) {
            final codigo = code.data.toString().replaceAll(RegExp(r'\D'), '');
            if (productosData.codigoRecorrido.trim() == codigo || productosData.codCodigo.toString().trim() == codigo) {
              setState(() {
                primerEscaneo = false;
                activaManual = true;
                validad = true;
              });
              Fluttertoast.showToast(
                backgroundColor: Colors.blue.shade200,
                textColor: Colors.black,
                msg: "Ubicación verificada con éxito!",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT,
              );
            } else {
              sounidoError();
              Fluttertoast.showToast(
                backgroundColor: Colors.red,
                textColor: Colors.white,
                msg: "La ubicación escaneada no es la correcta",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT,
              );

              setState(() {
                //primerEscaneo = false;
                activaManual = false;
                validad = false;
                //agregarBarraAdicional = true;
              });
              // return;
            }
            // Desactiva el primer escaneo
          } else*/ if (_currentIndex == productosDataIndex && !agregarBarraAdicional /*&& validad*/) {
            final codBarra = code.data.toString().trim();
            if (productosData.codBarra.trim() == codBarra || productosData.codBarraAdicional.contains(codBarra)) {
              if (mensajeEscaneo) {
                setState(() {
                  mensajeEscaneo = false;
                  cantidad++;
                });

                if (productosData.cantidad == cantidad) {
                  await insertarDatos(cantidad);
                  _nextProduct();
                }
                Fluttertoast.showToast(
                  backgroundColor: Colors.blue.shade200,
                  textColor: Colors.black,
                  msg: "Producto verificado!",
                  gravity: ToastGravity.BOTTOM,
                  toastLength: Toast.LENGTH_SHORT,
                );
              } else {
                setState(() {
                  cantidad = cantidad + 1;
                });

                if (productosData.cantidad == cantidad) {
                  await insertarDatos(cantidad);
                  _nextProduct();
                }
              }
            } else {
              sounidoErrorProducto();
              Fluttertoast.showToast(
                backgroundColor: Colors.red,
                textColor: Colors.white,
                msg: "El producto escaneado no es correcto",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          } else {}
        }
      });
    }

    productosDataIndex = _currentIndex;
  }

  void iniciarScannerManual() async {
    if (Platform.isAndroid) {
      fdwListener = fdw.onScanResult.listen((code) async {
        debugPrint("Jodeesrasdasdasdasd");
      });
    }
  }

  Future<void> insertarDatos(int cantidadEscaneada) async {
    final productos = producto[_currentIndex];
    final dbHelper = DbHeleprOrdernes();
    final orden = ordenesPendientes(
        Cod_Producto: productos.codProducto,
        Producto: productos.descripcion,
        Lab: productos.siglas,
        Cant_U: cantidadEscaneada,
        Cant_F: 0,
        Costo: productos.costo,
        Parcial: cantidadEscaneada * productos.costo,
        Fraccion: productos.fraccion,
        Cod_Compra: 0,
        Cant_Real: cantidadEscaneada,
        ivaProducto: productos.ivaProducto);

    await dbHelper.insertProducto(orden);
    //}
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
              title: const Text('Seleccione el tipo de transferencia'),
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
                          nombreSeleccionado = item["Nombre"];
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
                        msg: "Debe seleccionar al menos un tipo de transferencia",
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    } else {
                      obtenerDatosArea();
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

  Future<void> generarImagen(String datos) async {
    setState(() {
      _selectedImage = null;
    });
    final image = img.Image(400, 200);
    img.fill(image, img.getColor(255, 255, 255));

    drawBarcode(image, Barcode.code128(), datos);
    final png = img.encodePng(image);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/barcode.jpg';
    final file = await File(filePath).writeAsBytes(png);
    setState(() {
      _selectedImage = file;
    });
  }
}
