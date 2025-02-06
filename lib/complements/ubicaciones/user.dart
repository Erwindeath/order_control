class User {
  final String ubicacion;
   String producto;
   String codProducto;
   String descripcion;
   String escaneo;
   String codUbicacion;
 // final int age;

   User({
    required this.ubicacion,
    required this.producto,
    required this.codProducto,
    required this.descripcion,
    required this.escaneo,
    required this.codUbicacion
    //required this.age,
  });
  
  User copy({
    String? ubicacion,
    String? producto,
    String? codProducto,
    String? descripcion,
     String? escaneo,
     String? codUbicacion
   // int? age,
  }) =>
      User(
        ubicacion: ubicacion ?? this.ubicacion,
        producto: producto ?? this.producto,
        codProducto: codProducto ?? this.codProducto,
        descripcion: descripcion ?? this.descripcion,
        escaneo: escaneo ?? this.escaneo,
        codUbicacion: codUbicacion ?? this.codUbicacion,
       // age: age ?? this.age,
      );
       @override
  String toString() {
    return 'User{ubicacion: $ubicacion, producto: $producto,codProducto: $codProducto, descripcion: $descripcion,escaneo: $escaneo},codUbicacion: $codUbicacion';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          ubicacion == other.ubicacion &&
          producto == other.producto;//&&
         // age == other.age;

  @override
  int get hashCode => ubicacion.hashCode ^ producto.hashCode;
  Map<String, dynamic> toJson() => {
        'ubicacion': ubicacion,
        'producto': producto,
        'codProducto': codProducto,
        'descripcion': descripcion,
        'escaneo': escaneo,
        'codUbicacion':codUbicacion
      };
}
