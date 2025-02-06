import 'dart:async';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:order_control/complements/colors.dart';
import 'dart:convert';
import 'package:order_control/complements/login/logica_login.dart';
import 'package:order_control/complements/widget_app_bar.dart';
import 'package:order_control/views/home/home.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_datawedge/flutter_datawedge.dart';
// ignore: import_of_legacy_library_into_null_safe

class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  StreamSubscription? fdwListener;
  String _lastCode = '';
  late AnimationController _controller;
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  final bool _isLoading = false;
  bool scannerInitialized = false;
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const WidgetImageBar(),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10.0),
                  children: [
                    Card(
                      elevation: 2.0,
                      child: Column(
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Image.asset('assets/images/logoFSG.png', width: (MediaQuery.of(context).size.width / 1.5))),
                            Padding(padding: const EdgeInsets.all(15.0), child: titulo()),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0), child: usuario()),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0), child: password()),
                            botonlogin(),
                            opcion(),
                            botonQR()
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initScanner() {
    if (Platform.isAndroid) {
      var fdw = FlutterDataWedge(profileName: 'FlutterDataWedge');
      fdwListener = fdw.onScanResult.listen((code) async {
        _lastCode = code.data;

        try {
          var response = await loginBodegaUsuarioQR(_lastCode.trim());
          var json = await jsonDecode(response.body);

          var verificar = await registrarDatosUsuariosBodega(json);
          if (verificar) {
            scannerInitialized = false;
            fdwListener?.cancel();
            _lastCode = "";
            scannerInitialized = false;
            Navigator.of(context)
                .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const Home()), (Route<dynamic> route) => false);
          } else {
            _lastCode = "";
            await ArtSweetAlert.show(
                barrierDismissible: false,
                context: context,
                artDialogArgs: ArtDialogArgs(
                    type: ArtSweetAlertType.danger,
                    title: "Error de verificación",
                    text: "Usuario/clave incorrectos",
                    confirmButtonText: "Aceptar",
                    onConfirm: () async {
                      Navigator.pop(context);
                    },
                    confirmButtonColor: Colores.esquemaColor));
          }
        } catch (error) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error.toString())));
        }
      });
    }
  }

  Widget usuario() {
    return TextField(
      controller: _usuarioController,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: Icon(
            Icons.person,
            color: Colors.black,
          ),
          labelText: "Ingrese su usuario",
          hintText: "Nombre de usuario"),
    );
  }

  Widget password() {
    return TextField(
      obscureText: _isObscure,
      enableSuggestions: false,
      autocorrect: false,
      controller: _contrasenaController,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(
            Icons.lock,
            color: Colors.black,
          ),
          labelText: "Ingrese su contraseña",
          hintText: "Contraseña",
          suffixIcon: IconButton(
            icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
          )),
    );
  }

  Widget titulo() {
    return Text(
      "OASIS",
      style: TextStyle(
        decoration: TextDecoration.none,
        color: Theme.of(context).primaryColor,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget botonlogin() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_usuarioController.text == "" || _contrasenaController.text == "") {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                      content: Text('Debe rellenar todos los campos'),
                      backgroundColor: Colors.red,
                    ));
                } else {
                  try {
                    var response = await loginBodegaUsuario(_usuarioController.text, _contrasenaController.text);
                    var json = await jsonDecode(response.body);

                    var verificar = await registrarDatosUsuariosBodega(json);
                    if (verificar) {
                      Navigator.of(context)
                          .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const Home()), (Route<dynamic> route) => false);
                    } else {
                      await ArtSweetAlert.show(
                          barrierDismissible: false,
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                              type: ArtSweetAlertType.danger,
                              title: "Error de verificación",
                              text: "Usuario/clave incorrectos",
                              confirmButtonText: "Aceptar",
                              onConfirm: () async {
                                Navigator.pop(context);
                              },
                              confirmButtonColor: Colores.esquemaColor));
                    }
                  } catch (error) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                }
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Text("Iniciar sesión"),
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
            )),
      ),
    );
  }

  Widget botonQR() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            child: ElevatedButton(
              onPressed: () async {
                if (!scannerInitialized) {
                  initScanner();
                  scannerInitialized = true;
                }
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(child: dialogo());
                  },
                ).then((value) {
                  // Aquí se ejecuta la función después de que se ha cerrado el diálogo
                  if (value != null) {
                    // Se ha pulsado el botón OK
                    scannerInitialized = false;
                    fdwListener?.cancel();
                    _lastCode = "";
                  } else {
                    // Se ha cerrado el diálogo sin pulsar el botón OK
                    scannerInitialized = false;
                    fdwListener?.cancel();
                    _lastCode = "";
                  }
                });
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Text("Iniciar sesión con QR"),
                SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.qr_code,
                    size: 20.0,
                  ),
                )
              ]),
            )),
      ),
    );
  }

  Widget dialogo() {
    return AlertDialog(
      title: const Text('Escanea tu código QR'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(),
          ),
          SizedBox(height: 10),
          Text('Esperando...'),
        ],
      ),
    );
  }

  Widget opcion() {
    return const Center(
      child: Text(
        '-o-',
        textAlign: TextAlign.center,
      ),
    );
  }
}
