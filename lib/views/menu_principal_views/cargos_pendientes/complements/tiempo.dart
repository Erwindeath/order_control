// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier que maneja el tiempo transcurrido
class TiempoTranscurridoNotifier extends StateNotifier<String> {
  Timer? _timer;
  DateTime _fechaInicio;

  TiempoTranscurridoNotifier(String fechaInicio)
      : _fechaInicio = DateTime.parse(fechaInicio),
        super(_formatDuration(DateTime.now().difference(DateTime.parse(fechaInicio)))) {
    _startTimer();
  }

  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return '$hours:$minutes';
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final now = DateTime.now();
      final difference = now.difference(_fechaInicio);
      state = _formatDuration(difference);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
