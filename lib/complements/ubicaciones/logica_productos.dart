class Producto {
  int codProducto;
  String codBarra;
  String descripcion;

  Producto({required this.codProducto, required this.codBarra, required this.descripcion});

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      codProducto: json['Cod_Producto'],
      codBarra: json['Cod_Barra'],
      descripcion: json['Descripcion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codProducto': codProducto,
      'codBarra': codBarra,
      'descripcion': descripcion,
    };
  }
}