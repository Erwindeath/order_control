import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:vibration/vibration.dart';

class SoundManager {
  Soundpool pool = Soundpool.fromOptions(options: const SoundpoolOptions(streamType: StreamType.notification));
  Map<String, int> loadedSounds = {};

  Future<void> loadSound(String path) async {
    int soundId = await rootBundle.load(path).then((ByteData soundData) {
      return pool.load(soundData);
    });
    loadedSounds[path] = soundId;
  }

  Future<void> playSoundWithVibration(String path, {int duration = 500}) async {
    int? soundId = loadedSounds[path];
    if (soundId != null) {
      pool.play(soundId);
    }
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  void dispose() {
    pool.release();
  }
}
