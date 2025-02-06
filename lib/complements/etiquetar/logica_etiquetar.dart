import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

Future<http.Response> obternerBodegas(String token) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/obtener_data_bodegas'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access-token': token
    },
    
  );
}

Future<http.Response> obtenerDatosSeleccion(String token,String endpoint, int valor) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/$endpoint'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access-token': token
    },
    body: jsonEncode({
      'valor': valor,
    }),
  );
}

Future<http.Response> obternerRacks(
  String token,
  int codClasificacion,
  int codRack,
  int codSeccion,
  int codAltura,
) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/obtener_racks'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access-token': token
    },
    body: jsonEncode({
      'Cod_Gestion_Clasificacion': codClasificacion,
      'Cod_Gestion_Rack': codRack,
      'Cod_Gestion_Seccion': codSeccion,
      'Cod_Gestion_Altura': codAltura,
    }),
  );
}

Future<http.Response> registrarEtiquetas(String token, int codClasificacion,
    int codRack, int codSeccion, int codAltura, int codUbicacion,int codUsuario) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/registrar_etiquetas'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access-token': token
    },
    body: jsonEncode({
      'Cod_Gestion_Clasificacion': codClasificacion,
      'Cod_Gestion_Rack': codRack,
      'Cod_Gestion_Seccion': codSeccion,
      'Cod_Gestion_Altura': codAltura,
      'Cod_Gestion_Ubicacion': codUbicacion,
      'Cod_Usuario': codUsuario
    }),
  );
}
Future<http.Response> registrarEtiquetasNuevo(String token, String nombre, int codBodegaNivel) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/registrar_etiquetas'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access-token': token
    },
    body: jsonEncode({
      'nombre': nombre,
      'codBodegaNivel': codBodegaNivel,
    }),
  );
}