// ignore_for_file: import_of_legacy_library_into_null_safe, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/menu_principal_views/perchador/logica/logica_perchador.dart';
import 'package:order_control/views/menu_principal_views/perchador/notificacion_ordenes.dart';

class NotificacionesPerchador extends StatefulWidget {
  const NotificacionesPerchador({Key? key}) : super(key: key);

  @override
  State<NotificacionesPerchador> createState() => _NotificacionesPerchadorState();
}

class _NotificacionesPerchadorState extends State<NotificacionesPerchador> {
  String codCargo = "";
  var motivos = [];
  String token = "";
  String codUsuario = "";
  String orden = "";
  double tamanoTitulo = 18.0;
  double tamanoDescripcion = 15.0;
  final TextEditingController observacion = TextEditingController();
  final SecureStorage _storage = SecureStorage();
  bool seleccionoTipoTransferencia = false;
  int index = -1;

  List<dynamic> notificacionProductos = []; // Lista de notificaciones

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Novedades"),
      ),
      body: datos(),
    );
  }

  @override
  void initState() {
    super.initState();
    dataInicial();
  }

  Widget datos() {
    if (!seleccionoTipoTransferencia) {
      return circularPrimero();
    } else {
      return _buildNotificaciones();
    }
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

  Future<void> dataInicial() async {
    token = await _storage.readSecureData("token");
    codCargo = await _storage.readSecureData("Cod_Cargo");
    codUsuario = await _storage.readSecureData("cod_usuario");
    orden = await _storage.readSecureData("codOrden");
    try {
      var response = await novedades(token, int.parse(codCargo.trim()), int.parse(orden.trim()), int.parse(codUsuario.trim()));
      var datosDecodificado = jsonDecode(response.body)["msg"];
      var decodedResponse = jsonDecode(response.body);
      var motivosdata = await obtenerMotivos(token);
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
                      builder: (BuildContext context) => const NotificacionesOrdenes(),
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

  /* Future<void> datosFuncionales() async {
    try {
      var motivosdata = await obtenerMotivos(token);
      var motivosDecodificados = jsonDecode(motivosdata.body);
      print(motivosDecodificados);
      if (motivosDecodificados != "err") {
        setState(() {
          motivos = motivosDecodificados["motivosPerchador"];
        });
      } else {
        SweetAlertV2.show(context,
            title: "Error",
            subtitle: "Comuníquese con el administrador",
            style: SweetAlertV2Style.error, onPress: (bool isConfirm) {
          if (isConfirm) {
            Future.delayed(const Duration(milliseconds: 2), () async {
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const NotificacionesOrdenes(),
                ),
                (route) => false,
              );
            });

            return true;
          }
          return false;
        });
      }
    } on TimeoutException catch (e) {
      SweetAlertV2.show(
        context,
        title: "Error: $e",
        subtitle: "Comuníquese con el administrador",
        style: SweetAlertV2Style.error,
      );
    }
  }*/

  Widget _buildNotificaciones() {
    if (notificacionProductos.isEmpty) {
      return const Center(
        child: Text("No hay notificaciones disponibles."),
      );
    } else {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8.0),
          child: ExpansionPanelList(
            expansionCallback: (i, isOpen) {
              setState(() {
                if (index == i) {
                  index = -1;
                } else {
                  index = i;
                }
              });
            },
            animationDuration: const Duration(seconds: 1),
            dividerColor: Colores.esquemaColor,
            elevation: 4,
            children: List.generate(
              notificacionProductos.length,
              (indice) {
                var notificacion = notificacionProductos[indice];
                var descripcion = notificacion['Descripcion'];

                return ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text(
                        descripcion,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor),
                      ),
                      leading: const Icon(
                        Boxicons.bx_cart,
                        color: Colores.esquemaColor,
                      ),
                    );
                  },
                  canTapOnHeader: true,
                  body: Column(
                    children: [
                      tarjeta(
                          notificacion['nombre'],
                          notificacion['Seccion'],
                          notificacion['Rack'],
                          notificacion['Altura'],
                          notificacion['Ubicacion'],
                          notificacion['codigo_descripcion'],
                          notificacion['Cant_unidad'] - notificacion['cantidad'],
                          notificacion['Cod_Producto'],
                          notificacion['Cod_Notificacion'],
                          notificacion['Cod_Notificaciones_det'],
                          notificacion['StockDisponible'],
                          notificacion['stock']),
                    ],
                  ),
                  isExpanded: index == indice,
                );
              },
            ),
          ),
        ),
      );
    }
  }

  Widget tarjeta(String nombre, int seccion, int rack, int altura, int ubicacion, String codigoDescripcion, int cantidad, int codProducto,
      int Cod_Notificacion, int codNotificacionesDet, int stockDisponible, String stock) {
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Cantidad: ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            Text(cantidad.toString(), style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold))
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
                                alertaTerminar(context, codProducto, Cod_Notificacion);
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
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                alerta(context, Cod_Notificacion, codProducto, codNotificacionesDet, stockDisponible);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text("No atendida"),
                                Icon(
                                  Icons.error_rounded,
                                  size: 20.0,
                                )
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

  int motivo = 0;
  List<DropdownMenuItem<int>>? generarMotivos() {
    List<DropdownMenuItem<int>>? listadoTiposMantenimiento = [];
    listadoTiposMantenimiento.add(
      const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione un motivo"),
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

  Future<Widget> alerta(BuildContext context, int codNotificacion, int codProducto, int codNotificacionesDet, int stockDisponible) async {
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
                  /* var response = await completarNovedadObligatorias(
                      token,
                      motivo,
                      codNotificacion,
                      codProducto,
                      int.parse(codUsuario),
                      codNotificacionesDet,
                      stockDisponible);
                      print(jsonDecode(response.body)["msg"]);
                  if (jsonDecode(response.body)["msg"] != "err") {
                    setState(() {
                      motivo = 0;
                    });

                    Navigator.of(context).pop();
                    dataInicial();
                    await FlutterToastAlert.showToastAndAlert(
                        type: Type.Success,
                        androidToast: "Correcto",
                        toastDuration: 3,
                        toastShowIcon: true);
                  }else{
                    await FlutterToastAlert.showToastAndAlert(
                        type: Type.Error,
                        androidToast: "Error, Comuníquese con el administrador",
                        toastDuration: 3,
                        toastShowIcon: true);
                  }*/
                }
              },
            ),
          ],
        );
      },
    );
    return const SizedBox();
  }

  /*Future<Widget> alerta(
      BuildContext context, int codCargo, int codProducto) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Seleccione un motivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //const Text('Agregue una observación de ser necesaria'),
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
                await completarNovedad(token, observacion.text, codCargo,
                    codProducto, int.parse(codUsuario));
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
