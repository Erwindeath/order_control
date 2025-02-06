

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

Future<http.Response> obternerEtiquetas(String token, int codBodega) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/obtener_ubicaciones_etiquetadas'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access-token': token
    },
    body: jsonEncode({
      'codBodega':codBodega
      }),
  ).timeout(const Duration(seconds: 20));
}