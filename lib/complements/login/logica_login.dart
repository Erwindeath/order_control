import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:order_control/complements/globals/url.dart';
import 'package:order_control/complements/storage/storage.dart';

final SecureStorage _storage = SecureStorage();

Future<http.Response> loginBodegaUsuario(String user, String pass) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/autentificar-usuario-bodega'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'usuario': user,
      'clave': pass,
    }),
  );
}

Future<http.Response> loginBodegaUsuarioQR(String llave) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/autentificar-usuario-bodega-qr'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'llave': llave,
    }),
  );
}

Future<bool> registrarDatosUsuariosBodega(json) async {
  if (json["data"] != null) {
    if (json["data"].length > 0) {
      var codUsuario = json["data"]["usuariocod"];
      var token = json["data"]["token"];
      var codPerfil = json["data"]["cod_perfil"];
      var nombre = json["data"]["Nombres"];
      var cargo = json["data"]["Cargo"];
      var codSesion = json["data"]["dato"];
      var canales = json["data"]["canales"];
      var canal = json["data"]["canal"];
      if (canal != "") {
        await FirebaseMessaging.instance.subscribeToTopic(canal);
        await _storage.writeSecureData("canal", canal.toString());
      } else {
        await FirebaseMessaging.instance.subscribeToTopic(canales);
        await _storage.writeSecureData("canal", canales.toString());
      }

      await _storage.writeSecureData("cod_usuario", codUsuario.toString());
      await _storage.writeSecureData("cod_perfil", codPerfil.toString());
      await _storage.writeSecureData("token", token.toString());
      await _storage.writeSecureData("Nombre", nombre.toString());
      await _storage.writeSecureData("Cargo", cargo.toString());
      await _storage.writeSecureData("codSesion", codSesion.toString());

      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future<http.Response> obtenerDataMenu(String codUsuario) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/obtener-data-menu'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'codUsuario': codUsuario,
        }),
      )
      .timeout(const Duration(seconds: 15));
}
