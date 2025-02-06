import 'package:order_control/views/ordenes_pendientes/logica_adicional.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHeleprOrdernes {
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
      join(path, 'ordenesPendientes.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE ordenes(Cod_Producto INTEGER PRIMARY KEY, Producto TEXT, Lab TEXT, Cant_U INTEGER,Cant_F INTEGER, Costo INTEGER, Parcial FLOAT, Fraccion INTEGER, Cod_Compra INTEGER, Cant_Real INTEGER, ivaProducto INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertProducto(ordenesPendientes ordenes) async {
    final db = await database;
    await db?.insert(
      'ordenes',
      ordenes.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await database;
    return db!.query('ordenes');
  }

  Future<int> getCountByCodProducto(int codProducto) async {
    final db = await database;
    final count = await db?.rawQuery(
      'SELECT COUNT(*) FROM ordenes WHERE Cod_Producto = ?',
      [codProducto],
    );
    return Sqflite.firstIntValue(count!) ?? 0;
  }

  Future<void> clearProductos() async {
    final db = await database;
    await db?.delete('ordenes');
  }


  Future<void> updateProductQuantityReal(
      int codProducto, int cantidadReal) async {
    final db = await database;
    await db?.update(
      'ordenes',
      {'Cant_Real': cantidadReal,'Cant_U': cantidadReal},
      where: 'Cod_Producto = ?',
      whereArgs: [codProducto],
    );
  }
}
