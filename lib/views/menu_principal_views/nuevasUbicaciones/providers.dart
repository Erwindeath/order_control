import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_control/views/menu_principal_views/nuevasUbicaciones/clase/notifier.dart';
import 'package:order_control/views/menu_principal_views/nuevasUbicaciones/clase/clases.dart';

final validaProvider = StateProvider<bool>((ref) {
  return false; // Valor inicial
});
final departamentoProvider = StateNotifierProvider<DepartamentoNotifier, DepartamentoState>((ref) {
  return DepartamentoNotifier();
});
final bloquesProvider = StateNotifierProvider<BloquesNotifier, BloquesState>((ref) {
  return BloquesNotifier();
});
final alturaProvider = StateNotifierProvider<NivelesNotifier, NivelesState>((ref) {
  return NivelesNotifier();
});

final ubicacionProvider = StateNotifierProvider<UbicacionesNotifier, UbicacionState>((ref) {
  return UbicacionesNotifier();
});

final ubicacionProviderNuevo = StateNotifierProvider<UbicacionNotifier, UbicacionStateNuevo>((ref) {
  return UbicacionNotifier();
});
final validaProviderReimprimir = StateProvider<bool>((ref) {
  return false; // Valor inicial
});