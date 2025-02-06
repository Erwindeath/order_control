// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:order_control/views/menu_principal_views/recepcion/logica/clase_cargos.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "cargos.db";
  // static const _databaseVersion = 3;

  static const table = 'sobrestocck';

  static const columnCodProducto = 'Cod_Producto'; // No change to column names
  static const columnCodBarra = 'codBarra';
  static const columnProducto = 'Descripcion';
  static const columnCantidad = 'cantidad';
  static const columnCodBarraAdicional = 'codBarraAdicional';
  static const columnLotes = 'lotes';
  static const columLotesList = 'loteslista';
  static const columnPolitica = 'politica';
  static const columnValorPolitica = 'politicas';
  static const columncajasEscaneadas = 'cantEscaneada';

  static const columnLotesSeleccionados = 'listaLotesSeleccionados';
  // Nuevas columnas
  static const columnFraccion = 'Fraccion';
  static const columnCosto = 'Costo';
  static const columnParcial = 'Parcial';
  static const columnCantReal = 'CantReal';
  static const columnCodBodega = 'CodBodega';
  static const columnDocumento = 'Documento';
  static const columnFecha = 'Fecha';
  static const columnObservacion = 'Observacion';
  static const columnTotal = 'Total';
  static const columnSiglas = 'Siglas';
  static const columnProductoIva = 'ProductoIva';
  static const columnPrecioVenta = 'precioVenta';
  static const columnPrecioPublico = 'precioPublico';

  // Make this class a singleton to avoid multiple instances of the database.
  static Database? _databaseOrdenes;

  Future<Database?> get database async {
    if (_databaseOrdenes != null) {
      return _databaseOrdenes;
    }

    _databaseOrdenes = await _initDatabase();
    return _databaseOrdenes;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, _databaseName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $table($columnCodProducto INTEGER PRIMARY KEY,$columnProducto TEXT,$columnCodBarra TEXT, $columnCantidad INTEGER, $columnCodBarraAdicional TEXT,$columnLotes TEXT,$columLotesList TEXT, $columnPolitica TEXT,$columnValorPolitica TEXT, $columncajasEscaneadas INTEGER,$columnLotesSeleccionados TEXT, $columnFraccion INTEGER, $columnCosto REAL, $columnParcial REAL, $columnCantReal INTEGER, $columnCodBodega INTEGER, $columnDocumento TEXT, $columnFecha TEXT, $columnObservacion TEXT, $columnTotal REAL, $columnSiglas TEXT, $columnProductoIva TEXT, $columnPrecioVenta REAL, $columnPrecioPublico REAL)',
        );
      },
      version: 3,
    );
  }

  Future<void> insert(CargosPendientes producto) async {
    final db = await database;

    await db!.insert(table, producto.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> deleteTable() async {
    final db = await database;
    await db?.delete(table);
  }

  Future<List<CargosPendientes>> getAllProductos(String valor) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db!.query(
      table,
      //where: "$validacionProducto = ?",
      // whereArgs: [valor],
    );
    return List.generate(maps.length, (i) {
      return CargosPendientes.fromMap(maps[i]);
    });
  }

  Future<void> updateColumnLotesSeleccionados(int codProducto, String nuevosLotesSeleccionados) async {
    final db = await database;

    Map<String, dynamic> row = {
      columnLotesSeleccionados: nuevosLotesSeleccionados,
    };

    await db!.update(
      table,
      row,
      where: '$columnCodProducto = ?',
      whereArgs: [codProducto],
    );
  }
}
