import 'dart:convert';

import 'package:order_control/views/menu_principal_views/inservibles/logica/clase_inservibles.dart';

List<PorAprobacion> parsearPendientes(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<PorAprobacion>((json) {
    return PorAprobacion(
      productoIva: json["Producto_Iva"],
      precioPublico: double.parse(json["Precio_Publico"].toString()),
      costoVenta: double.parse(json["costoVenta"].toString()),
      codCargo: int.parse(json["Cod_Cargo"]),
      fecha: json["Fecha"],
      codBodega: json["Cod_Bodega"],
      descripcion: json["Descripcion"],
      codProducto: json["Cod_Producto"],
      codBodegaTran: json["Cod_Bodega_Tran"],
      nombreBodega: json["NombreBodega"],
      lote:json["Lote"],
      codLote: int.parse(json["Cod_Lote"]),
      fechaV: json["Fecha_Vencimiento"],
      usuario: json["Nombres"],
      codUsuario: json["Cod_Usuario"],
      cantUnidad: json["Cant_Unidad"],
      cantFraccion: json["Cant_Fraccion"],
      cantidadReal: json["Cant_Real"],
      fraccion: json["Fraccion"],
      costo: double.parse(json["Costo"].toString()),
      parcial: double.parse(json["Parcial"].toString()),
      observacion: json["Observacion"],
      base0: double.parse(json["Base_0"].toString()),
      baseIva: double.parse(json["Base_Iva"].toString()),
      iva: double.parse(json["Iva"].toString()),
      total: double.parse(json["Total"].toString()),
    );
  }).toList();
}
