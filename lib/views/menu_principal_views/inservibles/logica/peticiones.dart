import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

Future<http.Response> obtenerProductosInserviblesPendientes(String token, int codcargo) {
  return http
      .post(
        Uri.parse(URL + 'api/inservibles/obtener_productos_pendientes'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codCargo': codcargo,
        }),
      )
      .timeout(const Duration(seconds: 20));
}

Future<http.Response> completarPendiente(String token, int codProducto, int codLote, int codcargo, int codBodegaRecibe, int codBodegaEnvia,
    String observacion, String data, double base0, double baseIva, double iva, double total) {
  return http
      .post(
        Uri.parse(URL + 'api/inservibles/aceptar_pendiente'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codProducto': codProducto,
          'codLote': codLote,
          'codCargo': codcargo,
          'codBodegaRecibe': codBodegaRecibe,
          'codBodegaEnvia': codBodegaEnvia,
          'observacion': observacion,
          'datas': data,
          'base0': base0,
          'baseIva': baseIva,
          'iva': iva,
          'total': total,
        }),
      )
      .timeout(const Duration(seconds: 20));
}

Future<http.Response> rechazarPendiente(String token, int codProducto, int codLote, int codcargo, int codBodegaRecibe, int codBodegaEnvia,
    String observacion, String data, String cobro, double base0, double baseIva, double iva, double total, int destino) {
  return http
      .post(
        Uri.parse(URL + 'api/inservibles/rechazar_pendiente'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codProducto': codProducto,
          'codLote': codLote,
          'codCargo': codcargo,
          'codBodegaRecibe': codBodegaRecibe,
          'codBodegaEnvia': codBodegaEnvia,
          'observacion': observacion,
          'datas': data,
          'cobro': cobro,
          'base0': base0,
          'baseIva': baseIva,
          'iva': iva,
          'total': total,
          'destino': destino
        }),
      )
      .timeout(const Duration(seconds: 20));
}
