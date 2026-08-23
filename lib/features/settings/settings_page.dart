import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/neubrutal_button.dart';
import '../../core/widgets/neubrutal_card.dart';
import '../../core/utils/haptic_helper.dart';
import '../../data/providers/app_provider.dart';
import '../../data/services/custom_image_service.dart';
import 'premium_page.dart';

/// Ayarlar sayfası
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isMuted = false;
  bool _isHapticEnabled = true;
  List<Map<String, String>> _customImages = [];
  String _selectedCategory = 'space';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCustomImages();
  }

  Future<void> _loadSettings() async {
    final audioService = ref.read(audioServiceProvider);
    await HapticHelper.init();
    setState(() {
      _isMuted = audioService.isMuted;
      _isHapticEnabled = HapticHelper.isEnabled;
    });
  }

  Future<void> _loadCustomImages() async {
    final images = CustomImageService.instance.getAllCustomImages();
    setState(() {
      _customImages = images;
    });
  }

  Future<void> _toggleMute() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.toggleMute();
    setState(() {
      _isMuted = audioService.isMuted;
    });
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isUploading = true);

        for (final file in result.files) {
          if (file.path != null) {
            await CustomImageService.instance.addColoringImage(
              sourcePath: file.path!,
              category: _selectedCategory,
              name: file.name.split('.').first,
            );
          }
        }

        await _loadCustomImages();
        setState(() => _isUploading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.files.length} resim yüklendi!'),
              backgroundColor: AppColors.buttonSecondary,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.buttonDanger,
          ),
        );
      }
    }
  }

  Future<void> _deleteImage(String id) async {
    await CustomImageService.instance.deleteImage(id);
    await _loadCustomImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('⚙️ Ayarlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ses Ayarları
            NeubrutalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔊 Ses Ayarları',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sessiz Mod',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleMute,
                        child: Container(
                          width: 60,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _isMuted
                                ? AppColors.buttonDanger
                                : AppColors.buttonSecondary,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: AnimatedAlign(
                            duration: AppConstants.animFast,
                            alignment: _isMuted
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _isMuted ? '🔇' : '🔊',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 16),

            // Haptic Feedback Ayarları
            NeubrutalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📳 Dokunma Hissi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dokunma titreşimlerini açıp kapatabilirsiniz',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Haptic Feedback',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _isHapticEnabled ? 'Açık' : 'Kapalı',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isHapticEnabled ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await HapticHelper.toggle();
                          setState(() {
                            _isHapticEnabled = HapticHelper.isEnabled;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 60,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _isHapticEnabled
                                ? Colors.green
                                : AppColors.buttonDanger,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            alignment: _isHapticEnabled
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _isHapticEnabled ? '📳' : '📴',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // Resim Yükleme Bölümü
            NeubrutalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🖼️ Resim Yükleme',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kendi boyama resimlerinizi ekleyin',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kategori seçimi
                  const Text(
                    'Kategori Seçin:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CategoryChip(
                        label: '🚀 Uzay',
                        isSelected: _selectedCategory == 'space',
                        onTap: () =>
                            setState(() => _selectedCategory = 'space'),
                      ),
                      _CategoryChip(
                        label: '🐻 Hayvanlar',
                        isSelected: _selectedCategory == 'animals',
                        onTap: () =>
                            setState(() => _selectedCategory = 'animals'),
                      ),
                      _CategoryChip(
                        label: '🍎 Yiyecekler',
                        isSelected: _selectedCategory == 'food',
                        onTap: () =>
                            setState(() => _selectedCategory = 'food'),
                      ),
                      _CategoryChip(
                        label: '🌳 Doğa',
                        isSelected: _selectedCategory == 'nature',
                        onTap: () =>
                            setState(() => _selectedCategory = 'nature'),
                      ),
                      _CategoryChip(
                        label: '🚗 Taşıtlar',
                        isSelected: _selectedCategory == 'vehicles',
                        onTap: () =>
                            setState(() => _selectedCategory = 'vehicles'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Yükle butonu
                  NeubrutalButton(
                    label: _isUploading ? '⏳ Yükleniyor...' : '📁 Resim Seç',
                    backgroundColor: AppColors.buttonAccent,
                    width: double.infinity,
                    height: 56,
                    isLoading: _isUploading,
                    onPressed: _isUploading ? null : _pickImages,
                  ),

                  const SizedBox(height: 16),

                  // Yüklenen resimler
                  if (_customImages.isNotEmpty) ...[
                    const Text(
                      'Yüklenen Resimler:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _customImages.length,
                        itemBuilder: (context, index) {
                          final image = _customImages[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: Image.file(
                                    File(image['sourcePath'] ?? ''),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 40,
                                          color: AppColors.textSecondary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _deleteImage(image['id']!),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.buttonDanger,
                                        border: Border.all(
                                          color: AppColors.border,
                                          width: 1,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ] else
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Henüz resim yüklenmedi',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // Premium
            NeubrutalButton(
              label: '⭐ Premium - Reklamları Kaldır',
              backgroundColor: Colors.orange,
              width: double.infinity,
              height: 60,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumPage(),
                  ),
                );
              },
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // Hakkında
            NeubrutalCard(
              child: Column(
                children: [
                  const Text(
                    '🎨 ColorWord v1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Renklerle kelime öğrenme uygulaması',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.buttonPrimary
              : AppColors.background,
          border: Border.all(
            color: AppColors.border,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
