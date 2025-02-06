import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

Future<http.Response> obtenerDatosIniciales(String token, String url, int timeoutSeconds) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/$url'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
  ).timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> obtenerBodegas(
  String token,
  int codSector,
) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/obtener_bodegas'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'Cod_Sector': codSector,
        }),
      )
      .timeout(const Duration(seconds: 3));
}

Future<http.Response> obtenerBodegaRuta(String token, String url, String idRuta, int timeoutSeconds) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/$url'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
  ).timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> obtenerOrdenesRuta(String token, String url, int idRuta, int timeoutSeconds) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codRuta': idRuta,
        }),
      )
      .timeout(Duration(seconds: timeoutSeconds));
}

Future<http.Response> guardarPlanificaciones(
    int codBogedaOrigen,
    int codRuta,
    List<dynamic> bodegas,
    String codTransportista,
    int codVehiculo,
    String observacion,
    //int codDia,
    String token,
    String url,
    int codUsuario,
    List<dynamic> tipoTranferencia) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'CodBodegaOrigen': codBogedaOrigen,
          'CodRuta': codRuta,
          'Bodegas': bodegas,
          'codTransportista': codTransportista,
          'codVehiculo': codVehiculo,
          'observacion': observacion,
          // 'codDia':codDia,
          'codUsuario': codUsuario,
          'tipoTranferencia': tipoTranferencia
        }),
      )
      .timeout(const Duration(seconds: 60));
}
