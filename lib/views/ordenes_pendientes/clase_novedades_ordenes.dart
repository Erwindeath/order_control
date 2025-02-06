class Novedades {
  final int codProducto;
  final String producto;
  final String lab;
  final int cantidadFaltante;
  final int cantidadEscaneada;
  final int cantidadFinal;
  Novedades({
  
    required this.codProducto,
    required this.producto,
    required this.lab,
    required this.cantidadFaltante,
    required this.cantidadEscaneada,
    required this.cantidadFinal
    
  });

  @override
  String toString() {
    return 'Ordenes{'
        'codProducto: $codProducto, '
        'cantidadFaltante: $cantidadFaltante, '
        'CantidadFinal: $cantidadFinal, '
        'producto: $producto, '
        'Lab: $lab, '
        'cantidadEscaneada: $cantidadEscaneada, '
        '}';
  }
}
