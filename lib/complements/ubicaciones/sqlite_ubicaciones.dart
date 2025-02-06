import 'package:order_control/complements/ubicaciones/logica_ubicaciones.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelperUbicacion {
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
      join(path, 'ubicaciones.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE ubicacion(codUbicacion INTEGER PRIMARY KEY, ubicacionR TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertUbicaciones(Ubicaciones ubicaciones) async {
    final db = await database;
    await db?.insert(
      'ubicacion',
      ubicaciones.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Ubicaciones>> getUbicaciones() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('ubicacion');
    return List.generate(
      maps.length,
      (i) {
        return Ubicaciones(
          codUbicacion: maps[i]['codUbicacion'],
          ubicacionR: maps[i]['ubicacionR'],
        );
      },
    );
  }

  Future<void> clearUbicaciones() async {
    final db = await database;
    await db?.delete('ubicacion');
  }

  Future<Map<String, Object?>?> getCodUbicaciones(String codBarra) async {
    final db = await database;
    final result = await db!.rawQuery(
        'SELECT codUbicacion, ubicacionR FROM ubicacion WHERE ubicacionR = ?',
        [codBarra]);
    if (result.isNotEmpty) {
      final codUbicacion = result.first['codUbicacion'];
      final ubicacionR = result.first['ubicacionR'];
      return {'codUbicacion': codUbicacion, 'ubicacionR': ubicacionR};
    } else {
      return null;
    }
  }
   Future<Map<String, Object?>?> getCodUbicacionesNuevoMetodo(String codBarra) async {
    final db = await database;
    final result = await db!.rawQuery(
        'SELECT codUbicacion, ubicacionR FROM ubicacion WHERE codUbicacion = ?',
        [codBarra]);
    if (result.isNotEmpty) {
      final codUbicacion = result.first['codUbicacion'];
      final ubicacionR = result.first['ubicacionR'];
      return {'codUbicacion': codUbicacion, 'ubicacionR': ubicacionR};
    } else {
      return null;
    }
  }
}
