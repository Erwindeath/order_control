 import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

 Future <http.Response> notificacionesPendientes( token,int codUsuario) async {
    return http.post(
      Uri.parse(URL+'api/creedenciales/obtener_notificaciones_pendientes'),
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-token':'apitoken',
      'access-token': token,
        },
         body: jsonEncode(
            {'codUsuario':codUsuario}),
    ).timeout(const Duration(seconds: 10));
  }
  Future<http.Response> novedades(String token,int codCargo,int orden, int usuario) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/obtener_novedades_ordenes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': token
        },
        body: jsonEncode(
            {'codCargo': codCargo,'orden':orden,'codUsuario':usuario}),
      )
      .timeout(const Duration(seconds: 10));
}
Future<http.Response> obtenerMotivos(String token) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/obtener_motivos_perchador'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': token
        },
      )
      .timeout(const Duration(seconds: 10));
}
Future<http.Response> obtenerMotivosAdmin(String token) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/obtener_motivos_administrador'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': token
        },
      )
      .timeout(const Duration(seconds: 10));
}
Future<http.Response> novedadesPendientes(String token,int codUsuario,int tipo) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/obtener_data_pendientes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': token
        },
         body: jsonEncode(
            {'codUsuario':codUsuario,'tipo':tipo}),
      )
      .timeout(const Duration(seconds: 10));
}

Future<http.Response> novedadesPendientesGenerales(String token) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/obtener_data_pendientes_generales'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': token
        },
      )
      .timeout(const Duration(seconds: 10));
}
  Future<http.Response> completarNovedad(String token,int observacion,int codNotificacion,int codProducto,int codUsuario) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/completar_novedad'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': token
        },
        body: jsonEncode(
            {'codNotificacion': codNotificacion,'codProducto':codProducto,'observacion':observacion,'codUsuario':codUsuario}),
      )
      .timeout(const Duration(seconds: 10));
}
  Future<http.Response> completarNovedadAdmin(String token,int observacion,int codNotificacion,int codUsuario,String descripcion, String motivo, String codUbicacion,String ubicacionGeneral,String area) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/completar_novedad_admin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': token
        },
        body: jsonEncode(
            {'codNotificacion': codNotificacion,'observacion':observacion,'codUsuario':codUsuario,
            'descripcion':descripcion,'motivo':motivo,'ubicacion':codUbicacion,'ubicacionGeneral':ubicacionGeneral,'area':area}),
      )
      .timeout(const Duration(seconds: 10));
}

  /*Future<http.Response> completarNovedadAdminNovedad(String token,int observacion,int codNotificacion,int codUsuario) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/completar_novedad'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': token
        },
        body: jsonEncode(
            {'codNotificacion': codNotificacion,'observacion':observacion,'codUsuario':codUsuario}),
      )
      .timeout(const Duration(seconds: 10));
}*/

  Future<http.Response> completarNovedadObligatorias(String token,int observacion,int codNotificacion,
  int codProducto,int codUsuario,int codNotificacionesDet,int stockDisponible,String descripcion,String codUbicacion,String motivo) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/completar_novedad_obligatorias'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': token
        },
        body: jsonEncode(
            {'codNotificacion': codNotificacion,'codProducto':codProducto,'observacion':observacion,
            'codUsuario':codUsuario,'codNotificacioneDet':codNotificacionesDet,'stockDisponible':stockDisponible
            ,'descripcion':descripcion,'codUbicacion':codUbicacion,'motivo':motivo}),
      )
      .timeout(const Duration(seconds: 10));
}