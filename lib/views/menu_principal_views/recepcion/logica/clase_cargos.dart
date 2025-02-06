import 'dart:convert';

import 'package:order_control/views/menu_principal_views/recepcion/logica/database/cargos_sobre_stock.dart';

class CargosPendientes {
  final int codProducto;
  final String codBarra;
  final String descripcion;
  final int cantidad;
  final String politica;
  final String valorPolitica;
  final int fraccion;
  final double costo;
  final double parcial;
  final double costoVenta;
  final int cantReal;
  final int codBodega;
  final String documento;
  final DateTime fecha;
  final String observacion;
  final double total;
  final String siglas;
  final String productoIva;
  final double precioPublico;

  var codBarraAdicional = [];
  var lotes = [];
  var loteslist = [];
  var lotesSeleccionados = [];

  final int cajasEscaneadas;

  CargosPendientes(
      {required this.codBarra,
      required this.codProducto,
      required this.descripcion,
      required this.cantidad,
      required this.fraccion,
      required this.costo,
      required this.parcial,
      required this.cantReal,
      required this.costoVenta,
      required this.codBodega,
      required this.documento,
      required this.fecha,
      required this.observacion,
      required this.total,
      required this.siglas,
      required this.productoIva,
      required this.precioPublico,
      List<dynamic>? codBarraAdicional,
      List<dynamic>? lotes,
      List<dynamic>? loteslist,
      List<dynamic>? lotesSeleccionados,
      required this.politica,
      required this.valorPolitica,
      required this.cajasEscaneadas})
      : codBarraAdicional = codBarraAdicional ?? [],
        lotes = lotes ?? [],
        loteslist = loteslist ?? [],
        lotesSeleccionados = lotesSeleccionados ?? [];

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnCodProducto: codProducto,
      DatabaseHelper.columnProducto: descripcion,
      DatabaseHelper.columnCodBarra: codBarra,
      DatabaseHelper.columnCantidad: cantidad,
      DatabaseHelper.columnCodBarraAdicional: jsonEncode(codBarraAdicional),
      DatabaseHelper.columnLotes: jsonEncode(lotes),
      DatabaseHelper.columLotesList: jsonEncode(loteslist),
      DatabaseHelper.columnPolitica: politica,
      DatabaseHelper.columnValorPolitica: valorPolitica,
      DatabaseHelper.columncajasEscaneadas: 0, // valor predeterminado
      DatabaseHelper.columnLotesSeleccionados: jsonEncode(lotesSeleccionados),
      // Nuevos campos
      DatabaseHelper.columnFraccion: fraccion,
      DatabaseHelper.columnCosto: costo,
      DatabaseHelper.columnParcial: parcial,
      DatabaseHelper.columnCantReal: cantReal,
      DatabaseHelper.columnCodBodega: codBodega,
      DatabaseHelper.columnDocumento: documento,
      DatabaseHelper.columnFecha: fecha.toString(),
      DatabaseHelper.columnObservacion: observacion,
      DatabaseHelper.columnTotal: total,
      DatabaseHelper.columnPrecioVenta: costoVenta,
      DatabaseHelper.columnSiglas: siglas,
      DatabaseHelper.columnProductoIva: productoIva,
      DatabaseHelper.columnPrecioPublico: precioPublico
    };
  }

  factory CargosPendientes.fromMap(Map<String, dynamic> map) {
    return CargosPendientes(
        codBarra: map[DatabaseHelper.columnCodBarra],
        codProducto: map[DatabaseHelper.columnCodProducto],
        cantidad: map[DatabaseHelper.columnCantidad],
        descripcion: map[DatabaseHelper.columnProducto],
        codBarraAdicional: jsonDecode(map[DatabaseHelper.columnCodBarraAdicional]),
        lotes: jsonDecode(map[DatabaseHelper.columnLotes]),
        loteslist: jsonDecode(map[DatabaseHelper.columLotesList]),
        politica: map[DatabaseHelper.columnPolitica],
        valorPolitica: map[DatabaseHelper.columnValorPolitica],
        cajasEscaneadas: map[DatabaseHelper.columncajasEscaneadas],
        lotesSeleccionados: jsonDecode(map[DatabaseHelper.columnLotesSeleccionados]),
        costoVenta: map[DatabaseHelper.columnPrecioVenta],
        fraccion: map[DatabaseHelper.columnFraccion],
        costo: map[DatabaseHelper.columnCosto],
        parcial: map[DatabaseHelper.columnParcial],
        cantReal: map[DatabaseHelper.columnCantReal],
        codBodega: map[DatabaseHelper.columnCodBodega],
        documento: map[DatabaseHelper.columnDocumento],
        fecha: DateTime.parse(map[DatabaseHelper.columnFecha]),
        observacion: map[DatabaseHelper.columnObservacion],
        total: map[DatabaseHelper.columnTotal],
        siglas: map[DatabaseHelper.columnSiglas],
        productoIva: map[DatabaseHelper.columnProductoIva],
        precioPublico: map[DatabaseHelper.columnPrecioPublico]);
  }
  @override
  String toString() {
    return 'CargosPendientes{'
        'codProducto: $codProducto, '
        'cantidad: $cantidad, '
        'descripcion: $descripcion, '
        'codigoBarra: $codBarra, '
        // 'fraccion: $fraccion, '
        // 'costo: $costo, '
        // 'parcial: $parcial, '
        // 'cantReal: $cantReal, '
        //'codBodega: $codBodega, '
        //'documento: $documento, '
        //'precioVenta: $costoVenta, '
        //'fecha: $fecha, '
        //'observacion: $observacion, '
        //'total: $total, '
        //'siglas: $siglas, '
        //'productoIva: $productoIva, '
        // 'codBarraAdicional: $codBarraAdicional, '
        'lotes: $lotes, '
        'loteslist: $loteslist, '
        //'politica: $politica, '
        //'valorPolitica: $valorPolitica, '
        'cajasEscaneadas: $cajasEscaneadas, '
        'lotesSeleccionados: $lotesSeleccionados '
        // 'PrecioPublico: $precioPublico '
        '}';
  }

  /* static List<Map<String, dynamic>> convertirAListaMap(
      List<CargosPendientes> productos) {
    List<Map<String, dynamic>> listaMapas = [];
    for (var producto in productos) {
      Map<String, dynamic> mapa = {
        'codProducto': producto.codProducto,
        'Descripcion': producto.descripcion,
        'cantidad': producto.cantidad,
        'codBarra': producto.codBarra,
        'adicional': producto.codBarraAdicional
      };
      listaMapas.add(mapa);
    }
    return listaMapas;
  }

  static List<Map<String, dynamic>> convertirAlistaEspecial(
      List<CargosPendientes> productos) {
    List<Map<String, dynamic>> listaMapas = [];
    for (var producto in productos) {
      Map<String, dynamic> mapa = {
        'codProducto': producto.codProducto,
        'Descripcion': producto.descripcion,
        'cantidad': producto.cantidad,
        'codBarra': producto.codBarra,
        'adicional': producto.codBarraAdicional
      };
      listaMapas.add(mapa);
    }
    return listaMapas;
  }*/
  static List<Map<String, dynamic>> convertirAlistaEspecial(List<CargosPendientes> productos) {
    List<Map<String, dynamic>> listaMapas = [];
    for (var producto in productos) {
      Map<String, dynamic> mapa = {
        'codProducto': producto.codProducto,
        'producto': producto.descripcion,
      };
      listaMapas.add(mapa);
    }
    return listaMapas;
  }
}
