import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

int segundos = 30;
Future<http.Response> obtenerDatosCargo(int codCargo, int codUsuario, String token) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/obtener_cargo_pendiente'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({'codCargo': codCargo, 'codUsuario': codUsuario}),
      )
      .timeout(Duration(seconds: segundos));
}

Future<http.Response> obtenerInfoCargo(int codCargo, String token) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/obtener_info_cargo_pendiente'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codCargo': codCargo,
        }),
      )
      .timeout(Duration(seconds: segundos));
}
