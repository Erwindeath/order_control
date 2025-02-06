// ignore_for_file: import_of_legacy_library_into_null_safe, unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/menu_principal_views/perchador/logica/logica_perchador.dart';

class NotificacionesPendientesOpcionales extends StatefulWidget {
  const NotificacionesPendientesOpcionales({Key? key}) : super(key: key);

  @override
  State<NotificacionesPendientesOpcionales> createState() => _NotificacionesPendientesOpcionalesState();
}

class _NotificacionesPendientesOpcionalesState extends State<NotificacionesPendientesOpcionales> {
  String token = "";
  String codUsuario = "";
  double tamanoTitulo = 18.0;
  double tamanoDescripcion = 15.0;
  bool seleccionoTipoTransferencia = false;
  late int valorpr;
  final TextEditingController observacion = TextEditingController();
  final SecureStorage _storage = SecureStorage();
  int index = -1;
  List<dynamic> notificacionProductos = [];

  Map<int, List<dynamic>> cacheNovedades = {};

  @override
  Widget build(BuildContext context) {
    return datos();
  }

  @override
  void initState() {
    super.initState();
    dataInicial();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget datos() {
    if (!seleccionoTipoTransferencia) {
      return circularPrimero();
    } else {
      return _buildNotificaciones(notificacionProductos);
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

  Future<void> dataInicial() async {
    token = await _storage.readSecureData("token");
    codUsuario = await _storage.readSecureData("cod_usuario");
    try {
      var response = await novedadesPendientes(token, int.parse(codUsuario), 2);
      var datosDecodificado = jsonDecode(response.body)["msg"];
      var decodedResponse = jsonDecode(response.body);

      if (datosDecodificado != "err") {
        setState(() {
          notificacionProductos = decodedResponse['notificacionProductos'];
          seleccionoTipoTransferencia = true;
        });
      } else {
        setState(() {
          seleccionoTipoTransferencia = true;
        });
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.info,
                title: "Sin novedades",
                text: "No tiene novedades pendientes",
                confirmButtonText: "Aceptar",
                onConfirm: () async {
                  Navigator.pop(context);
                },
                confirmButtonColor: Colores.esquemaColor));
      }
    } on TimeoutException catch (e) {
      await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.info,
              title: "Error: $e",
              text: "Comuníquese con el administrador",
              confirmButtonText: "Aceptar",
              onConfirm: () async {
                Navigator.pop(context);
              },
              confirmButtonColor: Colores.esquemaColor));
    }
  }

  void _scrollToPanel(int panelIndex) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final double panelHeight = renderBox.size.height; // Altura del ListTile
    final double scrollOffset = panelIndex * panelHeight;
    Scrollable.ensureVisible(
      context,
      alignment: 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildNotificaciones(List<dynamic> datos) {
    if (datos.isEmpty) {
      return const Center(
        child: Text("No hay notificaciones disponibles."),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8.0),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: datos.length,
              itemBuilder: (BuildContext context, int indice) {
                var notificacion = datos[indice];
                var descripcion = notificacion['Descripcion'];
                var isExpanded = notificacion['isExpanded'] ?? false;

                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          descripcion,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colores.esquemaColor,
                          ),
                        ),
                        leading: const Icon(
                          Boxicons.bx_cart,
                          color: Colores.esquemaColor,
                        ),
                        trailing: const Icon(
                          Boxicons.bx_chevron_down,
                          color: Colores.esquemaColor,
                        ),
                        onTap: () {
                          setState(() {
                            datos[indice]['isExpanded'] = !isExpanded;
                            if (!isExpanded) {
                              _scrollToPanel(indice);
                            }
                          });
                        },
                      ),
                      if (isExpanded)
                        tarjeta(
                          notificacion['nombre'],
                          notificacion['Seccion'],
                          notificacion['Rack'],
                          notificacion['Altura'],
                          notificacion['Ubicacion'],
                          notificacion['codigo_descripcion'],
                          notificacion['Cod_Producto'],
                          notificacion['Cod_Notificacion'],
                          notificacion['stock'],
                          notificacion['tipo'],
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }

  Widget tarjeta(String nombre, int seccion, int rack, int altura, int ubicacion, String codigoDescripcion, int codProducto, int codNotificacion,
      String stock, String tipo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
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
                              rack.toString(),
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
                            Text(seccion.toString(), style: TextStyle(fontSize: tamanoDescripcion)),
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
                            Text(altura.toString(), style: TextStyle(fontSize: tamanoDescripcion))
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
                            Text(ubicacion.toString(), style: TextStyle(fontSize: tamanoDescripcion))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Stock: ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: tamanoTitulo),
                            ),
                            Text(stock.toString(), style: TextStyle(fontSize: tamanoDescripcion))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                alertaTerminar(context, codProducto, codNotificacion);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text("Atendida"),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Boxicons.bx_check_circle,
                                    size: 17.0,
                                  ),
                                )
                              ]),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Widget> alertaTerminar(BuildContext context, int codProducto, int codNotificacion) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('¿Está seguro de dar por terminada esta alerta?'),
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
                await completarNovedad(token, 4, codNotificacion, codProducto, int.parse(codUsuario));
                Navigator.of(context).pop();
                dataInicial();
                Fluttertoast.showToast(
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  msg: "Correcto",
                  gravity: ToastGravity.BOTTOM,
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
          ],
        );
      },
    );
    return const SizedBox();
  }
  /*Future<Widget> alerta(BuildContext context, int codProducto) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Observación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Agregue una observación de ser necesaria'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  maxLines: 10,
                  minLines: 1,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.multiline,
                  controller: observacion,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        FontAwesome5Solid.clipboard_list,
                        size:
                            18, // Ajusta el tamaño del ícono según tus necesidades
                        color: Colores
                            .esquemaColor, // Cambia el color del ícono si lo deseas
                      ),
                      labelText: 'Observación',
                      hintText: "Observación"),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                observacion.text = "";
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                //await completarNovedad(token,observacion.text,codProducto,int.parse(codUsuario));
                observacion.text = "";
                Navigator.of(context).pop();
                dataInicial();
                await FlutterToastAlert.showToastAndAlert(
                    type: Type.Success,
                    androidToast: "Correcto",
                    toastDuration: 3,
                    toastShowIcon: true);
              },
            ),
          ],
        );
      },
    );
    return const SizedBox();
  }*/
}
