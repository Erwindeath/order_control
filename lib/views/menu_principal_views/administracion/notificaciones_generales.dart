// ignore_for_file: import_of_legacy_library_into_null_safe, unused_local_variable, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/perchador/logica/logica_perchador.dart';

class NotificacionesGenerales extends StatefulWidget {
  const NotificacionesGenerales({Key? key}) : super(key: key);

  @override
  State<NotificacionesGenerales> createState() => _NotificacionesGeneralesState();
}

class _NotificacionesGeneralesState extends State<NotificacionesGenerales> {
  String token = "";
  String codUsuario = "";
  double tamanoTitulo = 18.0;
  double tamanoDescripcion = 15.0;
  bool seleccionoTipoTransferencia = false;

  final TextEditingController observacion = TextEditingController();
  final SecureStorage _storage = SecureStorage();
  int index = -1;
  List<dynamic> notificacionProductos = [];
  var motivos = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Novedades Pendientes"),
      ),
      body: RefreshIndicator(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                const SizedBox(height: 5),
                datos(),
              ],
            ),
          ),
        ),
        onRefresh: () async {
          await dataInicial();
        },
      ),
    );
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
      return _buildNotificaciones();
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
      var response = await novedadesPendientesGenerales(token);
      var datosDecodificado = jsonDecode(response.body)["msg"];
      var decodedResponse = jsonDecode(response.body);

      var motivosdata = await obtenerMotivosAdmin(token);
      var motivosDecodificados = jsonDecode(motivosdata.body);
      if (datosDecodificado != "err" && motivosDecodificados["msg"] != "err") {
        setState(() {
          motivos = motivosDecodificados["motivosPerchador"];
          notificacionProductos = decodedResponse['notificacionProductos'];
          seleccionoTipoTransferencia = true;
        });
      } else {
       await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.info,
              title: "Sin novedades",
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

  Widget _buildNotificaciones() {
    if (notificacionProductos.isEmpty) {
      return const Center(
        child: Text("No hay notificaciones disponibles."),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8.0),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height - 30,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: notificacionProductos.length,
                itemBuilder: (BuildContext context, int indice) {
                  var notificacion = notificacionProductos[indice];
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
                              notificacionProductos[indice]['isExpanded'] = !isExpanded;
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
                              notificacion['cantidad'],
                              notificacion['Stock'],
                              notificacion['Cod_Observacion_Perchador'],
                              notificacion['motivo'],
                              notificacion['Cod_Notificaciones_Administrador'],
                              notificacion['Descripcion']),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }
  }

  Widget tarjeta(String nombre, int seccion, int rack, int altura, int ubicacion, String codigoDescripcion, int codProducto, int cantidad, int stock,
      int codMotivo, String motivo, int codNotificacion, String descripcion) {
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
                const SizedBox(
                  height: 10,
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
                              "Cantidad R: ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: tamanoTitulo),
                            ),
                            Text(cantidad.toString(), style: TextStyle(fontSize: tamanoDescripcion))
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Stock: ",
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: tamanoTitulo),
                            ),
                            Text(stock.toString(), style: TextStyle(fontSize: tamanoDescripcion))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
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
                              "Motivo: ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: tamanoTitulo),
                            ),
                            Text(motivo, style: TextStyle(fontSize: tamanoDescripcion))
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                String ubicacionGenerla =
                                    'Rack:${rack.toString()}, Sección:${seccion.toString()}, Altura:${altura.toString()},Ubicación:${ubicacion.toString()} ';
                                alertaTerminar(context, codMotivo, codNotificacion, descripcion, motivo, codigoDescripcion, ubicacionGenerla, nombre);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text("Confirmar"),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Boxicons.bx_check_circle,
                                    size: 17.0,
                                  ),
                                )
                              ]),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                String ubicacionGenerla =
                                    'Rack:${rack.toString()}, Sección:${seccion.toString()}, Altura:${altura.toString()},Ubicación:${ubicacion.toString()} ';
                                alerta(context, codNotificacion, descripcion, codigoDescripcion, ubicacionGenerla, nombre);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              // ignore: prefer_const_constructors
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                Text("Completar"),
                                Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Icon(
                                      Icons.error_rounded,
                                      size: 20.0,
                                    ))
                              ]),
                            ),
                          ],
                        ),
                      ),
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

  Future<Widget> alertaTerminar(BuildContext context, int codMotivo, int codNotificacion, String descripcion, String motivo, String codUbicacion,
      String ubicacionGeneral, String area) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('¿Está seguro de confirmar el motivo de la novedad?'),
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
                await completarNovedadAdmin(
                    token, codMotivo, codNotificacion, int.parse(codUsuario), descripcion, motivo, codUbicacion, ubicacionGeneral, area);
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

  int motivo = 0;
  List<DropdownMenuItem<int>>? generarMotivos() {
    List<DropdownMenuItem<int>>? listadoTiposMantenimiento = [];
    listadoTiposMantenimiento.add(
      const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione una opción"),
      ),
    );

    for (var elemento in motivos) {
      listadoTiposMantenimiento.add(
        DropdownMenuItem(
          value: int.parse(elemento["Codigo"].toString()),
          child: Text(elemento["Nombre"].toString()),
        ),
      );
    }
    return listadoTiposMantenimiento;
  }

  Future<Widget> alerta(
      BuildContext context, int codNotificacion, String descripcion, String codUbicacion, String ubicacionGeneral, String area) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Seleccione un motivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colores.esquemaColor, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: DropdownButton(
                          borderRadius: BorderRadius.circular(5.0),
                          underline: const SizedBox(),
                          value: motivo,
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colores.esquemaColor,
                          ),
                          items: generarMotivos(),
                          isExpanded: true,
                          onChanged: (int? newValue) {
                            setState(() {
                              motivo = newValue!;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                setState(() {
                  motivo = 0;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                if (motivo == 0) {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: "Seleccione un motivo",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                } else {
                  var nombreMotivo = generarMotivos()!
                      .firstWhere(
                        (item) => item.value == motivo,
                        orElse: () => const DropdownMenuItem<int>(
                          value: 0,
                          child: Text("Motivo no encontrado"),
                        ),
                      )
                      .child as Text?;
                  var response = await completarNovedadAdmin(token, motivo, codNotificacion, int.parse(codUsuario), descripcion,
                      nombreMotivo!.data.toString(), codUbicacion, ubicacionGeneral, area);

                  if (jsonDecode(response.body)["msg"] != "err") {
                    setState(() {
                      motivo = 0;
                    });

                    Navigator.of(context).pop();
                    dataInicial();
                    Fluttertoast.showToast(
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      msg: "Correcto",
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  } else {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      msg: "Error, Comuníquese con el administrador",
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
    return const SizedBox();
  }
}
