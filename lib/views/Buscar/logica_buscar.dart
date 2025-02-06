import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

Future<http.Response> buscarProductos(
    String token, String url, int timeoutSeconds,String valor) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/$url'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access-token': token
    },
    body: jsonEncode({
      'valor': valor,
    }),
  ).timeout(Duration(seconds: timeoutSeconds));
}