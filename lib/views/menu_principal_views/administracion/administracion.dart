// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:order_control/complements/administracion/logica_administracion.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/menu_principal_views/administracion/principal_admin.dart';
import 'package:order_control/views/menu_principal_views/administracion/subject_data_model.dart';

class Administracion extends StatefulWidget {
  const Administracion({Key? key}) : super(key: key);

  @override
  State<Administracion> createState() => _AdministracionState();
}

class _AdministracionState extends State<Administracion> {
  List<String> list = <String>['One', 'Two', 'Three', 'Four'];
  final TextEditingController horaFormateada = TextEditingController();

  String horaGuardar = "";

  var bodegasDistribucion = [];
  var transportistas = [];
  var vehiculos = [];
  var rutas = [];

  var diasSemana = [];
  var planificacion = [];

  List<dynamic> bodegasSeleccionadas = [];
  List<dynamic> tipoSeleccionado = [];
  List<SubjectModel> subjectData = [];
  bool _isLoading = false;

  List datos = [];
  List<SubjectModel> datosTemporales = [];
  final SecureStorage _storage = SecureStorage();
  Color itemsTextColor = Colors.green;

  //List<int> bodegasSeleccionadas = [];
  //List<int> tipoSeleccionado = [];
  var tipoTransferencia = [];
  var pruebas = [];

  int valor = 0;
  int valorTransportista = 0;
  int valorVehiculo = 0;

  int valorRutas = 0;

  int valorDia = 0;
  int valorPlanificacion = 0;

  TextEditingController observacion = TextEditingController();
  TextEditingController bodegaIMp = TextEditingController();
  bool valida = false;

  bool validar = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Text(
              'Registrar nueva tarea',
              style: TextStyle(color: Colors.white), //<-- SEE HERE
            ),
            Icon(Icons.task)
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          principal(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    datosIniciales();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildLoadingOverlay() {
    return Stack(
      children: <Widget>[
        const Opacity(
          opacity: 0.3,
          child: ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: const [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                        // <-- Puedes cambiar el color aquí
                        ),
                  ),
                  Text(
                    'Generando transferencias por favor espere.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // <-- Estiliza el texto para que se ajuste
                      fontSize: 14, // <-- Cambia el tamaño de fuente según tu necesidad
                      color: Colores.esquemaColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<int>>? generarBodegasDistribucion(List<dynamic> dato) {
    List<DropdownMenuItem<int>>? listadoBodegasDistribucion = [];
    for (var elemento in dato) {
      listadoBodegasDistribucion.add(
        DropdownMenuItem(
          value: int.parse(elemento["Codigo"].toString()),
          child: Text(elemento["Nombre"].toString()),
        ),
      );
    }
    return listadoBodegasDistribucion;
  }

  List<DropdownMenuItem<int>>? generarBodegas() {
    List<DropdownMenuItem<int>>? listadoTiposRutas = [];
    listadoTiposRutas.add(
      const DropdownMenuItem(
        value: 0,
        child: Text("Varias farmacias"),
      ),
    );
    return listadoTiposRutas;
  }

  List<DropdownMenuItem<int>>? generarRutas() {
    List<DropdownMenuItem<int>>? listadoTiposRutas = [];
    listadoTiposRutas.add(
      const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione una ruta"),
      ),
    );

    for (var elemento in rutas) {
      listadoTiposRutas.add(
        DropdownMenuItem(
            value: int.parse(elemento["Codigo"].toString()),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      elemento["Nombre"].toString(),
                      style: TextStyle(
                        color: elemento["Total_bodega_sector"] == elemento["Total_Bodega_Trasferencia"]
                            ? Colors.red.withAlpha(255)
                            : Colors.black.withAlpha(255),
                      ),
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SizedBox(
                      width: 100,
                      child: Transform.rotate(
                        angle: 90 * 3.1416 / 180,
                        child: const Icon(Icons.horizontal_rule_sharp),
                      ),
                    ),
                    color: elemento["Total_bodega_sector"] == elemento["Total_Bodega_Trasferencia"]
                        ? Colors.red.withAlpha(255)
                        : Colors.green.withAlpha(255),
                  ),
                ],
              ),
            )),
      );
    }
    return listadoTiposRutas;
  }

  List<DropdownMenuItem<int>>? generarPlanificacion(List<dynamic> dato, String mensaje) {
    List<DropdownMenuItem<int>>? listadoTiposPlanificacion = [];
    listadoTiposPlanificacion.add(
      DropdownMenuItem(
        value: 0,
        child: Text(mensaje),
      ),
    );
    for (var elemento in dato) {
      listadoTiposPlanificacion.add(
        DropdownMenuItem(
          value: int.parse(elemento["Codigo"].toString()),
          child: Text(elemento["Nombre"].toString()),
        ),
      );
    }
    return listadoTiposPlanificacion;
  }

  Widget principal() {
    if (valida == false) {
      return const Center(
        child: Center(
            child: CircularProgressIndicator(
          color: Colors.blueGrey,
        )),
      );
    } else {
      return ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                cardFarmacia(),
                //const Padding(padding: EdgeInsets.only(bottom: 5)),
                //cardPlanificacion(),
                const Padding(padding: EdgeInsets.only(bottom: 10)),
                botonGuardar()
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget cardFarmacia() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Información de traslado", style: TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor, fontSize: 20)),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              const SizedBox(
                width: 110,
                child: Text(
                  'Bodega origen',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor, fontSize: 15),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colores.esquemaColor, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: DropdownButton(
                        borderRadius: BorderRadius.circular(5.0),
                        underline: const SizedBox(),
                        value: valor,
                        icon: const Icon(
                          Icons.arrow_drop_down_circle,
                          color: Colores.esquemaColor,
                        ),
                        items: generarBodegasDistribucion(bodegasDistribucion),
                        isExpanded: true,
                        onChanged: (int? newValue) {
                          setState(() {
                            valor = newValue!;
                          });
                        }),
                  ),
                ),
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              const SizedBox(
                width: 110,
                child: Text(
                  'Ruta',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor, fontSize: 15),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colores.esquemaColor, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: DropdownButton(
                        borderRadius: BorderRadius.circular(5.0),
                        underline: const SizedBox(),
                        value: valorRutas,
                        icon: const Icon(
                          Icons.arrow_drop_down_circle,
                          color: Colores.esquemaColor,
                        ),
                        items: generarRutas(),
                        isExpanded: true,
                        onChanged: (int? newValue) async {
                          setState(() {
                            valorRutas = newValue!;
                          });
                          bodegasSeleccionadas.clear();
                          await obtenerFarmacias(newValue!);
                        }),
                  ),
                ),
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                    width: 110, child: Text("Bodegas", style: TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor, fontSize: 15))),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colores.esquemaColor, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          controller: bodegaIMp,
                          maxLines: null,
                          onTap: () async {
                            if (pruebas.isEmpty) {
                              null;
                            } else {
                              await _showAlertDialog(context, pruebas.cast<Map<String, dynamic>>());
                            }
                          },
                          readOnly: true,
                          decoration: InputDecoration(
                              hintText: 'Varias Farmacias',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.arrow_drop_down_circle,
                                  color: Colores.esquemaColor,
                                ),
                                onPressed: () {},
                              )),
                        )),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                    width: 110,
                    child: Text("Transportista", style: TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor, fontSize: 15))),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colores.esquemaColor, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: DropdownButton(
                          borderRadius: BorderRadius.circular(5.0),
                          underline: const SizedBox(),
                          value: valorTransportista,
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colores.esquemaColor,
                          ),
                          items: generarBodegasDistribucion(transportistas),
                          isExpanded: true,
                          onChanged: (int? newValue) {
                            setState(() {
                              valorTransportista = newValue!;
                            });
                          }),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                    width: 110, child: Text("Vehículo", style: TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor, fontSize: 15))),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colores.esquemaColor, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: DropdownButton(
                          borderRadius: BorderRadius.circular(5.0),
                          underline: const SizedBox(),
                          value: valorVehiculo,
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colores.esquemaColor,
                          ),
                          items: generarBodegasDistribucion(vehiculos),
                          isExpanded: true,
                          onChanged: (int? newValue) {
                            setState(() {
                              valorVehiculo = newValue!;
                            });
                          }),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                    width: 110,
                    child: Text("Tipo Transferencia", style: TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor, fontSize: 15))),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colores.esquemaColor, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          //controller: bodegaIMp,
                          maxLines: null,
                          onTap: () async {
                            if (tipoTransferencia.isEmpty) {
                              null;
                            } else {
                              await _showAlertDialogTipoTransferencia(context, tipoTransferencia.cast<Map<String, dynamic>>());
                            }
                          },
                          readOnly: true,
                          decoration: InputDecoration(
                              hintText: 'Transferencia',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.arrow_drop_down_circle,
                                  color: Colores.esquemaColor,
                                ),
                                onPressed: () {},
                              )),
                        )),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                    width: 110,
                    child: Text("Observación",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colores.esquemaColor,
                            fontSize: 15))),
                Expanded(
                    child: TextField(
                  controller: observacion,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese su texto aquí',
                    border: OutlineInputBorder(),
                  ),
                ))
              ],
            )*/
          ],
        ),
      ),
    );
  }

  /*Widget cardPlanificacion() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Planificación",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colores.esquemaColor,
                    fontSize: 20)),
            /*Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              const SizedBox(
                width: 110,
                child: Text(
                  'Sucede',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colores.esquemaColor,
                      fontSize: 15),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colores.esquemaColor,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: DropdownButton(
                        borderRadius: BorderRadius.circular(5.0),
                        underline: const SizedBox(),
                        value: valorPlanificacion,
                        icon: const Icon(
                          Icons.arrow_drop_down_circle,
                          color: Colores.esquemaColor,
                        ),
                        items: generarPlanificacion(
                            planificacion, "Seleccione el tipo de ocurrencia"),
                        isExpanded: true,
                        onChanged: (int? newValue) {
                          obtenerFarmacias(newValue!);
                          setState(() {
                            valorPlanificacion = newValue;
                          });
                        }),
                  ),
                ),
              ),
            ]),
            const SizedBox(
              height: 10,
            ),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                    width: 110,
                    child: Text("Días de la semana",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colores.esquemaColor,
                            fontSize: 15))),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colores.esquemaColor,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: IgnorePointer(
                        ignoring: valorPlanificacion == 1,
                        child: Opacity(
                          opacity: valorPlanificacion == 1 ? 0.5 : 1.0,
                          child: DropdownButton(
                              borderRadius: BorderRadius.circular(5.0),
                              underline: const SizedBox(),
                              value: valorDia,
                              icon: const Icon(
                                Icons.arrow_drop_down_circle,
                                color: Colores.esquemaColor,
                              ),
                              items: generarPlanificacion(
                                  diasSemana, "Seleccione un día"),
                              isExpanded: true,
                              onChanged: (int? newValue) {
                                //obtenerFarmacias(newValue!);
                                setState(() {
                                  valorDia = newValue!;
                                });
                              }),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            /*const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                    width: 110,
                    child: Text("Hora inicio",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colores.esquemaColor,
                            fontSize: 15))),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.start,
                    controller: horaFormateada,
                    decoration: const InputDecoration(
                        suffixIcon: Align(
                          widthFactor: 1.0,
                          heightFactor: 1.0,
                          child: Icon(Icons.access_time_filled_rounded,
                              color: Colores.esquemaColor),
                        ),
                        labelText: "Hora inicial"),
                    readOnly: true,
                    onTap: () async {
                      final DateTime now = DateTime.now();
                      TimeOfDay? pickedDate = await showTimePicker(
                          hourLabelText: "Hora",
                          minuteLabelText: "Minuto",
                          helpText: "Seleccione una hora para iniciar",
                          context: context,
                          initialTime:
                              TimeOfDay(hour: now.hour, minute: now.minute));

                      if (pickedDate != null) {
                        setState(() {
                          horaGuardar = pickedDate.format(context).toString();
                          horaFormateada.text =
                              pickedDate.format(context).toString();
                        });
                      }
                    },
                  ),
                )
              ],
            )*/
          ],
        ),
      ),
    );
  }*/

  Widget botonGuardar() {
    return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            onPressed: !validar
                ? () async {
                    setState(() {
                      validar = true;
                    });

                    String token = await _storage.readSecureData("token");
                    String codUsuario = await _storage.readSecureData("cod_usuario");
                    await guardar(valor, valorRutas, bodegasSeleccionadas, valorTransportista, valorVehiculo, valorDia, observacion.text, token,
                        int.parse(codUsuario), tipoSeleccionado);
                  }
                : null,
            label: const Text(
              "Guardar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            )));
  }

  Future<dynamic> guardar(
    int bodegaD,
    int ruta,
    List<dynamic> bodegas,
    int trasportista,
    int vehiculo,
    int diaSemana,
    String observacion,
    String token,
    int codUsuario,
    List<dynamic> tipoTranferenciaP,
  ) async {
    if (bodegaD == 0) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Error al seleccionar la bodega origen'),
          backgroundColor: Colors.red,
        ));
    } else if (ruta == 0) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Error al seleccionar la ruta'),
          backgroundColor: Colors.red,
        ));
    } else if (bodegas.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Debe escoger una bodega'),
          backgroundColor: Colors.red,
        ));
    } else if (trasportista == 0) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Error al seleccionar el transportista'),
          backgroundColor: Colors.red,
        ));
    } else if (vehiculo == 0) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Error al seleccionar el vehículo'),
          backgroundColor: Colors.red,
        ));
      /*} else if (diaSemana == 0) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Seleccione un día de la semana'),
          backgroundColor: Colors.red,
        ));*/
    } else if (tipoTranferenciaP.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Debe escoger un tipo de transferencia'),
          backgroundColor: Colors.red,
        ));
      /*} else if (observacion.trim() == "") {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Debe agregar una observación'),
          backgroundColor: Colors.red,
        ));*/
      setState(() {
        validar = false;
      });
    } else {
      try {
        setState(() {
          _isLoading = true;
        });
        print(bodegaD);
         print(bodegaD);
          print(ruta);
           print(bodegas);
            print(codUsuario);
             print(tipoTranferenciaP);
       /* var registro = await guardarPlanificaciones(
            bodegaD,
            ruta,
            bodegas,
            trasportista.toString() + '   ',
            vehiculo,
            observacion,
            //diaSemana,
            token,
            "registrar_planificaciones",
            codUsuario,
            tipoTranferenciaP);
        print(jsonDecode(registro.body));
        if (jsonDecode(registro.body)["msg"] != "err") {
          setState(() {
            _isLoading = false;
          });
          await ArtSweetAlert.show(
              barrierDismissible: false,
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.success,
                  title: "Transferencias generadas con éxito",
                  confirmButtonText: "Aceptar",
                  onConfirm: () async {
                    await Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const AdministracionPrincipal(),
                      ),
                      (route) => false,
                    );
                  },
                  confirmButtonColor: Colores.esquemaColor));

          /*await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  const AdministracionPrincipal(),
            ),
            (route) => false,
          );*/
        } else {
          setState(() {
            _isLoading = false;
            validar = false;
          });
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: "No se pudo registrar",
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT,
          );
        }*/
      } on TimeoutException catch (e) {
        setState(() {
          _isLoading = false;
          validar = false;
        });
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
  }

  /// **************DATOS INICIALES**************************************/

  Future<void> datosIniciales() async {
    String token = await _storage.readSecureData("token");
    try {
      var jsonbodegasDistribucion = await obtenerDatosIniciales(token, 'obtener_bodegas_principales', 5);
      var msgBodegaDistribucion = jsonDecode(jsonbodegasDistribucion.body)["msg"];

      var jsonTransportista = await obtenerDatosIniciales(token, 'obtener_transportistas', 5);
      var msgTransportista = jsonDecode(jsonTransportista.body)["msg"];

      var jsonVehiculos = await obtenerDatosIniciales(token, 'obtener_vehiculos', 5);
      var msgVehiculos = jsonDecode(jsonVehiculos.body)["msg"];

      var jsonRutas = await obtenerDatosIniciales(token, "obtener_rutas", 5);

      var msgRutas = jsonDecode(jsonRutas.body)["msg"];

      var jsonPlanificaciones = await obtenerDatosIniciales(token, "obtener_planificacion", 5);

      var msgPlanificaciones = jsonDecode(jsonPlanificaciones.body)["msg"];

      if (msgBodegaDistribucion != "err" && msgTransportista != "err" && msgVehiculos != "err" && msgRutas != "err" && msgPlanificaciones != "err") {
        setState(() {
          bodegasDistribucion = jsonDecode(jsonbodegasDistribucion.body)["data"];
          valor = bodegasDistribucion[1]["Codigo"];

          transportistas = jsonDecode(jsonTransportista.body)["data"];
          valorTransportista = int.parse(transportistas[0]["Codigo"]);

          vehiculos = jsonDecode(jsonVehiculos.body)["data"];
          valorVehiculo = vehiculos[0]["Codigo"];

          rutas = jsonDecode(jsonRutas.body)["data"];

          //diasSemana = jsonDecode(jsonPlanificaciones.body)["diasDeLaSemana"];
          //planificacion = jsonDecode(jsonPlanificaciones.body)["eventosDePlanificacion"];
          tipoTransferencia = jsonDecode(jsonPlanificaciones.body)["tipoTranferencia"];
          valida = true;
        });
      } else {
        valida = false;
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: "No se pudo obtener los datos",
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
    //print(jsonDecode(jsonbodegasDistribucion.body));
  }

  Future<void> obtenerFarmacias(int ruta) async {
    String token = await _storage.readSecureData("token");
    try {
      var jsonObtenerBodegas = await obtenerBodegas(token, ruta);
      var msgJsonObtenerBodegas = jsonDecode(jsonObtenerBodegas.body)["msg"];
      var jsonObtenerBodegasDeco = jsonDecode(jsonObtenerBodegas.body)["data"];

      var items = jsonObtenerBodegasDeco.map((e) => e as Map<String, dynamic>).toList();

      if (msgJsonObtenerBodegas != "err") {
        pruebas.clear();
        setState(() {
          pruebas = items;
        });
        List<Map<String, dynamic>> valores = pruebas.cast<Map<String, dynamic>>();
        var contador = 0;
        for (var item in valores) {
          if (item["TRANSFERENCIA"] == 0) {
            contador = contador + 1;
          }
        }
        Fluttertoast.showToast(
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          msg: "Se cargarán $contador farmacias",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: "No se pudo obtener los datos",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } on TimeoutException {
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
    }
  }

  Future<void> _showAlertDialog(BuildContext context, List<Map<String, dynamic>> items) async {
    //bodegasSeleccionadas.clear();
    if (bodegasSeleccionadas.isEmpty) {
      for (var item in items) {
        if (item["Codigo"] != null && item["TRANSFERENCIA"] == 0) {
          bodegasSeleccionadas.add(item["Codigo"]);
        }
      }
    }

    await showDialog<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                scrollable: true,
                title: const Text('Selecciona las bodegas'),
                content: SizedBox(
                  height: 250,
                  child: SingleChildScrollView(
                    child: ListBody(
                      children: items
                          .map(
                            (item) => CheckboxListTile(
                              title: Text(
                                item['Nombre'],
                                style: TextStyle(
                                    color: item["TRANSFERENCIA"] > 0 ? Colors.red.withAlpha(255) : Colors.black.withAlpha(255),
                                    fontWeight: item["TRANSFERENCIA"] > 0 ? FontWeight.bold : FontWeight.normal),
                              ),
                              onChanged: (value) {
                                if (value == true) {
                                  bodegasSeleccionadas.add(item['Codigo']);
                                } else {
                                  bodegasSeleccionadas.remove(item['Codigo']);
                                }
                                setState(() {});
                              },
                              value: bodegasSeleccionadas.contains(item['Codigo']),
                            ),
                          )
                          .toList(),
                    ),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          });
        });
  }

  Future<void> _showAlertDialogTipoTransferencia(BuildContext context, List<Map<String, dynamic>> items) async {
    //bodegasSeleccionadas.clear();

    await showDialog<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                scrollable: true,
                title: const Text('Selecciona las áreas'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: items
                        .map(
                          (item) => CheckboxListTile(
                            title: Text(
                              item['Nombre'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onChanged: (value) {
                              if (value == true) {
                                tipoSeleccionado.add(item['Codigo']);
                              } else {
                                tipoSeleccionado.remove(item['Codigo']);
                              }
                              setState(() {});
                            },
                            value: tipoSeleccionado.contains(item['Codigo']),
                          ),
                        )
                        .toList(),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          });
        });
  }
}
