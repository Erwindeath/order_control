import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/menu_principal_views/nuevasUbicaciones/clase/clases.dart';

class DepartamentoNotifier extends StateNotifier<DepartamentoState> {
  DepartamentoNotifier() : super(DepartamentoState());

  void seleccionarDepartamento(int id, String nombre) {
    state = state.copyWith(id: id, nombre: nombre);
  }
  void limpiarDepartamentos(){
    state=DepartamentoState();
  }

}

class BloquesNotifier extends StateNotifier<BloquesState> {
  BloquesNotifier() : super(BloquesState());

  void seleccionarBloque(int id, String nombre) {
    state = state.copyWith(id: id, nombre: nombre);
  }

  void limpiarBloques() {
    // Esto restablece el estado a valores iniciales, id: 0 y nombre: ""
    state = BloquesState(); // Asumiendo que BloquesState() es tu estado inicial por defecto
  }
}

class NivelesNotifier extends StateNotifier<NivelesState> {
  NivelesNotifier() : super(NivelesState());

  void seleccionarAltura(int id, String nombre) {
    state = state.copyWith(id: id, nombre: nombre);
  }

  void limpiarAltura() {
    // Esto restablece el estado a valores iniciales, id: 0 y nombre: ""
    state = NivelesState(); // Asumiendo que BloquesState() es tu estado inicial por defecto
  }
}
class UbicacionesNotifier extends StateNotifier<UbicacionState> {
  UbicacionesNotifier() : super(UbicacionState());

  void seleccionarUbicacion(int id, String nombre) {
    state = state.copyWith(id: id, nombre: nombre);
  }

  void limpiarUbicacion() {
    // Esto restablece el estado a valores iniciales, id: 0 y nombre: ""
    state = UbicacionState(); // Asumiendo que BloquesState() es tu estado inicial por defecto
  }
}

class UbicacionNotifier extends StateNotifier<UbicacionStateNuevo> {
  UbicacionNotifier() : super(UbicacionStateNuevo());

  void setCodUbicacion(String cod) {
    state = state.copyWith(codUbicacion: cod);
  }

  void setNombreUbicacion(String nombre) {
    state = state.copyWith(nombreUbicacion: nombre);
  }

  void saveValuesToStorage(SecureStorage storage) async {
    await storage.writeSecureData('codUbicacion', state.codUbicacion);
    await storage.writeSecureData('nombreUbicacion', state.nombreUbicacion);
  }

  Future<void> loadValuesFromStorage(SecureStorage storage) async {
    String? cod = await storage.readSecureData('codUbicacion');
    String? nombre = await storage.readSecureData('nombreUbicacion');
    state = state.copyWith(codUbicacion: cod ?? '', nombreUbicacion: nombre ?? '');
  }
}
