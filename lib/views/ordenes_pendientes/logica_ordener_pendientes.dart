import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

Future<http.Response> obtenerOrdenesDatosIniciales(String token, String url, int timeoutSeconds) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/$url'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
  ).timeout(Duration(seconds: timeoutSeconds));
}
Future<http.Response> obtenerUsuariosAutorizados(String token, String url, int timeoutSeconds) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/$url'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
  ).timeout(Duration(seconds: timeoutSeconds));
}
Future<http.Response> obtenerDatosPorArea(String token, String url, int timeoutSeconds, String codUsuario, int tipoTranferencia, int codRecorrido) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({'codUsuario': codUsuario, 'tipoTransferencia': tipoTranferencia, 'codRecorrido': codRecorrido}),
      )
      .timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> obtenerDatosReccorrido(String token, String url, int timeoutSeconds) {
  return http.post(Uri.parse(URL + 'api/creedenciales/$url'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token}).timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> obtenerCanales(String token, String url, int timeoutSeconds, int codRack, int clasificacion) {
  return http
      .post(Uri.parse(URL + 'api/creedenciales/$url'),
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
          body: jsonEncode({'rack': codRack, 'clasificacion': clasificacion}))
      .timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> enviarRecorrido(String token, String url, int timeoutSeconds, String codUsuario, int codRecorrido) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({'codUsuario': codUsuario, 'codRecorrido': codRecorrido}),
      )
      .timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> verificarOrdenes(String token, String url, int timeoutSeconds, String codUsuario) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codUsuario': codUsuario,
        }),
      )
      .timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> verificarOrdenesCargadas(String token, String url, int timeoutSeconds, String codCargo, int codRecorrido) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({'cod_cargo': codCargo, 'codRecorrido': codRecorrido}),
      )
      .timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> agregarCodBarra(String token, String url, int timeoutSeconds, String codBarra, int codUsuario, int codProducto) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codBarra': codBarra,
          'codProducto': codProducto,
          'codUsuario': codUsuario,
        }),
      )
      .timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> enviarNotificacion(
    int usuario,
    String token,
    String urls,
    int timeoutSeconds,
    String ubicacion,
    int codUsuario,
    String nombre,
    int codProducto,
    int codUbicacion,
    String tokenPerchador,
    int codCargo,
    String descripcionProducto,
    String canal,
    int cantidadReal,
    int cantidadEscaneada,
    int orden,
    int tipo) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/$urls'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'usuario': usuario,
          'codUsuario': codUsuario,
          'nombreUsuario': nombre,
          'codCargo': codCargo,
          'codProducto': codProducto,
          'descripcionProducto': descripcionProducto,
          'codUbicacion': codUbicacion,
          'Ubicacion': ubicacion,
          'canal': canal,
          'tokenPerchador': tokenPerchador,
          'cantidadReal': cantidadReal,
          'CantidadEscaneada': cantidadEscaneada,
          'orden': orden,
          'tipo': tipo
        }),
      )
      .timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> guardarPedido(
    String token,
    String url,
    int timeoutSeconds,
    int codEstacion,
    int codSesion,
    int codBodegaOrigen,
    int codBodegaDestino,
    String documento,
    double baseCero,
    double baseIva,
    double iva,
    double total,
    String observacion,
    int tipoTransferencia,
    int codUsuario,
    String codTransportista,
    String placa,
    List<Map<String, dynamic>> productos,
    String razonSocialTrans,
    int bulto,
    int tipoMovimiento,
    int confirmacionIngreso,
    int valida,
    List<Map<String, dynamic>> jsonDataHistorica 
    ) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'Tipo_Movimiento': tipoMovimiento,
          'Cod_Estacion': codEstacion,
          'Cod_Sesion': codSesion,
          'Cod_Bodega': codBodegaDestino,
          'Total_Costo': total,
          'Base_0': baseCero,
          'Base_iva': baseIva,
          'IVA': iva,
          'Observacion': observacion,
          'Cod_Bodega_Tran': codBodegaOrigen,
          'Cod_Cargo_Pendiente': int.parse(documento), //pilas
          'Identificacion_Transportista': codTransportista,
          'Razon_Social_Transportista': razonSocialTrans,
          'Placa': placa,
          'Cod_Usuario': codUsuario,
          'TIPO': tipoTransferencia,
          'Bulto': bulto,
          'Json_Detalle': productos,
          'confirmacionIngreso': confirmacionIngreso,
          'valida': valida,
          'jsonDataHistorica':jsonDataHistorica
        }),
      )
      .timeout(Duration(seconds: timeoutSeconds));
}
