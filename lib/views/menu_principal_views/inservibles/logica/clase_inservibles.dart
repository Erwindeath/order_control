class PorAprobacion {
  final String productoIva;
  final double precioPublico;
  final double costoVenta;
  final int codCargo;
  final String fecha;
  final int codBodega;
  final String descripcion;
  final int codProducto;
  final String usuario;
  final int codUsuario;
  final int codBodegaTran;
  final String nombreBodega;
  final String lote;
  final int codLote;
  final String fechaV;
  final int cantUnidad;
  final int cantFraccion;
  final int cantidadReal;
  final int fraccion;
  final double costo;
  final double parcial;
  final String observacion;
  final double base0;
  final double baseIva;
  final double iva;
  final double total;

  PorAprobacion({
    required this.productoIva,
    required this.precioPublico,
    required this.costoVenta,
    required this.codCargo,
    required this.fecha,
    required this.codBodega,
    required this.descripcion,
    required this.codProducto,
    required this.codBodegaTran,
    required this.nombreBodega,
    required this.lote,
    required this.codLote,
    required this.fechaV,
    required this.usuario,
    required this.codUsuario,
    required this.cantUnidad,
    required this.cantFraccion,
    required this.cantidadReal,
    required this.fraccion,
    required this.costo,
    required this.parcial,
    required this.observacion,
    required this.base0,
    required this.baseIva,
    required this.iva,
    required this.total,
  });

  @override
  String toString() {
    return 'PorAprobacion('
        'productoIva: $productoIva, '
        'precioPublico: $precioPublico, '
        'costoVenta: $costoVenta, '
        'codCargo: $codCargo, '
        'fecha: $fecha, '
        'codBodega: $codBodega, '
        'descripcion: $descripcion, '
        'codProducto: $codProducto, '
        'usuario: $usuario, '
        'codUsuario: $codUsuario, '
        'codBodegaTran: $codBodegaTran, '
        'nombreBodega: $nombreBodega, '
        'lote: $lote, '
        'codLote: $codLote, '
        'fechaV: $fechaV, '
        'cantUnidad: $cantUnidad, '
        'cantFraccion: $cantFraccion, '
        'cantidadReal: $cantidadReal, '
        'fraccion: $fraccion, '
        'costo: $costo, '
        'parcial: $parcial, '
        'observacion: $observacion, '
        'base0: $base0, '
        'baseIva: $baseIva, '
        'iva: $iva, '
        'total: $total'
        ')';
  }
}