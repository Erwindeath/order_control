// ignore_for_file: depend_on_referenced_packages

//traer el det

import 'package:order_control/views/menu_principal_views/cargos_pendientes/complements/clase.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "despachoMercaderia.db";
  // static const _databaseVersion = 3;

  static const table = 'despacho';
  static const columIva = 'Producto_Iva';
  static const columnCodProducto = 'Cod_Producto'; // No change to column names
  static const columnProducto = 'producto';
  static const columnSiglas = 'Siglas';
  static const columFraccionDv = 'fraccion';
  static const columnCantidadUnidad = 'Cant_Unidad_Inicial';
  static const columnCantidadFraccion = 'Cant_Fraccion';
  static const columnCosto = 'Costo';
  static const columnCantidadRealInicial = 'Cant_Real';
  static const columnParcial = 'Parcial';
  static const columnCodBarra = 'Cod_Barra';
  static const columnCantidadUnidadFinal = 'Cant_Unidad';
  static const columnCodBarraAdicional = 'codBarraAdicional';

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
          'CREATE TABLE $table($columnCodProducto INTEGER PRIMARY KEY,$columIva BOOLEAN, $columnProducto TEXT,$columnSiglas TEXT,$columFraccionDv INTEGER, $columnCantidadUnidad INTEGER, $columnCantidadFraccion INTEGER, $columnCosto REAL,$columnCantidadRealInicial REAL,$columnParcial REAL,$columnCodBarra TEXT,$columnCantidadUnidadFinal INTEGER,$columnCodBarraAdicional TEXT)',
        );
      },
      version: 5,
    );
  }

  Future<void> insert(DespachoMercaderia producto) async {
    final db = await database;

    await db!.insert(table, producto.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> deleteTable() async {
    final db = await database;
    await db?.delete(table);
  }

  Future<List<DespachoMercaderia>> getAllProductos() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db!.query(
      table,
      orderBy: '$columnSiglas ASC, $columnProducto ASC',
    );
    return List.generate(maps.length, (i) {
      return DespachoMercaderia.fromMap(maps[i]);
    });
  }

  Future<List<DespachoMercaderia>> getAllProductos2() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db!.query(
      table,
      orderBy: '$columnSiglas ASC, $columnProducto ASC',
    );
    return List.generate(maps.length, (i) {
      return DespachoMercaderia.fromMap(maps[i]);
    });
  }

  Future<void> updateProducto(int codProducto, int nuevaCantidad) async {
    final db = await database;
    await db!.update(
      table,
      {'Cant_Unidad': nuevaCantidad}, // Nombre de la columna y nuevo valor
      where: '$columnCodProducto = ?', // Condición para identificar el registro a actualizar
      whereArgs: [codProducto], // Valor para la condición
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await database;
    return db!.query('despacho');
  }
}
