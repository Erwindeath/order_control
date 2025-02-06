// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/menu_principal_views/inservibles/logica/clase_inservibles.dart';
import 'package:order_control/views/menu_principal_views/inservibles/logica/methods.dart';
import 'package:order_control/views/menu_principal_views/inservibles/logica/peticiones.dart';

class AprobarInservibles extends StatefulWidget {
  const AprobarInservibles({Key? key}) : super(key: key);

  @override
  State<AprobarInservibles> createState() => _AprobarInserviblesState();
}

class _AprobarInserviblesState extends State<AprobarInservibles> {
  @override
  void initState() {
    super.initState();
    dataInicial();
  }

  bool activa = false;
  String token = "";
  int destino = 0;
  List<PorAprobacion> pendientes = [];
  Map<String, List<PorAprobacion>> groupedPendientes = {};
  double baseCero = 0.0;
  double baseIvas = 0.0;
  double ivas = 0.0;
  double totales = 0.0;

  final SecureStorage storage = SecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Aprobación de productos",
                style: TextStyle(color: Colors.white, fontSize: 15.0), //<-- SEE HERE
              ),
            ],
          ),
        ),
        body: datos());
  }

  Future<void> dataInicial() async {
    token = await storage.readSecureData("token");
    var datos = await obtenerProductosInserviblesPendientes(token, 5);
    pendientes.clear();
    groupedPendientes.clear();
    setState(() {
      activa = false;
    });
    var decodifica = jsonDecode(datos.body);
    if (decodifica["msg"] == "ok") {
      setState(() {
        activa = true;
      });
      pendientes = parsearPendientes(datos.body);
      groupedPendientes = pendientes.fold<Map<String, List<PorAprobacion>>>({}, (map, pendiente) {
        if (!map.containsKey(pendiente.codCargo.toString())) {
          map[pendiente.codCargo.toString()] = [];
        }
        map[pendiente.codCargo.toString()]!.add(pendiente);
        return map;
      });
    } else {
      pendientes = [];
      setState(() {
        activa = true;
      });
    }
  }

  Widget datos() {
    if (!activa) {
      return circularPrimero();
    } else {
      return buildGroupedCards();
    }
  }

  Widget buildGroupedCards() {
    if (groupedPendientes.isEmpty) {
      return const Center(
        child: Text("No hay datos disponibles."),
      );
    } else {
      return ListView.builder(
        itemCount: groupedPendientes.keys.length,
        itemBuilder: (context, index) {
          var codCargo = groupedPendientes.keys.elementAt(index);
          var pendientesGroup = groupedPendientes[codCargo]!;

          // Tomar el NombreBodega del primer elemento en el grupo
          var nombreBodega = pendientesGroup[0].nombreBodega;
          var usuario = pendientesGroup[0].usuario;
          var fecha = pendientesGroup[0].fecha;

          return Card(
            child: ExpansionTile(
              title: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  nombreBodega.length > 30 ? nombreBodega.substring(0, 30) : nombreBodega,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    // color: Colores.esquemaColor, // Define el color adecuado
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Envía: $usuario",
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text("Fecha: $fecha", style: const TextStyle(color: Colors.black)),
              ]),
              //leading: const Icon(Icons.local_pharmacy),
              children: pendientesGroup.map<Widget>((pend) {
                return Card(
                  elevation: 4.0,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pend.descripcion.length > 30 ? pend.descripcion.substring(0, 30) : pend.descripcion,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // color: Colores.esquemaColor, // Define el color adecuado
                                ),
                              ),
                              //Text('${pend.totalValor}', style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text("Lote: ${pend.lote}"), Text("Fecha: ${pend.fechaV}")],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text("Cantidad: ${pend.cantUnidad}")],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  alertaTerminarRechazo(
                                      context,
                                      pend.codCargo,
                                      pend.codBodega,
                                      pend.codBodegaTran,
                                      pend.observacion,
                                      pend.codProducto,
                                      pend.cantUnidad,
                                      pend.cantFraccion,
                                      pend.cantidadReal,
                                      pend.fraccion,
                                      pend.costo,
                                      pend.parcial,
                                      baseCero,
                                      baseIvas,
                                      ivas,
                                      totales,
                                      pend.codLote,
                                      pend.productoIva,
                                      pend.precioPublico,
                                      pend.costoVenta,
                                      pend);
                                },
                                child: const Row(
                                  children: [
                                    Text("Rechazar", style: TextStyle(color: Colors.black)),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.cancel,
                                      color: Colores.esquemaColor,
                                      size: 20,
                                    )
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    alertaTerminar(
                                        context,
                                        pend.codCargo,
                                        pend.codBodega,
                                        pend.codBodegaTran,
                                        pend.observacion,
                                        pend.codProducto,
                                        pend.cantUnidad,
                                        pend.cantFraccion,
                                        pend.cantidadReal,
                                        pend.fraccion,
                                        pend.costo,
                                        pend.parcial,
                                        pend.base0,
                                        pend.baseIva,
                                        pend.iva,
                                        pend.total,
                                        pend.codLote,
                                        pend);
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Aceptar"),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(Icons.check, size: 20)
                                    ],
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    }
  }

  Future<Map<String, String>> calcularTotales(PorAprobacion producto, int destino) async {
    double base0 = 0.0;
    double baseIva = 0.0;
    double iva = 0.0;
    String valorIva= await storage.readSecureData("valorIva");
    int valor= int.parse(valorIva);
    if (destino == 3) {
      var prodIvaTrimmed = producto.productoIva.trim();
      if (prodIvaTrimmed == '') {
        base0 += producto.costoVenta * producto.cantUnidad.toDouble();
      } else if (prodIvaTrimmed == '*') {
        double base = (producto.costoVenta / ((valor/100)+1)) * producto.cantUnidad.toDouble();
        baseIva += base;
        iva += (base * (valor/100));
      }

      double total = base0 + iva + baseIva;
      setState(() {
        baseCero = double.parse(base0.toStringAsFixed(2).toString());
        baseIvas = double.parse(baseIva.toStringAsFixed(2));

        ivas = double.parse(iva.toStringAsFixed(2));
        totales = double.parse(total.toStringAsFixed(2));
      });
      return {
        "Total": total.toStringAsFixed(2),
        "Base_0": base0.toStringAsFixed(2),
        "Iva": iva.toStringAsFixed(2),
        "Base_Iva": baseIva.toStringAsFixed(2),
      };
    } else {
      var prodIvaTrimmed = producto.productoIva.trim();
      if (prodIvaTrimmed == '') {
        base0 += producto.costo * producto.cantUnidad.toDouble();
      } else if (prodIvaTrimmed == '*') {
        double base = (producto.costo / ((valor/100)+1)) * producto.cantUnidad.toDouble();
        baseIva += base;
        iva += (base * (valor/100));
      }

      double total = base0 + iva + baseIva;
      setState(() {
        baseCero = double.parse(base0.toStringAsFixed(2).toString());
        baseIvas = double.parse(baseIva.toStringAsFixed(2));

        ivas = double.parse(iva.toStringAsFixed(2));
        totales = double.parse(total.toStringAsFixed(2));
      });
      return {
        "Total": total.toStringAsFixed(2),
        "Base_0": base0.toStringAsFixed(2),
        "Iva": iva.toStringAsFixed(2),
        "Base_Iva": baseIva.toStringAsFixed(2),
      };
    }
  }

  Future<Widget> alertaTerminar(
      BuildContext context,
      int codcargo,
      int codBodegaRecibe,
      int codBodegaEnvia,
      String observacion,
      int codProducto,
      int cantidadUnidad,
      int cantidadFraccion,
      int cantReal,
      int fraccion,
      double costo,
      double parcial,
      double base0,
      double baseIva,
      double iva,
      double total,
      int codLote,
      PorAprobacion pend) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('¿Está seguro de aceptar este producto?'),
          content: const Text('Si acepta no podrá volver atrás'),
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
                Map<String, dynamic> jsonData = {
                  'Cod_Producto': codProducto,
                  'Fraccion': fraccion, // Asegúrate de tener este valor disponible
                  'Cant_Real': cantReal, // Asegúrate de tener este valor disponible
                  'Cant_U': cantidadUnidad, // Asegúrate de tener este valor disponible
                  'Cant_F': cantidadFraccion, // Asegúrate de tener este valor disponible
                  'Costo': costo,
                  'Parcial': parcial,
                  'Cod_Lote': codLote
                };
                await calcularTotales(pend, 1);
                var datos = await completarPendiente(token, codProducto, codLote, codcargo, codBodegaRecibe, codBodegaEnvia, observacion,
                    jsonEncode([jsonData]), baseCero, baseIvas, ivas, totales);
                var decod = jsonDecode(datos.body);

                if (decod["msg"] == "ok") {
                  Navigator.of(context).pop();
                  dataInicial();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    msg: "Correcto",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                } else {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: "currió un error",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              },
            ),
          ],
        );
      },
    );
    return const SizedBox();
  }

  Future<Widget> alertaTerminarRechazo(
      BuildContext context,
      int codcargo,
      int codBodegaRecibe,
      int codBodegaEnvia,
      String observacion,
      int codProducto,
      int cantidadUnidad,
      int cantidadFraccion,
      int cantReal,
      int fraccion,
      double costo,
      double parcial,
      double base0,
      double baseIva,
      double iva,
      double total,
      int codLote,
      String productoIva,
      double precioPublico,
      double costoVenta,
      PorAprobacion producto) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('¿Está seguro de rechazar ese producto?'),
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    width: double.infinity,
                    child: DropdownButton(
                        borderRadius: BorderRadius.circular(5.0),
                        //underline: const SizedBox(),
                        isExpanded: true,
                        value: destino,
                        items: const [
                          DropdownMenuItem<int>(value: 0, child: Text("Seleccione destino")),
                          DropdownMenuItem<int>(value: 1, child: Text("Distribución")),
                          DropdownMenuItem<int>(value: 2, child: Text("Devolución")),
                          DropdownMenuItem<int>(value: 3, child: Text("Cobro dependiente")),
                        ],
                        onChanged: (int? value) {
                          setState(() {
                            destino = value!;
                          });
                        }),
                  );
                }),
              ),
              const Text('Si acepta no podrá volver atrás'),
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
                if (destino == 0) {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: "Por favor seleccione un destino",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                } else if (destino == 3) {
                  Map<String, String> totalesInservibles = await calcularTotales(producto, 3);

                  Map<String, dynamic> jsonData = {
                    'Cod_Producto': codProducto,
                    'Fraccion': fraccion, // Asegúrate de tener este valor disponible
                    'Cant_Real': cantReal, // Asegúrate de tener este valor disponible
                    'Cant_U': cantidadUnidad, // Asegúrate de tener este valor disponible
                    'Cant_F': cantidadFraccion, // Asegúrate de tener este valor disponible
                    'Costo': costo,
                    'Parcial': cantidadUnidad * costoVenta,
                    'Precio': costoVenta,
                    'Producto_iva': productoIva,
                    'PrecioPublico': precioPublico,
                    'TipoMf': "",
                    'Base': 0,
                    'Bonificacion': 0,
                    'Descuento': 0,
                    'id_broanet_invoicing': null,
                    'Cod_Lote': codLote
                  };
                  Map<String, dynamic> cobro = totalesInservibles;

                  var datos = await rechazarPendiente(token, codProducto, codLote, codcargo, codBodegaRecibe, codBodegaEnvia, observacion,
                      jsonEncode([jsonData]), jsonEncode([cobro]), baseCero, baseIvas, ivas, totales, destino);
                  var decod = jsonDecode(datos.body);

                  if (decod["msg"] == "ok") {
                    setState(() {
                      destino = 0;
                    });
                    Navigator.of(context).pop();
                    dataInicial();
                    Fluttertoast.showToast(
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      msg: "Correcto",
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  } else {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      msg: "Ocurrió un error, ${decod["controlador"]}",
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  }
                } else {
                  Map<String, String> totalesInservibles = await calcularTotales(producto, 1);

                  Map<String, dynamic> jsonData = {
                    'Cod_Producto': codProducto,
                    'Fraccion': fraccion, // Asegúrate de tener este valor disponible
                    'Cant_Real': cantReal, // Asegúrate de tener este valor disponible
                    'Cant_U': cantidadUnidad, // Asegúrate de tener este valor disponible
                    'Cant_F': cantidadFraccion, // Asegúrate de tener este valor disponible
                    'Costo': costo,
                    'Parcial': parcial,
                    'Precio': costoVenta,
                    'Producto_iva': productoIva,
                    'PrecioPublico': precioPublico,
                    'TipoMf': "",
                    'Base': 0,
                    'Bonificacion': 0,
                    'Descuento': 0,
                    'id_broanet_invoicing': null,
                    'Cod_Lote': codLote
                  };
                  Map<String, dynamic> cobro = totalesInservibles;

                  var datos = await rechazarPendiente(token, codProducto, codLote, codcargo, codBodegaRecibe, codBodegaEnvia, observacion,
                      jsonEncode([jsonData]), jsonEncode([cobro]), baseCero, baseIvas, ivas, totales, destino);
                  var decod = jsonDecode(datos.body);

                  if (decod["msg"] == "ok") {
                    setState(() {
                      destino = 0;
                    });
                    Navigator.of(context).pop();
                    dataInicial();
                    Fluttertoast.showToast(
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      msg: "Correcto",
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  } else {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      msg: "Ocurrió un error, ${decod["controlador"]}",
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

  Widget circularPrimero() {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: const [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  color: Colores.esquemaColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Cargando datos, por favor espere...",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
