// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/complements/ubicaciones/logica_productos.dart';
import 'package:order_control/complements/ubicaciones/logica_registrar_ubicaciones.dart';
import 'package:order_control/complements/ubicaciones/logica_ubicaciones.dart';
import 'package:order_control/complements/ubicaciones/sqlite.dart';
import 'package:order_control/complements/ubicaciones/sqlite_ubicaciones.dart';
import 'package:order_control/complements/ubicaciones/user.dart';
import 'package:order_control/complements/ubicaciones/utils.dart';
import 'package:order_control/views/home/home.dart';

class RegistrarUbicaciones extends StatefulWidget {
  const RegistrarUbicaciones({
    Key? key,
  }) : super(key: key);
  @override
  State<RegistrarUbicaciones> createState() => _RegistrarUbicacionesState();
}

class _RegistrarUbicacionesState extends State<RegistrarUbicaciones> {
  StreamSubscription<dynamic>? fdwListener;
  List<User> users = [];
  var usuarios = <User>[];
  List<DataRow> _rows = [];
  int _counter = 1;
  bool boton = true;
  final SecureStorage _storage = SecureStorage();
  bool valida = false;
  var fdw = FlutterDataWedge(profileName: 'FlutterDataWedge');

  String origen = "";
  bool mostrar = false;
  bool validaUbicaciones = false;
  bool validaUbicacionesSqlite = false;
  String codProducto = "";
  String descripcion = "";

  String codUbicacion = "";
  String ubicacionR = "";

  String escaneo = "";
  String _locationController = "";
  String _textoUbicacion = "";
  String _productController = "";

  final TextEditingController _textFieldControllerAlerta = TextEditingController();
  final StreamController<double> _progressController = StreamController();
  final StreamController<double> _progressControllerUbicaciones = StreamController();

  final StreamController<double> _progressControllerSqlite = StreamController();
  final StreamController<double> _progressControllerUbicacionesSqlite = StreamController();
  //ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Registrar ubicaciones',
              style: TextStyle(color: Colors.white), //<-- SEE HERE
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                recargarSqlite();
                if (validaUbicacionesSqlite == false) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return StreamBuilder<double>(
                          stream: _progressControllerUbicacionesSqlite.stream,
                          initialData: 0.0,
                          builder: (context, snapshot) {
                            final progressesUbicaciones = snapshot.data ?? 0.0;
                            return WillPopScope(
                              onWillPop: () async {
                                // Aquí puedes ejecutar recargarSqlite() en segundo plano
                                return false; // Siempre devuelve false para evitar que se cierre el cuadro de diálogo
                              },
                              child: AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            width: 200,
                                            height: 200,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 13.0,
                                              value: progressesUbicaciones,
                                              color: const Color.fromARGB(255, 255, 0, 0),
                                            ),
                                          ),
                                          Text('${(progressesUbicaciones * 100).toStringAsFixed(0)}%'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Cargando ubicaciones, por favor espere..",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                  );
                }
              },
              icon: const Icon(
                Icons.update,
                color: Colors.white,
              ))
        ],
      ),
      body: ListView(
        //controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: tabla(),
          )
        ],
      ),
      /*floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Icon(Icons.add),
          backgroundColor: Colores.esquemaColor),*/
    );
  }

  /*void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }*/

  Widget tabla() {
    if (validaUbicaciones == false) {
      return StreamBuilder<double>(
          stream: _progressControllerUbicaciones.stream,
          initialData: 0.0,
          builder: (context, snapshot) {
            final progressesUbicaciones = snapshot.data ?? 0.0;
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
                          value: progressesUbicaciones,
                          color: const Color.fromARGB(255, 255, 0, 0),
                        ),
                      ),
                      Text('${(progressesUbicaciones * 100).toStringAsFixed(0)}%'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Cargando ubicaciones, por favor espere....",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          });
    } else if (valida == false) {
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
                      "Cargando, por favor espere, este proceso puede tardar varios minutos",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          });
    } else {
      return DataTable(
        border: TableBorder.all(width: 1.0, color: Colors.grey),
        sortColumnIndex: 1,
        dividerThickness: 1.0,
        sortAscending: false,
        dataRowHeight: 60,
        columns: const [
          DataColumn(
              label: Text(
            "Ubicación",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          DataColumn(
              label: Text(
            "Producto",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
        ],
        rows: _rows,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    datosProductos();
    // _scrollController = ScrollController();
    iniciarScanner();
  }

  @override
  void dispose() {
    //_scrollController.dispose();
    _progressController.close();
    _progressControllerUbicaciones.close();
    _progressControllerSqlite.close();
    _progressControllerUbicacionesSqlite.close();
    super.dispose();
    fdwListener?.cancel();
  }

  Future<void> recargarSqlite() async {
    final dbHelper = DBHelper();
    final dbHelperUbicaciones = DBHelperUbicacion();
    await dbHelper.clearProductos();
    await dbHelperUbicaciones.clearUbicaciones();
    String token = await _storage.readSecureData("token");

    await _obtenerUbicacionesSqlite(dbHelperUbicaciones, dbHelper, token);
    final productos = await dbHelper.getProductos();
    final ubicaciones = await dbHelperUbicaciones.getUbicaciones();
    if (productos.isEmpty && ubicaciones.isEmpty) {
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
    } else {
      setState(() {
        validaUbicacionesSqlite = true;
      });
    }
  }

  Future<void> datosProductos() async {
    try {
      String token = await _storage.readSecureData("token");
      final dbHelper = DBHelper();
      final dbHelperUbicaciones = DBHelperUbicacion();
      final product = await dbHelper.getProductos();
      final ubicacion = await dbHelperUbicaciones.getUbicaciones();
      if (product.isEmpty && ubicacion.isEmpty) {
        await _obtenerUbicaciones(dbHelperUbicaciones, token);
        await _obtenerProductos(dbHelper, token);

        final productos = await dbHelper.getProductos();
        final ubicaciones = await dbHelperUbicaciones.getUbicaciones();
        if (productos.isEmpty || ubicaciones.isEmpty) {
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
        } else {
          setState(() {
            validaUbicaciones = true;
            valida = true;
          });
        }
      } else {
        setState(() {
          valida = true;
          validaUbicaciones = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void iniciarScanner() async {
    String token = await _storage.readSecureData("token");
    //String dato = await _storage.readSecureData("listaUbicaciones");
    String codUsuario = await _storage.readSecureData("cod_usuario");

    // ignore: unnecessary_null_comparison
    /* if (dato != null) {
      usuarios.clear();
      var json = jsonDecode(dato);
      for (var item in json) {
        String ubicaciona = item["ubicacion"];
        String productoa = item["producto"];
        String codProduc = item["codProducto"];
        String descripcion = item["descripcion"];
        String escaneo = item["escaneo"];
        String codUbicacion = item["codUbicacion"];
        usuarios.add(User(
            ubicacion: ubicaciona,
            producto: productoa,
            codProducto: codProduc,
            descripcion: descripcion,
            escaneo: escaneo,
            codUbicacion: codUbicacion));
      }

      setState(() {
        users = List.of(usuarios);
        _rows = getRows(users);
      });
       
    }*/

    if (Platform.isAndroid) {
      fdwListener = fdw.onScanResult.listen((code) async {
        _textoUbicacion = code.data;

        if (_counter % 2 == 1) {
          limpiar2();
          _locationController = _textoUbicacion;
          await buscaUbicacion(_locationController);

          if (codUbicacion != "" && ubicacionR != "") {
            usuarios.add(User(ubicacion: ubicacionR, producto: "", codProducto: "", descripcion: "", escaneo: "", codUbicacion: ""));
            setState(() {
              mostrar = true;
              users = List.of(usuarios);
              _rows = getRows(users);
            });
          } else {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text("Esta ubicación no existe"),
                backgroundColor: Color.fromARGB(255, 246, 0, 33),
              ));
            _counter++;
            limpiar2();
          }
        } else {
          setState(() {
            origen = "ESC";
          });
          limpiar();
          _productController = _textoUbicacion;
          await buscaDatos(_productController);
          usuarios.clear();
          usuarios.add(User(
              ubicacion: _locationController,
              producto: descripcion,
              codProducto: codProducto,
              descripcion: descripcion,
              escaneo: _productController,
              codUbicacion: codUbicacion));
          bool productExists = false;
          for (User user in usuarios) {
            if (user.codProducto == codProducto) {
              productExists = true;
              break;
            }
          }
          if (productExists && codProducto != "" && descripcion != "") {
            var dato = await registrarUbicacionesProductos(token, int.parse(codProducto), int.parse(codUbicacion), int.parse(codUsuario), origen);
            var json = jsonDecode(dato.body);
            if (json["msg"] == "ok") {
              setState(() {
                mostrar = false;
              });
              usuarios.clear();
              users.clear();

              setState(() {
                users = List.of(usuarios);
                _rows = getRows(users);
              });

              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  duration: const Duration(seconds: 3),
                  content: Text("Producto " + descripcion + " agregado con éxito"),
                  backgroundColor: const Color.fromARGB(255, 41, 98, 255),
                ));
            } else {
              await actualizarProducto(token, int.parse(codProducto), int.parse(codUbicacion), int.parse(codUsuario), origen);
              setState(() {
                mostrar = false;
              });
            }
          } else {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text("Error al escanear este producto"),
                backgroundColor: Color.fromARGB(255, 246, 0, 33),
              ));
            limpiar();
            usuarios.clear();
            users.clear();
            setState(() {
              mostrar = false;
              _rows = getRows(users);
            });
          }
        }
        _counter++;
      });
    }
  }

  void _showDialog(BuildContext context) async {
    limpiar();
    String token = await _storage.readSecureData("token");

    String codUsuario = await _storage.readSecureData("cod_usuario");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Código de barras'),
          content: TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 15,
            controller: _textFieldControllerAlerta,
            decoration: const InputDecoration(
              hintText: "Ingrese el código de barras",
              label: Text("codigo de barras"),
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
                // Aquí puedes manejar la acción de aceptar
                await buscaDatos(_textFieldControllerAlerta.text);
                usuarios.clear();
                usuarios.add(User(
                    ubicacion: _locationController,
                    producto: descripcion,
                    codProducto: codProducto,
                    descripcion: descripcion,
                    escaneo: _textFieldControllerAlerta.text,
                    codUbicacion: codUbicacion));

                bool productExists = false;
                for (User user in usuarios) {
                  if (user.codProducto == codProducto) {
                    productExists = true;
                    break;
                  }
                }

                if (productExists && codProducto != "" && descripcion != "") {
                  setState(() {
                    origen = "TXT";
                  });
                  var dato =
                      await registrarUbicacionesProductos(token, int.parse(codProducto), int.parse(codUbicacion), int.parse(codUsuario), origen);
                  var json = jsonDecode(dato.body);

                  if (json["msg"] == "ok") {
                    _counter++;
                    setState(() {
                      mostrar = false;
                    });
                    usuarios.clear();
                    users.clear();

                    setState(() {
                      users = List.of(usuarios);
                      _rows = getRows(users);
                    });
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        duration: const Duration(seconds: 3),
                        content: Text("Producto " + descripcion + " agregado con éxito"),
                        backgroundColor: const Color.fromARGB(255, 41, 98, 255),
                      ));
                  } else {
                    await actualizarProducto(token, int.parse(codProducto), int.parse(codUbicacion), int.parse(codUsuario), origen);
                    _counter++;
                    setState(() {
                      mostrar = false;
                    });
                  }
                } else {
                  _counter++;
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                      content: Text("Producto no encontrado, comuníquese con el administrador"),
                      backgroundColor: Color.fromARGB(255, 246, 0, 33),
                    ));
                  limpiar();
                  usuarios.clear();
                  users.clear();
                  setState(() {
                    _textFieldControllerAlerta.text = "";
                    mostrar = false;
                    _rows = getRows(users);
                  });
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _obtenerUbicaciones(DBHelperUbicacion dbHelperUbicaciones, String token) async {
    var datas = await obtenerUbicacionesRegistradas(token);
    var jsonUbicaciones = jsonDecode(datas.body);
    var jsonfinalUbicaciones = jsonUbicaciones["data"]["valores"];
    final totalUbicaciones = jsonfinalUbicaciones.length;
    for (int i = 0; i < totalUbicaciones; i++) {
      final itemUbicaciones = jsonfinalUbicaciones[i];
      final ubi = Ubicaciones.fromJson(itemUbicaciones);
      await dbHelperUbicaciones.insertUbicaciones(ubi);
      final progreso = (i + 1) / totalUbicaciones;
      _progressControllerUbicaciones.sink.add(progreso);
    }
    _progressControllerUbicaciones.sink.add(1.0);
    setState(() {
      validaUbicaciones = true;
    });
  }

  Future<void> _obtenerProductos(DBHelper dbHelper, String token) async {
    var data = await obtenerProductos(token);
    var json = jsonDecode(data.body);
    var jsonfinal = json["data"]["valores"];
    final totalItems = jsonfinal.length;
    for (int i = 0; i < totalItems; i++) {
      final item = jsonfinal[i];
      final prod = Producto.fromJson(item);
      await dbHelper.insertProducto(prod);
      final progress = (i + 1) / totalItems;
      _progressController.sink.add(progress);
    }
    _progressController.sink.add(1.0);
  }

  Future<void> _obtenerUbicacionesSqlite(DBHelperUbicacion dbHelperUbicaciones, DBHelper dbHelper, String token) async {
    var datas = await obtenerUbicacionesRegistradas(token);
    var jsonUbicaciones = jsonDecode(datas.body);
    var jsonfinalUbicaciones = jsonUbicaciones["data"]["valores"];
    final totalUbicaciones = jsonfinalUbicaciones.length;
    for (int i = 0; i < totalUbicaciones; i++) {
      final itemUbicaciones = jsonfinalUbicaciones[i];
      final ubi = Ubicaciones.fromJson(itemUbicaciones);
      await dbHelperUbicaciones.insertUbicaciones(ubi);
      final progreso = (i + 1) / totalUbicaciones;
      _progressControllerUbicacionesSqlite.sink.add(progreso);
    }
    _progressControllerUbicacionesSqlite.sink.add(1.0);
    setState(() {
      validaUbicacionesSqlite = true;
    });
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StreamBuilder<double>(
            stream: _progressControllerSqlite.stream,
            initialData: 0.0,
            builder: (context, snapshot) {
              final progresses = snapshot.data ?? 0.0;
              return WillPopScope(
                onWillPop: () async {
                  // Aquí puedes ejecutar recargarSqlite() en segundo plano
                  return false; // Siempre devuelve false para evitar que se cierre el cuadro de diálogo
                },
                child: AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
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
                      ),
                      const SizedBox(width: 10),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Cargando, por favor espere, este proceso puede tardar varios minutos",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
    await _obtenerProductosSqlite(dbHelper, token);
    Navigator.pop(context);
  }

  Future<void> _obtenerProductosSqlite(DBHelper dbHelper, String token) async {
    var data = await obtenerProductos(token);
    var json = jsonDecode(data.body);
    var jsonfinal = json["data"]["valores"];
    final totalItems = jsonfinal.length;
    for (int i = 0; i < totalItems; i++) {
      final item = jsonfinal[i];
      final prod = Producto.fromJson(item);
      await dbHelper.insertProducto(prod);
      final progress = (i + 1) / totalItems;
      _progressControllerSqlite.sink.add(progress);
    }
    _progressControllerSqlite.sink.add(1.0);
  }

  Future<void> actualizarProducto(String token, int codProducto, int codUbicacion, int codUsuario, String origen) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Aquí puedes ejecutar recargarSqlite() en segundo plano
            return false; // Siempre devuelve false para evitar que se cierre el cuadro de diálogo
          },
          child: AlertDialog(
            title: const Text('Error!!', style: TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor)),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Esta ubicación o producto ya se encuentra registrada, ¿Desea actualizar?',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  limpiar();
                  usuarios.clear();
                  users.clear();
                  setState(() {
                    _rows = getRows(users);
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Si'),
                onPressed: () async {
                  var actualizacion = await actualizarUbicacionesProductos(token, codProducto, codUbicacion, codUsuario, origen);
                  var json = jsonDecode(actualizacion.body);

                  if (json["msg"] == "err") {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text(""),
                        backgroundColor: Color.fromARGB(255, 246, 0, 33),
                      ));
                    limpiar();
                    usuarios.clear();
                    users.clear();
                    setState(() {
                      _rows = getRows(users);
                    });
                  } else if (json["msg"] == "ok") {
                    usuarios.clear();
                    users.clear();
                    setState(() {
                      users = List.of(usuarios);
                      _rows = getRows(users);
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        duration: const Duration(seconds: 3),
                        content: Text("Producto " + descripcion + " agregado con éxito"),
                        backgroundColor: const Color.fromARGB(255, 41, 98, 255),
                      ));
                  } else {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text("Error, comuníquese con el administrador"),
                        backgroundColor: Color.fromARGB(255, 246, 0, 33),
                      ));
                    limpiar();
                    usuarios.clear();
                    users.clear();
                    setState(() {
                      _rows = getRows(users);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> buscaDatos(String dato) async {
    final dbHelper = DBHelper();
    final product = await dbHelper.getCodProducto(dato.trim());

    if (product != null) {
      setState(() {
        codProducto = product["codProducto"].toString();
        descripcion = product["descripcion"].toString().trim();
      });
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Producto no encontrado'),
          backgroundColor: Colors.red,
        ));
    }
  }

  Future<void> buscaUbicacion(String dato) async {
    final dbHelperUbicacion = DBHelperUbicacion();
    final ubicacion = await dbHelperUbicacion.getCodUbicaciones(dato.trim());

    final ubicacionNueva = await dbHelperUbicacion.getCodUbicacionesNuevoMetodo(dato.trim());

    if (ubicacion != null) {
      codUbicacion = ubicacion["codUbicacion"].toString();
      ubicacionR = ubicacion["ubicacionR"].toString().trim();
    } else if (ubicacionNueva != null) {
      codUbicacion = ubicacionNueva["codUbicacion"].toString();
      ubicacionR = ubicacionNueva["ubicacionR"].toString().trim();
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('No existe la ubicación escaneada'),
          backgroundColor: Colors.red,
        ));
    }
  }

  void limpiar() {
    setState(() {
      codProducto = "";
      descripcion = "";
    });
  }

  void limpiar2() {
    setState(() {
      codUbicacion = "";
      ubicacionR = "";
    });
  }

  List<DataRow> getRows(List<User> users) => users.asMap().entries.map((entry) {
        int index = entry.key;
        User user = entry.value;
        final cells = [user.ubicacion, user.producto];
        //scrollToBottom();
        return DataRow(
            cells: Utils.modelBuilder(cells, (cellIndex, model) {
          if (_counter % 2 == 1 && index == users.length - 1 && cellIndex == 1 && mostrar == true) {
            return DataCell(
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Añadir manualmente"),
                  onPressed: () {
                    _showDialog(context);
                  },
                ),
              ),
            );
          } else {
            return DataCell(
              Text(
                '$model',
                softWrap: true,
              ),
            );
          }
        }));
      }).toList();
}
