import 'dart:convert';

import 'package:order_control/views/menu_principal_views/nuevasUbicaciones/clase/clases.dart';

List<SubBodega> parsearDataSubbodega(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<SubBodega>((json) {
    return SubBodega(codSubBodega: json["Cod_Sub_Bodega"], nombre: json["Nombre"]);
  }).toList();
}

List<Bloques> parsearBloquesBodega(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Bloques>((json) {
    return Bloques(codBloque: json["Cod_Bodega_Bloques"], nombre: json["Nombre"]);
  }).toList();
}

List<Niveles> parsearNiveles(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Niveles>((json) {
    return Niveles(codNivel: json["Cod_Bodega_Niveles"], nombre: json["Nombre"]);
  }).toList();
}

List<Ubicaciones> parsearUbicaciones(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Ubicaciones>((json) {
    return Ubicaciones(codUbicacion: json["Cod_Gestion_Ubicacion"], nombre: json["Nombre"]);
  }).toList();
}
