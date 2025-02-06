class SubjectModel {
  String codigo;
  String nombre;
  String transferencia;
  SubjectModel({
    required this.codigo,
    required this.nombre,
    required this.transferencia
  });
  @override
  String toString() {
    return codigo;
  }
}
