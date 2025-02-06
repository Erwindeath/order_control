class SubBodega {
  final int codSubBodega;
  final String nombre;

  SubBodega({required this.codSubBodega, required this.nombre});
}

class Bloques {
  final int codBloque;
  final String nombre;

  Bloques({required this.codBloque, required this.nombre});
}
class Niveles {
  final int codNivel;
  final String nombre;

  Niveles({required this.codNivel, required this.nombre});
}
class Ubicaciones {
  final int codUbicacion;
  final String nombre;

  Ubicaciones({required this.codUbicacion, required this.nombre});
}



class DepartamentoState {
  final int id;
  final String nombre;

  DepartamentoState({this.id = 0, this.nombre = ''});

  DepartamentoState copyWith({int? id, String? nombre}) {
    return DepartamentoState(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
    );
  }
}

class BloquesState {
  final int id;
  final String nombre;

  BloquesState({this.id = 0, this.nombre = ''});

  BloquesState copyWith({int? id, String? nombre}) {
    return BloquesState(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
    );
  }
}

class NivelesState {
  final int id;
  final String nombre;

  NivelesState({this.id = 0, this.nombre = ''});

  NivelesState copyWith({int? id, String? nombre}) {
    return NivelesState(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
    );
  }
}
class UbicacionState {
  final int id;
  final String nombre;

  UbicacionState({this.id = 0, this.nombre = ''});

  UbicacionState copyWith({int? id, String? nombre}) {
    return UbicacionState(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
    );
  }
}
class UbicacionStateNuevo {
  final String codUbicacion;
  final String nombreUbicacion;

  UbicacionStateNuevo({this.codUbicacion = '', this.nombreUbicacion = ''});
  
  UbicacionStateNuevo copyWith({
    String? codUbicacion,
    String? nombreUbicacion,
  }) {
    return UbicacionStateNuevo(
      codUbicacion: codUbicacion ?? this.codUbicacion,
      nombreUbicacion: nombreUbicacion ?? this.nombreUbicacion,
    );
  }
}