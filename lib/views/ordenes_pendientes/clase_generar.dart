class Ordenes {
  final int clasificacion;
  final int codProducto;
  final int cantidadUnidad;
  late int cantidad;
  final int codCodigo;
  final int fraccion;
  final String descripcion;
  final String codCargo;
  final String codRecorrido;
  final String codigoRecorrido;
  final String laboratorio;
  final String siglas;
  final double costo;
  final double baseCero;
  final double baseIva;
  final double iva;
  final double total;
  final int codBodega;
  final int codBodegaTran;
  final int cantReal;
  final int rack;
  final int seccion;
  final int altura;
  final int ubicacion;
  final String codBarra;
  final String cedula;
  final String razonSocial;
  final String placa;
  final String observacion;
  final int cargarDestino;
  final int ivaProducto;
  final String observacionOrden;
  var codBarraAdicional=[];
  Ordenes({
    required this.clasificacion,
    required this.baseCero,
    required this.baseIva,
    required this.iva,
    required this.total,
    required this.codBodega,
    required this.codBodegaTran,
    required this.codProducto,
    required this.cantidadUnidad,
    required this.cantidad,
    required this.fraccion,
    required this.descripcion,
    required this.codCargo,
    required this.codRecorrido,
    required this.codigoRecorrido,
    required this.laboratorio,
    required this.rack,
    required this.seccion,
    required this.altura,
    required this.ubicacion,
    required this.codBarra,
    required this.siglas,
    required this.costo,
    required this.cantReal,
    required this.codCodigo,
    required this.cedula,
    required this.razonSocial,
    required this.placa,
    required this.observacion,
    required this.observacionOrden,
    required this.cargarDestino,
    required this.ivaProducto,
    required this.codBarraAdicional
    
  });

  @override
  String toString() {
    return 'Ordenes{'
        'Recorrido: $codRecorrido, '
        '}';
  }
  
}
