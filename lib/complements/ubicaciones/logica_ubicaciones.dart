class Ubicaciones {
  int codUbicacion;
  String ubicacionR;

  Ubicaciones({required this.codUbicacion, required this.ubicacionR});

  factory Ubicaciones.fromJson(Map<String, dynamic> json) {
    return Ubicaciones(
      codUbicacion: json['Cod_Bode_Codigo'],
      ubicacionR: json['ubicacion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'codUbicacion': codUbicacion, 'ubicacionR': ubicacionR};
  }
}
