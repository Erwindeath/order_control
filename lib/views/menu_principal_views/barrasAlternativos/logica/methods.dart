import 'dart:convert';

import 'claseAlternativos.dart';

List<Busqueda> parsearBusqueda(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Busqueda>((json) {
    return Busqueda(codProducto: json["Cod_Producto"], name: json["Descripcion"], codBarra: json["Cod_Barra"]);
  }).toList();
}
