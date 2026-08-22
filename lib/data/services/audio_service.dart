import 'package:audioplayers/audioplayers.dart';
import 'database_service.dart';

/// Ses efektleri ve müzik yönetim servisi
class AppAudioService {
  static AppAudioService? _instance;
  static AppAudioService get instance => _instance ??= AppAudioService._();
  AppAudioService._();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isMuted = false;

  /// Servisi başlat
  Future<void> init() async {
    _isMuted = DatabaseService.instance.isMuted();

    // Arka plan müziği ayarları
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(0.3);
  }

  /// Sessizlik durumunu getir
  bool get isMuted => _isMuted;

  /// Sessizliği aç/kapat
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await DatabaseService.instance.setMuted(_isMuted);

    if (_isMuted) {
      await _bgPlayer.pause();
      await _sfxPlayer.stop();
    }
  }

  /// Sessizliği ayarla
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    await DatabaseService.instance.setMuted(muted);

    if (_isMuted) {
      await _bgPlayer.pause();
    }
  }

  /// Dokunma sesi çal
  Future<void> playTapSound() async {
    if (_isMuted) return;
    await _sfxPlayer.play(AssetSource('audio/tap.mp3'), volume: 0.5);
  }

  /// Başlama sesi çal
  Future<void> playSuccessSound() async {
    if (_isMuted) return;
    await _sfxPlayer.play(AssetSource('audio/success.mp3'), volume: 0.6);
  }

  /// Kelime keşfetme sesi çal
  Future<void> playWordDiscoverySound() async {
    if (_isMuted) return;
    await _sfxPlayer.play(AssetSource('audio/discovery.mp3'), volume: 0.7);
  }

  /// Boyama sesi çal
  Future<void> playColoringSound() async {
    if (_isMuted) return;
    await _sfxPlayer.play(AssetSource('audio/coloring.mp3'), volume: 0.4);
  }

  /// Harf sesi çal
  Future<void> playLetterSound(String letter) async {
    if (_isMuted) return;
    // Harf dosyası yoksa tapsound kullan
    try {
      await _sfxPlayer.play(AssetSource('audio/letters/$letter.mp3'));
    } catch (_) {
      await playTapSound();
    }
  }

  /// Hata sesi çal
  Future<void> playErrorSound() async {
    if (_isMuted) return;
    await _sfxPlayer.play(AssetSource('audio/error.mp3'), volume: 0.5);
  }

  /// Arka plan müziğini başlat
  Future<void> startBackgroundMusic() async {
    if (_isMuted) return;
    try {
      await _bgPlayer.play(AssetSource('audio/background.mp3'));
    } catch (_) {
      // Müzik dosyası yoksa sessiz devam et
    }
  }

  /// Arka plan müziğini durdur
  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
  }

  /// Kaynakları temizle
  void dispose() {
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
