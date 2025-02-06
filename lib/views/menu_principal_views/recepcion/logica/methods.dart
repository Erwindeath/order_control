import 'dart:convert';

import 'package:order_control/views/menu_principal_views/recepcion/logica/clase_cargos.dart';

List<CargosPendientes> parseCargos(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();

  return parsed.map<CargosPendientes>((json) {
    // Decodificar la cadena JSON en una lista
    int fraccion = json["Fraccion"] ?? 0;
    double costo = json["Costo"]?.toDouble() ?? 0.0;
    double parcial = json["Parcial"]?.toDouble() ?? 0.0;
    int cantReal = json["Cant_Real"] ?? 0;
    int codBodega = json["Cod_Bodega"] ?? 0;
    String documento = json["Documento"] ?? '';
    DateTime fecha = DateTime.parse(json["Fecha"] ?? '');
    String observacion = json["Observacion"] ?? '';
    double total = json["Total"]?.toDouble() ?? 0.0;
    String siglas = json["siglas"] ?? '';
    String productoIva = json["Producto_Iva"] ?? '';
    double costoTotal = json["costoVenta"]?.toDouble() ?? 0.0;
    double precioPublico = json["Precio_Publico"]?.toDouble() ?? 0.0;
    List<Map<String, dynamic>> listaLotesSeleccionados = [];
    final codBarraAdicionalString = json["Cod_Barra_Adicional"] ?? '[]';
    final decodedList = jsonDecode(codBarraAdicionalString) as List<dynamic>;
    // Extraer códigos de barras adicionales si existen
    List<String> codBarraAdicionalList = [];
    for (var item in decodedList) {
      if (item is Map && item.containsKey("Cod_Barra")) {
        codBarraAdicionalList.add(item["Cod_Barra"]);
      }
    }

    // Extraer lotes junto con su fecha de vencimiento
    final lotess = json["lotes"] ?? '[]';
    final decodLotes = jsonDecode(lotess) as List<dynamic>;

    List<Map<String, dynamic>> lotesList = [];
    for (var item in decodLotes) {
      if (item is Map &&
          item.containsKey("lotes") &&
          item.containsKey("Fecha_Vencimiento") &&
          item.containsKey("Cant_Unidad")) {
        lotesList.add({
          "Cod_Lote": item["Cod_Lote"],
          "lotes": item["lotes"],
          "Fecha_Vencimiento": item["Fecha_Vencimiento"],
          "Cant_Unidad": item["Cant_Unidad"]
        });
      }
    }

    //Todos los lotes por producto
    final listaLostes = json["loteslist"] ?? '[]';
    final decodLotesList = jsonDecode(listaLostes) as List<dynamic>;
    List<Map<String, dynamic>> listaLotes = [];
    for (var item in decodLotesList) {
      if (item is Map &&
          item.containsKey("lotes") &&
          item.containsKey("Fecha_Vencimiento") &&
          item.containsKey("Cod_Lote")) {
        listaLotes
            .add({"Cod_Lote": item["Cod_Lote"], "lotes": item["lotes"], "Fecha_Vencimiento": item["Fecha_Vencimiento"]});
      }
    }

    return CargosPendientes(
        codBarra: json["Cod_Barra"] as String,
        codProducto: json["Cod_Producto"] as int,
        descripcion: json["Descripcion"].toString().trim(),
        cantidad: json["Cant_Unidad"] as int,
        codBarraAdicional: codBarraAdicionalList,
        lotes: lotesList,
        loteslist: listaLotes,
        politica: json["politica"],
        valorPolitica: json["politicas"],
        cajasEscaneadas: 0,
        lotesSeleccionados: listaLotesSeleccionados,
        fraccion: fraccion,
        costo: costo,
        costoVenta: costoTotal,
        parcial: parcial,
        cantReal: cantReal,
        codBodega: codBodega,
        documento: documento,
        fecha: fecha,
        observacion: observacion,
        total: total,
        siglas: siglas,
        productoIva: productoIva,
        precioPublico: precioPublico);
  }).toList();
}
