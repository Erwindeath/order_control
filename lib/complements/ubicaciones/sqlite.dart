import 'package:order_control/complements/ubicaciones/logica_productos.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'productos.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE productos(codProducto INTEGER PRIMARY KEY, codBarra TEXT, descripcion TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertProducto(Producto producto) async {
    final db = await database;
    await db?.insert(
      'productos',
      producto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Producto>> getProductos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('productos');

    return List.generate(
      maps.length,
      (i) {
        return Producto(
          codProducto: maps[i]['codProducto'],
          codBarra: maps[i]['codBarra'],
          descripcion: maps[i]['descripcion'],
        );
      },
    );
  }

  Future<void> clearProductos() async {
    final db = await database;
    await db?.delete('productos');
  }

  Future<Map<String, Object?>?> getCodProducto(String codBarra) async {
    final db = await database;
    final result = await db!.rawQuery(
        'SELECT codProducto, descripcion FROM productos WHERE codBarra = ?',
        [codBarra]);
    if (result.isNotEmpty) {
      final codProducto = result.first['codProducto'];
      final descripcion = result.first['descripcion'];
      return {'codProducto': codProducto, 'descripcion': descripcion};
    } else {
      return null;
    }
  }
}
