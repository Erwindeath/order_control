import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_control/views/menu_principal_views/cargos_pendientes/complements/clase.dart';
import 'package:order_control/views/menu_principal_views/cargos_pendientes/complements/sqlite.dart';
import 'package:order_control/views/menu_principal_views/cargos_pendientes/complements/tiempo.dart';

class DespachoMercaderiaNotifier extends StateNotifier<List<DespachoMercaderia>> {
  DespachoMercaderiaNotifier() : super([]);

  void setData(List<DespachoMercaderia> data) {
    state = data;
  }

  /* void updateUnidad(int index, int unidad, WidgetRef ref) {
    var newState = [...state]; // Clona el estado actual para evitar mutaciones directas
    if (index < newState.length) {
      newState[index].cantUnidadFinal = unidad;
    }
    state = newState; // Actualiza el estado con el nuevo arreglo modificado
  }*/
  void updateUnidad(int index, int unidad, WidgetRef ref) {
    if (index < state.length) {
      state[index].updateCantidad(unidad); // Esto también actualiza el controller
      state = [...state]; // Esto es necesario para que Riverpod detecte el cambio
      ref.read(databaseHelperProvider).updateProducto(state[index].codProducto, unidad);
    }
  }
}

final despachoMercaderiaProvider = StateNotifierProvider<DespachoMercaderiaNotifier, List<DespachoMercaderia>>((ref) {
  return DespachoMercaderiaNotifier();
});

final enviando = StateProvider<bool>((ref) => false);
final enviar = StateProvider<bool>((ref) => false);
final habilitado = StateProvider<bool>((ref) => true);
final validaProvider = StateProvider<bool>((ref) {
  return false; // Valor inicial
});
final validaProviderSegundo = StateProvider<bool>((ref) {
  return false; // Valor inicial
});
final tiempoTranscurridoProvider = StateNotifierProvider.family<TiempoTranscurridoNotifier, String, String>((ref, fechaInicio) {
  return TiempoTranscurridoNotifier(fechaInicio);
});

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});
