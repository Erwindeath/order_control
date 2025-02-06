// ignore_for_file: import_of_legacy_library_into_null_safe, unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/complements/administracion/logica_administracion.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/administracion/administracion.dart';

class AdministracionPrincipal extends StatefulWidget {
  const AdministracionPrincipal({Key? key}) : super(key: key);

  @override
  State<AdministracionPrincipal> createState() => _AdministracionPrincipalState();
}

class _AdministracionPrincipalState extends State<AdministracionPrincipal> {
  String token = "";
  bool seleccionoTipoTransferencia = false;
  bool seleccionoTipoTransferencia2 = false;
  double tamanoTitulo = 16.0;
  double tamanoDescripcion = 12.0;
  final SecureStorage _storage = SecureStorage();
  int index = -1;
  List<dynamic> rutas = [];
  List<dynamic> ordenes = [];
  Map<int, List<dynamic>> cacheConsultas = {};

  Timer? timer;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return const Administracion();
              }),
            );
          },
          tooltip: 'Agregar',
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Administración bodega",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
        body: datos());
  }

  @override
  void initState() {
    super.initState();
    datosIniciales();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  Future<void> datosIniciales() async {
    token = await _storage.readSecureData("token");
    try {
      var jsonRutas = await obtenerDatosIniciales(token, "obtener_rutas", 5);
      var datosDecodificado = jsonDecode(jsonRutas.body)["msg"];
      var msgRutas = jsonDecode(jsonRutas.body);
      //print(msgRutas);
      if (datosDecodificado != "err") {
        setState(() {
          rutas = msgRutas["data"];
          seleccionoTipoTransferencia = true;
        });
      } else {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: "Comuníquese con el administrador",
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

  Widget datos() {
    if (!seleccionoTipoTransferencia) {
      return verificacion();
    } else {
      return _buildNotificaciones();
    }
  }

  Widget datos2(int indice) {
    if (!seleccionoTipoTransferencia2) {
      return verificacion();
    } else if (rutas[indice]['ordenes'] != null && rutas[indice]['ordenes'].isNotEmpty) {
      return ordenesCargadas(indice);
    } else if (rutas[indice]['ordenes'] == null) {
      return tarjeta();
    } else {
      return const Text("Error");
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

  Widget verificacion() {
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
              Text('Obteniendo datos....'),
            ],
          ),
        ],
      ),
    );
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

  Future<void> obtenerOrdenes(int codRuta, int indice) async {
    if (cacheConsultas.containsKey(indice)) {
      setState(() {
        rutas[indice]['ordenes'] = cacheConsultas[indice];
        seleccionoTipoTransferencia2 = true;
      });
    } else {
      token = await _storage.readSecureData("token");
      try {
        var jsonRutas = await obtenerOrdenesRuta(token, "obtener_ordenes_rutas", codRuta, 5);
        var datosDecodificado = jsonDecode(jsonRutas.body)["msg"];
        var msgRutas = jsonDecode(jsonRutas.body);

        if (datosDecodificado != "err") {
          setState(() {
            rutas[indice]['ordenes'] = msgRutas["data"];
            cacheConsultas[indice] = msgRutas["data"]; // Almacena el resultado de la consulta en el caché
            seleccionoTipoTransferencia2 = true;
          });
        } else {
          setState(() {
            seleccionoTipoTransferencia2 = true;
          });
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
  }

  Widget _buildNotificaciones() {
    if (rutas.isEmpty) {
      return const Center(
        child: Text("No hay datos disponibles."),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8.0),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: rutas.length,
              itemBuilder: (BuildContext context, int indice) {
                var ruta = rutas[indice];
                var descripcion = ruta['Nombre'];
                var transferencia = ruta['Total_Bodega_Trasferencia'];

                var isExpanded = ruta['isExpanded'] ?? false;

                return Card(
                  color: transferencia > 0 ? Colors.blue.shade100 : Colors.white,
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
                          Boxicons.bxs_chevron_down,
                          color: Colores.esquemaColor,
                        ),
                        onTap: () async {
                          /*    print("adasd*********************");
                            print(rutas[indice]['ordenes']);
                            print("adasd*********************");*/
                          //ordenes.clear();
                          setState(() {
                            rutas[indice]['isExpanded'] = !isExpanded;
                            if (!isExpanded) {
                              _scrollToPanel(indice);
                            }
                          });
                          if (!isExpanded) {
                            await obtenerOrdenes(ruta["Codigo"], indice);
                          }
                        },
                      ),
                      if (isExpanded) datos2(indice)
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

  Widget tarjeta() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                Icon(
                  Icons.assignment_late,
                  size: 55.0,
                  color: Colors.grey,
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                Text("Sin transferencias en este sector")
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ordenesCargadas(int indice) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: rutas[indice]['ordenes'].length,
        itemBuilder: (context, index) {
          var orden = rutas[indice]['ordenes'][index];
          // Use the values in the 'orden' map to build your card
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
                      // Add the content of your card here
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Text(
                              orden['Descripcion'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: tamanoTitulo,
                              ),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            const Icon(
                              Boxicons.bx_user,
                              color: Color(0xff6A2831),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "Empleado:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colores.esquemaColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                orden['Nombres'] ?? '',
                                style: TextStyle(fontSize: tamanoDescripcion),
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
                                  const Icon(
                                    Boxicons.bx_calendar,
                                    color: Color(0xff6A2831),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Inicio: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: tamanoTitulo,
                                        color: Colores.esquemaColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    orden['Fecha_Inicio_Pistoleo'] ?? '',
                                    style: TextStyle(fontSize: tamanoDescripcion),
                                  ),
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
                                  const Icon(
                                    Boxicons.bx_calendar,
                                    color: Color(0xff6A2831),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Fin: ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: tamanoTitulo,
                                        color: Colores.esquemaColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    orden['Fecha_Fin_Pistoleo'] ?? '',
                                    style: TextStyle(fontSize: tamanoDescripcion),
                                  ),
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
                                  const Icon(
                                    Boxicons.bx_box,
                                    color: Color(0xff6A2831),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Productos: ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: tamanoTitulo,
                                        color: Colores.esquemaColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    orden['cantidadProductos'].toString(),
                                    style: TextStyle(fontSize: tamanoDescripcion),
                                  ),
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
                                  const Icon(
                                    Icons.alarm_outlined,
                                    color: Color(0xff6A2831),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SizedBox(
                                      width: 100,
                                      child: orden['reloj'] != null
                                          ? Text(
                                              calcularTiempoTranscurrido(orden['reloj']),
                                              style: const TextStyle(fontSize: 14.0),
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(
                                              calcularTiempoTranscurrido2(orden['Fecha_Inicio_Pistoleo'] ?? '', orden['Fecha_Fin_Pistoleo'] ?? ''),
                                              style: const TextStyle(fontSize: 14.0),
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Boxicons.bx_info_circle,
                                    color: Colores.esquemaColor,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(orden["Estado"], style: TextStyle(fontSize: tamanoDescripcion)),
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
        },
      ),
    );
  }

  String calcularTiempoTranscurrido(String fechaInicio) {
    DateTime inicio = DateTime.parse(fechaInicio);

    DateTime ahora = DateTime.now();

    Duration diferencia = ahora.difference(inicio);

    int horas = diferencia.inHours;
    int minutos = diferencia.inMinutes.remainder(60);

    return 'Lleva $horas horas $minutos minutos';
  }

  String calcularTiempoTranscurrido2(String fechaInicio, String fechaFinal) {
    if (fechaInicio != "" && fechaFinal != "") {
      DateTime inicio = DateTime.parse(fechaInicio);
      DateTime fin = DateTime.parse(fechaFinal);
      Duration diferencia = fin.difference(inicio);

      int horas = diferencia.inHours;
      int minutos = diferencia.inMinutes.remainder(60);

      return '$horas horas $minutos minutos';
    } else {
      return '';
    }
  }
}
