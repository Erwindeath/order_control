import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:order_control/views/menu_principal_views/cargos_pendientes/complements/sqlite.dart';

class DespachoMercaderia {
  final int iva;
  final String producto;
  final String siglas;
  final int fraccion;
  final int codProducto;
  int cantUnidad;
  final int cantFraccion;
  final double costo;
  final double cantRealInicial;
  final double parcial;
  final String codBarra;
  int cantUnidadFinal;
  var codBarraAdicional = [];
  TextEditingController controller;
  DespachoMercaderia({
    required this.iva,
    required this.producto,
    required this.siglas,
    required this.fraccion,
    required this.codProducto,
    required this.cantUnidad,
    required this.cantFraccion,
    required this.costo,
    required this.cantRealInicial,
    required this.parcial,
    required this.codBarra,
    required this.cantUnidadFinal,
    required this.codBarraAdicional,
  }) : controller = TextEditingController(text: cantUnidadFinal.toString());

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnCodProducto: codProducto,
      DatabaseHelper.columIva: iva,
      DatabaseHelper.columnProducto: producto,
      DatabaseHelper.columnSiglas: siglas,
      DatabaseHelper.columFraccionDv: fraccion,
      DatabaseHelper.columnCantidadUnidad: cantUnidad,
      DatabaseHelper.columnCantidadFraccion: cantFraccion,
      DatabaseHelper.columnCosto: costo,
      DatabaseHelper.columnCantidadRealInicial: cantRealInicial,
      DatabaseHelper.columnParcial: parcial,
      DatabaseHelper.columnCodBarra: codBarra,
      DatabaseHelper.columnCantidadUnidadFinal: cantUnidadFinal,
      DatabaseHelper.columnCodBarraAdicional: jsonEncode(codBarraAdicional), // Convertir la lista en una cadena JSON
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'Producto': producto,
      'Cod_Producto': codProducto,
      'Fraccion': fraccion,
      'Cant_U': cantUnidadFinal,
      'Cant_F': 0,
      'Costo': costo,
      'Cant_Real': cantUnidadFinal,
      'Parcial': double.parse((cantUnidadFinal * costo).toStringAsFixed(2)),
    };
  }

  factory DespachoMercaderia.fromMap(Map<String, dynamic> map) {
    return DespachoMercaderia(
      iva: map[DatabaseHelper.columIva],
      codProducto: map[DatabaseHelper.columnCodProducto],
      producto: map[DatabaseHelper.columnProducto],
      siglas: map[DatabaseHelper.columnSiglas],
      fraccion: map[DatabaseHelper.columFraccionDv],
      cantUnidad: map[DatabaseHelper.columnCantidadUnidad],
      cantFraccion: map[DatabaseHelper.columnCantidadFraccion],
      costo: map[DatabaseHelper.columnCosto],
      cantRealInicial: map[DatabaseHelper.columnCantidadRealInicial],
      parcial: map[DatabaseHelper.columnParcial],
      codBarra: map[DatabaseHelper.columnCodBarra],
      cantUnidadFinal: map[DatabaseHelper.columnCantidadUnidadFinal],
      codBarraAdicional: jsonDecode(map[DatabaseHelper.columnCodBarraAdicional]),
    );
  }
  void updateCantidad(int nuevaCantidad) {
    cantUnidadFinal = nuevaCantidad;
    controller.text = nuevaCantidad.toString(); // Actualiza el controlador
  }
}

List<DespachoMercaderia> parseOrdernesPendientes(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<DespachoMercaderia>((json) {
    final codBarraAdicionalString = json["Cod_Barra_Adicional"];
    // Decodificar la cadena JSON en una lista de objetos
    final codBarraAdicionalList = jsonDecode(codBarraAdicionalString) as List<dynamic>;
    return DespachoMercaderia(
      iva: json["Iva"],
      codBarra: json["Cod_Barra"],
      codProducto: json["Cod_Producto"],
      producto: json["Producto"].toString().trim(),
      siglas: json["Siglas"],
      cantUnidad: json["Cant_Unidad"] ?? 0,
      cantFraccion: json["Cant_Fraccion"] ?? 0,
      codBarraAdicional: codBarraAdicionalList.map((item) => item["Cod_Barra"]).toList(),
      fraccion: json["Fraccion"],
      costo: double.parse(json["Costo"].toString()),
      cantRealInicial: double.parse(json["Cant_Real"].toString()),
      parcial: double.parse(json["Parcial"].toString()),
      cantUnidadFinal: 0,
      //echaEscaneo: json["Fecha_Inicio"].toString(),
    );
  }).toList();
}
