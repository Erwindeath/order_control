import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:order_control/complements/globals/url.dart';

Future<http.Response> obtenerCargos(String token, int codcargo) {
  return http
      .post(
        Uri.parse(URL + 'api/Recepcionsobrestock/obtener_reception_mercaderia_sobrestock'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codCargo': codcargo,
        }),
      )
      .timeout(const Duration(seconds: 20));
}

Future<http.Response> enviarRecepcionDatos(
    String token,
    int tipoTransferencia,
    int codEstacion,
    int codSesion,
    int codBodegaDevolucion,
    int codBodegaDistribucion,
    int codBodegaTran,
    int codCargoPendiente,
    int validadDevolucion,
    String jsonDetalleDevolucion,
    int validadDistribucion,
    String jsonDetalleDistribucion,
    int validaCobro,
    String jsonCobro,
    int validaLotes,
    String jsonLotes,
    String totalesDevolucion,
    String totalesDistribucion,
    String totalesCobro,
    int codUsuario) {
  return http
      .post(
        Uri.parse(URL + 'api/Recepcionsobrestock/movimiento_recepcion_sobrestock_movimientos'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'tipoTransferencia': tipoTransferencia,
          'codEstacion': codEstacion,
          'codSesion': codSesion,
          'codBodegaDevolucion': codBodegaDevolucion,
          'codBodegaDistribucion': codBodegaDistribucion,
          'codBodegaTran': codBodegaTran,
          'codCargoPendiente': codCargoPendiente,
          'validadDevolucion': validadDevolucion,
          'jsonDetalleDevolucion': jsonDetalleDevolucion,
          'validadDistribucion': validadDistribucion,
          'jsonDetalleDistribucion': jsonDetalleDistribucion,
          'validaCobro': validaCobro,
          'jsonCobro': jsonCobro,
          'validaLotes': validaLotes,
          'jsonLotes': jsonLotes,
          'totalesDevolucion': totalesDevolucion,
          'totalesDistribucion': totalesDistribucion,
          'totalesCobro': totalesCobro,
          'codUsuario': codUsuario,
        }),
      )
      .timeout(const Duration(seconds: 20));
}

Future<http.Response> enviarRecepcionDatos2(
    String token,
    int tipoTransferencia,
    int codEstacion,
    int codSesion,
    int codBodegaDevolucion,
    int codBodegaDistribucion,
    int codBodegaTran,
    int codCargoPendiente,
    int validadPorAprobacion,
    String jsonDestino6,
    String totalesDestino6,
    String observacion,
    int validadMas,
    String jsonDemas,
    int validadMenos,
    String jsonDemenos,
    int validaCobro,
    String jsonCobro,
    int validadDevolucion,
    String jsonDetalleDevolucion,
    int validadDistribucion,
    String jsonDetalleDistribucion,
    int validaLotes,
    String jsonLotes,
    String totalesDevolucion,
    String totalesDistribucion,
    String totalesCobro,
    codUsuario) {
  return http
      .post(
        Uri.parse(URL + 'api/Recepcionsobrestock/movimiento_recepcion_sobrestock_valida_envio'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'tipoTransferencia': tipoTransferencia,
          'codEstacion': codEstacion,
          'codSesion': codSesion,
          'codBodegaDevolucion': codBodegaDevolucion,
          'codBodegaDistribucion': codBodegaDistribucion,
          'codBodegaTran': codBodegaTran,
          'codCargoPendiente': codCargoPendiente,
          'validadPorAprobacion':validadPorAprobacion,
          'jsonDestino6':jsonDestino6,
          'totalesDestino6':totalesDestino6,
          'observacion':observacion,
          'validaMas': validadMas,
          'jsonDemas': jsonDemas,
          'validaMenos': validadMenos,
          'jsonDemenos': jsonDemenos,
          'validaCobro': validaCobro,
          'jsonCobro': jsonCobro,
          'validadDevolucion': validadDevolucion,
          'jsonDetalleDevolucion': jsonDetalleDevolucion,
          'validadDistribucion': validadDistribucion,
          'jsonDetalleDistribucion': jsonDetalleDistribucion,
          'validaLotes': validaLotes,
          'jsonLotes': jsonLotes,
          'totalesDevolucion': totalesDevolucion,
          'totalesDistribucion': totalesDistribucion,
          'totalesCobro': totalesCobro,
          'codUsuario': codUsuario
        }),
      )
      .timeout(const Duration(seconds: 20));
}

Future<http.Response> obtenerImpresora(String token, int codTipo) {
  return http
      .post(
        Uri.parse(URL + 'api/Recepcionsobrestock/obtener_impresora'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codTipo': codTipo,
        }),
      )
      .timeout(const Duration(seconds: 20));
}


/*Future<void> guardarData(String codLaboratorio, String nombreLaboratorio, String codInventario) async {
  await storage.writeSecureData("codLaboratorio", codLaboratorio);
  await storage.writeSecureData("nombreLaboratorio", nombreLaboratorio);
  await storage.writeSecureData("codInventario", codInventario);
}*/
