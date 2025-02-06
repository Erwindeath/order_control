// ignore_for_file: non_constant_identifier_names, camel_case_types
class ordenesPendientes {
  int Cod_Producto;
  String Producto;
  String Lab;
  int Cant_U;
  int Cant_F;
  double Costo;
  double Parcial;
  int Fraccion;
  int Cod_Compra;
  int Cant_Real;
  int ivaProducto;

  ordenesPendientes(
      {required this.Cod_Producto,
      required this.Producto,
      required this.Lab,
      required this.Cant_U,
      required this.Cant_F,
      required this.Costo,
      required this.Parcial,
      required this.Fraccion,
      required this.Cod_Compra,
      required this.Cant_Real,
      required this.ivaProducto});

  /*factory ordenesPendientes.fromJson(Map<String, dynamic> json) {
    return ordenesPendientes(
      Cod_Producto: json['Cod_Producto'],
      Cant_Real: json['Cant_Real'],
    );
  }
*/
  @override
  String toString() {
    return 'ordenesPendientes: {Cod_Producto: $Cod_Producto, Producto: $Producto, Lab: $Lab, Cant_U: $Cant_U, Cant_F: $Cant_F, Costo: $Costo, Parcial: $Parcial, Fraccion: $Fraccion, Cod_Compra: $Cod_Compra, Cant_Real: $Cant_Real,ivaProducto: $ivaProducto}';
  }

  Map<String, dynamic> toMap() {
    return {
      'Cod_Producto': Cod_Producto,
      'Producto': Producto,
      'Lab': Lab,
      'Cant_U': Cant_U,
      'Cant_F': Cant_F,
      'Costo': Costo,
      'Parcial': Parcial,
      'Fraccion': Fraccion,
      'Cod_Compra': Cod_Compra,
      'Cant_Real': Cant_Real,
      'ivaProducto': ivaProducto,
    };
  }
}
