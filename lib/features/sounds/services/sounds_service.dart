import 'package:audioplayers/audioplayers.dart';

class SoundsService {
  final Map<String, AudioPlayer> _players = {};
  bool _globalContextConfigured = false;

  Future<void> _ensureGlobalAudioContext() async {
    if (_globalContextConfigured) return;

    await AudioPlayer.global.setAudioContext(
      AudioContextConfig(
        focus: AudioContextConfigFocus.mixWithOthers,
        stayAwake: true,
      ).build(),
    );

    _globalContextConfigured = true;
  }

  AudioPlayer _getOrCreatePlayer(String id) {
    final existing = _players[id];
    if (existing != null) return existing;

    final player = AudioPlayer(playerId: 'sound_$id');
    _players[id] = player;
    return player;
  }

  Future<void> play({
    required String id,
    required String assetPath,
    required double volume,
  }) async {
    await _ensureGlobalAudioContext();

    final player = _getOrCreatePlayer(id);

    await player.setAudioContext(
      AudioContextConfig(
        focus: AudioContextConfigFocus.mixWithOthers,
        stayAwake: true,
      ).build(),
    );

    await player.setPlayerMode(PlayerMode.mediaPlayer);
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(volume);
    await player.play(AssetSource(assetPath));
  }

  Future<void> pause(String id) async {
    final player = _players[id];
    if (player != null) {
      await player.pause();
    }
  }

  Future<void> stop(String id) async {
    final player = _players[id];
    if (player != null) {
      await player.stop();
    }
  }

  Future<void> setVolume(String id, double volume) async {
    final player = _players[id];
    if (player != null) {
      await player.setVolume(volume);
    }
  }

  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}