class Busqueda {
  final int codProducto;
  final String name;
  final String codBarra;

  Busqueda({
    required this.codProducto,
    required this.name,
    required this.codBarra
  });
  Map<String, dynamic> toMap() {
    return {
      'codProducto': codProducto,
      'name': name,
      'codBarra':codBarra
    };
  }
}
