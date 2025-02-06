import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

Future<http.Response> guardarTransferencia(
    String token,
    String url,
    int timeoutSeconds,
    int codEstacion,
    int codSesion,
    int codBodegaOrigen,
    int codCargo,
    double baseCero,
    double baseIva,
    double iva,
    double total,
    double baseCeroNOVA,
    double baseIvaNOVA,
    double ivaNOVA,
    double totalNOVA,
    int codUsuario,
    List<Map<String, dynamic>> productos,
    int bulto,
    int valida,
    List<Map<String, dynamic>> jsonDataHistorica) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'Cod_Estacion': codEstacion,
          'Cod_Sesion': codSesion,
          'Total_Costo': total,
          'Base_0': baseCero,
          'Base_iva': baseIva,
          'IVA': iva,
          'Total_CostoNova': totalNOVA,
          'Base_0Nova': baseCeroNOVA,
          'Base_ivaNova': baseIvaNOVA,
          'IVANova': ivaNOVA,
          'Cod_Bodega_Tran': codBodegaOrigen,
          'Cod_Cargo_Pendiente': codCargo,
          'Cod_Usuario': codUsuario,
          'Bulto': bulto,
          'Json_Detalle': productos,
          'valida': valida,
          'jsonDataHistorica': jsonDataHistorica
        }),
      )
      .timeout(Duration(seconds: timeoutSeconds));
}
