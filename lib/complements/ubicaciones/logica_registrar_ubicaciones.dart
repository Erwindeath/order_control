import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';
//import 'package:order_control/complements/ubicaciones/user.dart';

/*Future<http.Response> registrarUbicacionesProductos(
    String token, List<User> users) async {
  List<Map<String, dynamic>> userList = [];
  for (User user in users) {
    userList.add({
      'codProducto': user.codProducto.replaceAll('\n', ''),
      'codUbicacion': user.codUbicacion,
    });
  }

  final body = jsonEncode(
    userList,
  );

  return http.post(
      Uri.parse(URL + "api/creedenciales/registrar_ubicaciones_bodega"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access-token': token
      },
      body: body);
}
*/

Future<http.Response> registrarUbicacionesProductos(String token, int codProducto, int codUBicacion, int codUsuario, String origen) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/registrar_ubicaciones_bodega'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
    body: jsonEncode({
      'codProducto': codProducto,
      'codUbicacion': codUBicacion,
      'codUsuario': codUsuario,
      'origen': origen,
    }),
  );
}

Future<http.Response> actualizarUbicacionesProductos(String token, int codProducto, int codUBicacion, int codUsuario, String origen) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/actualizar_ubicaciones_bodega'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
    body: jsonEncode({
      'codProducto': codProducto,
      'codUbicacion': codUBicacion,
      'codUsuario': codUsuario,
      'origen': origen,
    }),
  );
}

Future<http.Response> obtenerProductos(String token) {
  return http.post(
    Uri.parse(URL + "api/creedenciales/obtener_productos_codbarra"),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
  );
}

Future<http.Response> obtenerUbicacionesRegistradas(String token) {
  return http.post(
    Uri.parse(URL + "api/creedenciales/obtener_ubicaciones_registradas"),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
  );
}
