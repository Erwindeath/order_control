// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:badges/badges.dart' as bg;
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:intl/intl.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/perchador/logica/logica_perchador.dart';
import 'package:order_control/views/menu_principal_views/perchador/notificaciones.dart';

import '../../../complements/colors.dart';

class NotificacionesOrdenes extends StatefulWidget {
  const NotificacionesOrdenes({Key? key}) : super(key: key);

  @override
  State<NotificacionesOrdenes> createState() => _NotificacionesOrdenesState();
}

class _NotificacionesOrdenesState extends State<NotificacionesOrdenes> {
  String token = "";
  String codUsuario = "";
  List<Map<String, dynamic>> notificacionesListado = [];
  List<Widget> notificaciones = [];
  final SecureStorage _storage = SecureStorage();
  bool valida = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Ordenes con novedades"),
        ),
        body: RefreshIndicator(
            child: Column(
              children: [Flexible(child: inicial())],
            ),
            onRefresh: () async {
              dataInicial();
            }));
  }

  @override
  void initState() {
    super.initState();
    dataInicial();
  }

  Future<void> dataInicial() async {
    token = await _storage.readSecureData("token");
    codUsuario = await _storage.readSecureData("cod_usuario");

    try {
      var ordenesNotificaciones = await notificacionesPendientes(token, int.parse(codUsuario));
      var datosDecodificado = jsonDecode(ordenesNotificaciones.body)["msg"];

      if (datosDecodificado != "err") {
        setState(() {
          valida = true;
        });
        notificacionesListado = (jsonDecode(ordenesNotificaciones.body)["notificacion"] as List).map((e) => e as Map<String, dynamic>).toList();
        generarListados(notificacionesListado);
      } else {
        setState(() {
          valida = false;
        });
        notificaciones = [];
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.info,
                title: "Sin novedades!",
                text: "No tiene novedades pendientes",
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

  void generarListados(List<Map<String, dynamic>> valor) {
    List<Widget> listadoNotificacionesPendientes = [];

    for (var notificacion in valor) {
      listadoNotificacionesPendientes.add(Padding(
        padding: const EdgeInsets.all(5.0),
        child: GestureDetector(
          onTap: () async {
            await _storage.writeSecureData("Cod_Cargo", notificacion["Cod_Cargo"].toString());

            await _storage.writeSecureData("codOrden", notificacion["orden"].toString());
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificacionesPerchador()));
          },
          child: bg.Badge(
            badgeContent: Text(
              notificacion["noti"].toString(),
              style: const TextStyle(color: Colors.white),
            ),
            badgeStyle: const bg.BadgeStyle(
              badgeColor: Colors.red,
            ),
            position: bg.BadgePosition.topEnd(top: 0, end: 0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 4,
              shadowColor: const Color(0xff6A2831),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline, color: Color(0xff6A2831)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    notificacion["Nombres"].toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff6A2831)),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Boxicons.bx_notepad, color: Color(0xff6A2831)),
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    "Orden: ",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff6A2831)),
                                  ),
                                ),
                                Text(
                                  notificacion["Cod_Cargo"].toString(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, color: Color(0xff6A2831)),
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    "Fecha: ",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff6A2831)),
                                  ),
                                ),
                                Text(
                                  DateFormat('EEEE, y/M/d HH:mm', 'es_US').format(DateTime.parse(notificacion["fecha"])),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                            child: Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.assignment, color: Color(0xff6A2831), size: 50),
                            ],
                          ),
                        )),
                      ],
                    ),
                    //Text(farmacia["distancia"].toStringAsFixed(2) + " Km", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
    }
    setState(() {
      notificaciones = listadoNotificacionesPendientes;
    });
  }

  Widget inicial() {
    if (valida == false) {
      return circularPrimero();
    } else {
      return notificacionesP();
    }
  }

  Widget notificacionesP() {
    return ListView(physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), children: notificaciones);
  }

  Widget circularPrimero() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: const [
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
}
