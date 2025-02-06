import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

Future<http.Response> buscarProducto(String token, String descripcion) async {
  return http.post(Uri.parse(URL + 'api/creedenciales/buscar_productos_facturacion'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'api-token': 'apitoken',
        'access-token': token,
      },
      body: jsonEncode({'descripcion': descripcion}));
}

Future<http.Response> buscarProductoBarra(String token, String descripcionBarra) async {
  return http.post(Uri.parse(URL + 'api/creedenciales/buscar_productos_barras'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'api-token': 'apitoken',
        'access-token': token,
      },
      body: jsonEncode({'descripcionBarra': descripcionBarra}));
}
