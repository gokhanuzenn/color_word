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
  bool _isInitialized = false;

  /// Servisi başlat
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _isMuted = DatabaseService.instance.isMuted();
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(0.3);
      _isInitialized = true;
    } catch (e) {
      print('⚠️ Audio init hatası: $e');
      _isInitialized = true;
    }
  }

  /// Sessizlik durumunu getir
  bool get isMuted => _isMuted;

  /// Sessizliği aç/kapat
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    try {
      await DatabaseService.instance.setMuted(_isMuted);
    } catch (_) {}

    if (_isMuted) {
      try {
        await _bgPlayer.pause();
        await _sfxPlayer.stop();
      } catch (_) {}
    }
  }

  /// Sessizliği ayarla
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    try {
      await DatabaseService.instance.setMuted(muted);
    } catch (_) {}

    if (_isMuted) {
      try {
        await _bgPlayer.pause();
      } catch (_) {}
    }
  }

  /// Güvenli ses çalma
  Future<void> _safePlay(String asset, {double volume = 0.5}) async {
    if (_isMuted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(asset), volume: volume);
    } catch (e) {
      // Ses dosyası yoksa sessizce devam et
    }
  }

  /// Dokunma sesi çal
  Future<void> playTapSound() async {
    await _safePlay('audio/tap.wav', volume: 0.3);
  }

  /// Başlama sesi çal
  Future<void> playSuccessSound() async {
    await _safePlay('audio/success.wav', volume: 0.5);
  }

  /// Kelime keşfetme sesi çal
  Future<void> playWordDiscoverySound() async {
    await _safePlay('audio/discovery.wav', volume: 0.4);
  }

  /// Boyama sesi çal
  Future<void> playColoringSound() async {
    await _safePlay('audio/coloring.wav', volume: 0.2);
  }

  /// Harf sesi çal
  Future<void> playLetterSound(String letter) async {
    await _safePlay('audio/tap.wav', volume: 0.3);
  }

  /// Hata sesi çal
  Future<void> playErrorSound() async {
    await _safePlay('audio/error.wav', volume: 0.4);
  }

  /// Yıldız sesi çal
  Future<void> playStarSound() async {
    await _safePlay('audio/star.wav', volume: 0.5);
  }

  /// Arka plan müziğini başlat
  Future<void> startBackgroundMusic() async {
    if (_isMuted) return;
    try {
      await _bgPlayer.play(AssetSource('audio/background.wav'));
    } catch (_) {
      // Müzik dosyası yoksa sessiz devam et
    }
  }

  /// Arka plan müziğini durdur
  Future<void> stopBackgroundMusic() async {
    try {
      await _bgPlayer.stop();
    } catch (_) {}
  }

  /// Kaynakları temizle
  void dispose() {
    try {
      _bgPlayer.dispose();
      _sfxPlayer.dispose();
    } catch (_) {}
  }
}
