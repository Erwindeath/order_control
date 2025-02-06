// ignore_for_file: avoid_unnecessary_containers, unnecessary_null_comparison, import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/complements/login/logica_login.dart';
import 'package:order_control/complements/principal_home.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/providers/push_notification.dart';
import 'package:order_control/views/Buscar/busqueda.dart';
import 'package:order_control/views/home/logica.dart';
import 'package:order_control/views/home/menu.dart';
import 'package:order_control/views/menu_principal_views/administracion/notificaciones_generales.dart';

import 'package:order_control/views/menu_principal_views/administracion/principal_admin.dart';
import 'package:order_control/views/menu_principal_views/inservibles/aprobar_inservibles.dart';
import 'package:order_control/views/menu_principal_views/nuevasUbicaciones/etiquetarNuevasUbicaciones.dart';
import 'package:order_control/views/menu_principal_views/perchador/notificacion_ordenes.dart';
import 'package:order_control/views/menu_principal_views/perchador/notificaciones_pendientes_obligatorias.dart';
import 'package:order_control/views/menu_principal_views/recepcion/recepcion_sobrestock.dart';

import 'package:order_control/views/ordenes_pendientes/ordenes_pendientes.dart';
import 'package:order_control/views/menu_principal_views/registrar_ubicaciones.dart';
import 'package:order_control/views/menu_principal_views/reimpresion/reimprimir_etiquetas.dart';
import 'package:upgrader/upgrader.dart';

import '../menu_principal_views/barrasAlternativos/codigo_barras_alternativos.dart';
import '../menu_principal_views/cargos_pendientes/despacho_mercaderia.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Color colorPrincipal = const Color(0xff62242C);
  final SecureStorage _storage = SecureStorage();
  var codPerfil = "";
  var codigoPrincipal = "";
  bool valida = false;
  List<Map<String, dynamic>> menu = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const MenuUsuario(),
      appBar: AppBar(
        title: Image.asset('assets/images/logoFSG.png', color: Colors.white, width: MediaQuery.of(context).size.width / 3 - 20),
        actions: [
          Builder(
              builder: (context) => IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.account_circle),
                    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  ))
        ],
      ),
      body: UpgradeAlert(
        child: Container(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RefreshIndicator(
                  child: data(),
                  onRefresh: () async {
                    obtenerCodPerfil();
                  })),
        ),
      ),
    );
  }

  Widget data() {
    if (valida == true) {
      return Principal(
        children: [
          MenuAcciones(
            itemPorLinea: 2,
            children: [
              if (menu.isNotEmpty)
                for (int i = 0; i < menu.length; i++)
                  if (menu[i] != null)
                    BotonMenu(
                      nombre: menu[i]["Descripcion"],
                      icono:
                          getIcon(menu[i]["Icono"]), // Reemplaza 'getIcon' con la función que obtiene el IconData correspondiente al nombre del icono
                      callback: () async {
                        if (menu[i]["Descripcion"] == "Despacho mercaderia") {
                          //await _storage.deleteSecureData("codCargo");
                          String cargoUsado = await _storage.readSecureData("codCargo") ?? "";
                          String token = await _storage.readSecureData("token");

                          String fecha = await _storage.readSecureData("fechaInicio") ?? "";
                          //await _storage.writeSecureData("fechaInicio", DateTime.now().toString());
                          if (cargoUsado != "") {
                            var respuesta = await obtenerInfoCargo(int.parse(cargoUsado), token);
                            var mensajeDecode = jsonDecode(respuesta.body);
                            String bodegaUsada = await _storage.readSecureData("bodegaUsada") ?? "";
                            String observacion = await _storage.readSecureData("observacion") ?? "";

                            if (mensajeDecode["msg"] != "err") {
                              await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => DespachoMercaderias(
                                      codCargo: int.parse(cargoUsado),
                                      fecha: fecha,
                                      farmacia: mensajeDecode["data"][0]["Bodega"],
                                      observacion: mensajeDecode["data"][0]["observacion"],
                                      token: token)));
                            } else if (bodegaUsada != "" && observacion != "") {
                              await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => DespachoMercaderias(
                                      codCargo: int.parse(cargoUsado), fecha: fecha, farmacia: bodegaUsada, observacion: observacion, token: token)));
                            } else {
                              Fluttertoast.showToast(
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                msg: "Error, no se pudo obtener la información de la orden bodega: $bodegaUsada, observacion: $observacion",
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            }
                          } else {
                            alertaInicial();
                          }
                        } else {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return getRoute(menu[i][
                                  "Descripcion"]); // Reemplaza 'getRoute' con la función que obtiene la ruta de la página correspondiente al nombre de la opción
                            }),
                          );
                        }
                      },
                      color: colorPrincipal,
                      habilitado: menu[i]["valor"] == 1 ? true : false,
                    ),
            ],
          ),
        ],
      );
    } else {
      return Center(
        child: Container(
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.blueGrey,
            ),
          ),
        ),
      );
    }
  }

  Future<void> alertaInicial() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return WillPopScope(
              onWillPop: () async => Future.value(false),
              child: AlertDialog(
                title: const Text("Escanee el cargo"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        //controller: editingController,
                        onChanged: (valor) {
                          if (valor.length >= 6) {
                            obtenerCargo(int.parse(valor));
                          }
                        },
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: "Número de cargo",
                          hintText: "Ingrese el número del cargo",
                          suffixIcon: Icon(Icons.file_copy),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
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
                ],
              ),
            );
          });
        });
  }

  IconData getIcon(String iconName) {
    // Mapea el nombre del icono a su correspondiente IconData
    switch (iconName) {
      case 'paste':
        return Icons.paste_outlined;
      case 'inventory':
        return Icons.inventory_outlined;
      case 'print':
        return Icons.print_rounded;
      case 'archive':
        return Icons.archive_outlined;
      case 'search':
        return Icons.search_rounded;
      case 'settings':
        return Icons.settings;
      case 'alarma':
        return Icons.notifications;
      case 'recipt':
        return Icons.medical_information_rounded;
      case 'aprove':
        return Icons.checklist_rtl_rounded;
      case 'barcode':
        return Icons.qr_code;
      case 'barcode_reader':
        return Icons.barcode_reader;
      default:
        return Icons.error; // Icono por defecto en caso de que no se encuentre el nombre del icono
    }
  }

  Widget getRoute(String routeName) {
    // Mapea el nombre de la ruta a su correspondiente widget de Flutter
    switch (routeName) {
      case 'Ordenes Pendientes':
        return const OrdenesPendientes();
      case 'Etiquetar':
        return NuevasUbicacionesEtiquetas(key: UniqueKey());
      case 'Registrar Ubicaciones':
        return const RegistrarUbicaciones();
      case 'Recibir productos':
        return const RegistrarUbicaciones();
      case 'Reimprimir etiquetas':
        return const ReimprimirEtiquetas();
      case 'Administración':
        return const AdministracionPrincipal();
      case 'Buscar':
        return const BuscarProductos();
      case 'Notificaciones ordenes':
        return const NotificacionesOrdenes();
      case 'Notificaciones':
        return const NotificacionesPendientes();
      case 'Notificaciones generales':
        return const NotificacionesGenerales();
      case 'Recepción por sobrestock':
        return const RecepcionSobreStock();
      case 'Aprobaciones Pendientes':
        return const AprobarInservibles();
      case 'Codigo barras alternativos':
        return const CodigosBarrasAlternativos();
      case 'Despacho mercaderia':
        return Container();
      default:
        return Container(); // Widget por defecto en caso de que no se encuentre la ruta
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerCodPerfil();
  }

  Future<void> obtenerCargo(int cargo) async {
    try {
      String codUsuario = await _storage.readSecureData("cod_usuario");
      String token = await _storage.readSecureData("token");
      var response = await obtenerDatosCargo(cargo, int.parse(codUsuario), token);
      var mensaje = jsonDecode(response.body);

      if (mensaje["msg"] != "err") {
        await _storage.writeSecureData("codCargo", cargo.toString());
        String fecha = DateTime.now().toString();
        await _storage.writeSecureData("fechaInicio", fecha);
        var respuesta = await obtenerInfoCargo(cargo, token);
        var mensajeDecode = jsonDecode(respuesta.body);
        if (mensajeDecode["msg"] != "err") {
          await _storage.deleteSecureData("codigoMovimiento");
          await _storage.writeSecureData("bodegaUsada", mensajeDecode["data"][0]["Bodega"]);
          await _storage.writeSecureData("observacion", mensajeDecode["data"][0]["observacion"]);
          await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => DespachoMercaderias(
                      data: response,
                      codCargo: cargo,
                      fecha: fecha,
                      farmacia: mensajeDecode["data"][0]["Bodega"],
                      observacion: mensajeDecode["data"][0]["observacion"],
                      token: token,
                    )),
            (route) => false,
          );
        } else {
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: "Error, no se pudo obtener la información de la orden",
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } else {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: "Error: $mensaje",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } on TimeoutException catch (e) {
      ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error al obtener los datos: $e",
              confirmButtonText: "Aceptar",
              text: "Comuníquese con el administrador",
              confirmButtonColor: Colores.esquemaColor));
    } catch (e) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Error: $e, comuníquese con el administrador",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> obtenerCodPerfil() async {
    PushNotification pushNotification = PushNotification();
    await pushNotification.initializeApp();
    WidgetsFlutterBinding.ensureInitialized();
    await Upgrader.clearSavedSettings();
    var data = await _storage.readSecureData("cod_perfil");
    String codUsuario = await _storage.readSecureData("cod_usuario");
    try {
      var response = await obtenerDataMenu(codUsuario);
      var valorIva = jsonDecode(response.body);

      if (jsonDecode(response.body)["data"] != null) {
        await _storage.writeSecureData("valorIva", valorIva["iva"][0]["ValorIva"].toString());
        setState(() {
          menu = (jsonDecode(response.body)["data"] as List).map((e) => e as Map<String, dynamic>).toList();
          codPerfil = data;
          codigoPrincipal = codUsuario;
          valida = true;
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
}
