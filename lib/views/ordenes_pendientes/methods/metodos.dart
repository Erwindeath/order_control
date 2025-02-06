import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:order_control/views/ordenes_pendientes/clase_generar.dart';
import 'package:soundpool/soundpool.dart';

List<Ordenes> parseOrdernes(String responseBody) {
    final parsed = json.decode(responseBody)["respuesta"].cast<Map<String, dynamic>>();
    return parsed.map<Ordenes>((json) {
      final codBarraAdicionalString = json["Cod_Barra_Adicional"];
      // Decodificar la cadena JSON en una lista de objetos
      final codBarraAdicionalList = jsonDecode(codBarraAdicionalString) as List<dynamic>;

      return Ordenes(
          clasificacion: json["Clasificacion"],
          baseCero: json["Base_0"].toDouble(),
          baseIva: json["Base_Iva"].toDouble(),
          iva: json["Iva"].toDouble(),
          total: json["Total"].toDouble(),
          codBodega: json["Cod_Bodega"],
          codBodegaTran: json["Cod_Bodega_Tran"],
          codProducto: json["Cod_Producto"],
          cantidad: json["Cant_Unidad"],
          descripcion: json["Descripcion"],
          codCargo: json["Cod_Cargo"],
          codRecorrido: json["codigo_descripcion"],
          codigoRecorrido: json["codigo"],
          laboratorio: json["laboratorio"],
          rack: json["Rack"],
          seccion: json["Seccion"],
          altura: json["Altura"],
          ubicacion: json["Ubicacion"],
          codBarra: json["Cod_Barra"],
          codCodigo: json["Cod_Codigo"],
          siglas: json["Siglas"],
          costo: 0.00,
          cantReal: 1,
          cantidadUnidad: 1,
          fraccion: 1,
          cedula: json["cedula"],
          razonSocial: json["Razon_Social"],
          placa: json["Placa"],
          observacion: json["Observacion"],
          observacionOrden: json["ObservacionOrden"],
          cargarDestino: json["confirmacionIngreso"],
          ivaProducto: json["ivaProducto"],
          codBarraAdicional: codBarraAdicionalList.map((item) => item["Cod_Barra"]).toList());
    }).toList();
  }

   Future<void> sounidoError() async {
    Soundpool pool = Soundpool.fromOptions(options: const SoundpoolOptions(streamType: StreamType.notification));

    int soundId = await rootBundle.load("assets/sonidos/ubicacion.mp3").then((ByteData soundData) {
      return pool.load(soundData);
    });
    await pool.play(soundId);
  }

  Future<void> sounidoErrorProducto() async {
    Soundpool pool = Soundpool.fromOptions(options: const SoundpoolOptions(streamType: StreamType.notification));

    int soundId = await rootBundle.load("assets/sonidos/producto.mp3").then((ByteData soundData) {
      return pool.load(soundData);
    });
  await pool.play(soundId);
  }
    Future<void> sounidoErrorCantidades() async {
    Soundpool pool = Soundpool.fromOptions(options: const SoundpoolOptions(streamType: StreamType.notification));

    int soundId = await rootBundle.load("assets/sonidos/errorcantidades.mp3").then((ByteData soundData) {
      return pool.load(soundData);
    });
  await pool.play(soundId);
  }
  
