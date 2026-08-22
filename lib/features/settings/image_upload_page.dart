import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/neubrutal_button.dart';
import '../../data/services/custom_image_service.dart';

/// Kategori listesi
class CategoryInfo {
  final String id;
  final String name;
  final String icon;

  const CategoryInfo({
    required this.id,
    required this.name,
    required this.icon,
  });
}

/// Kolay resim yükleme sayfası
class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  // Tüm kategoriler
  static const List<CategoryInfo> _categories = [
    CategoryInfo(id: 'animals', name: 'Hayvanlar', icon: '🐻'),
    CategoryInfo(id: 'girl_character', name: 'Kız Karakter', icon: '👧'),
    CategoryInfo(id: 'vehicles', name: 'Taşıtlar', icon: '🚗'),
    CategoryInfo(id: 'numbers', name: 'Sayılar', icon: '🔢'),
    CategoryInfo(id: 'food', name: 'Yiyecekler', icon: '🍎'),
    CategoryInfo(id: 'nature', name: 'Doğa', icon: '🌳'),
    CategoryInfo(id: 'space', name: 'Uzay Maceraları', icon: '🚀'),
    CategoryInfo(id: 'dinosaur', name: 'Dinozor Dünyası', icon: '🦕'),
    CategoryInfo(id: 'magic', name: 'Sihirli Dünya', icon: '✨'),
    CategoryInfo(id: 'underwater', name: 'Deniz Altı', icon: '🐠'),
    CategoryInfo(id: 'fairy_tale', name: 'Masal Dünyası', icon: '🏰'),
    CategoryInfo(id: 'robots', name: 'Robotlar', icon: '🤖'),
    CategoryInfo(id: 'flowers', name: 'Çiçekler', icon: '🌸'),
    CategoryInfo(id: 'emojis', name: 'Emojiler', icon: '😊'),
    CategoryInfo(id: 'heroes', name: 'Kahramanlar', icon: '🦸'),
    CategoryInfo(id: 'farm', name: 'Çiftlik', icon: '🐄'),
    CategoryInfo(id: 'professions', name: 'Meslekler', icon: '👨‍⚕️'),
    CategoryInfo(id: 'letters', name: 'Harfler Dünyası', icon: '🔤'),
    CategoryInfo(id: 'toys', name: 'Oyuncak Dünyası', icon: '🧸'),
    CategoryInfo(id: 'work_vehicles', name: 'İş Arabaları', icon: '🚜'),
  ];

  String? _selectedCategoryId;
  bool _isUploading = false;
  List<Map<String, String>> _uploadedImages = [];

  @override
  void initState() {
    super.initState();
    _loadUploadedImages();
  }

  Future<void> _loadUploadedImages() async {
    final images = CustomImageService.instance.getAllCustomImages();
    setState(() => _uploadedImages = images);
  }

  Future<void> _pickImages() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ Önce bir kategori seçin!'),
          backgroundColor: AppColors.buttonPrimary,
        ),
      );
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isUploading = true);

        int successCount = 0;
        for (final file in result.files) {
          if (file.path != null) {
            await CustomImageService.instance.addColoringImage(
              sourcePath: file.path!,
              category: _selectedCategoryId!,
              name: file.name.split('.').first,
            );
            successCount++;
          }
        }

        await _loadUploadedImages();
        setState(() => _isUploading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $successCount resim başarıyla yüklendi!'),
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
            content: Text('❌ Hata: $e'),
            backgroundColor: AppColors.buttonDanger,
          ),
        );
      }
    }
  }

  Future<void> _deleteImage(String id) async {
    await CustomImageService.instance.deleteImage(id);
    await _loadUploadedImages();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Resim silindi'),
          backgroundColor: AppColors.buttonDanger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '🖼️ Resim Yükle',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
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
            // Başlık
            const Text(
              '📂 Kategori Seçin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 8),

            Text(
              'Resimleri yüklemek istediğiniz kategoriyi seçin',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // Kategori listesi (2 sütunlu grid)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategoryId == cat.id;

                // Bu kategoride kaç resim var?
                final imageCount = _uploadedImages
                    .where((img) => img['category'] == cat.id)
                    .length;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategoryId = cat.id);
                  },
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.buttonPrimary
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.border
                            : AppColors.border.withOpacity(0.5),
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              const BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(2, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cat.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (imageCount > 0) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.buttonSecondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$imageCount',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Yükleme butonu
            NeubrutalButton(
              label: _isUploading
                  ? '⏳ Yükleniyor...'
                  : '📁 Resim Seç ve Yükle',
              backgroundColor: _selectedCategoryId != null
                  ? AppColors.buttonAccent
                  : AppColors.textSecondary.withOpacity(0.3),
              width: double.infinity,
              height: 56,
              isLoading: _isUploading,
              onPressed: _selectedCategoryId != null && !_isUploading
                  ? _pickImages
                  : null,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 20),

            // Yüklenen resimler
            if (_uploadedImages.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🖼️ Yüklenen Resimler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.buttonSecondary,
                      border: Border.all(
                        color: AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'Toplam: ${_uploadedImages.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Resim grid'i
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _uploadedImages.length,
                itemBuilder: (context, index) {
                  final image = _uploadedImages[index];
                  final catName = _categories
                      .where((c) => c.id == image['category'])
                      .map((c) => '${c.icon} ${c.name}')
                      .firstOrNull ?? '';

                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.file(
                                File(image['sourcePath'] ?? ''),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stack) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 30,
                                      color: AppColors.textSecondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(2),
                              color: AppColors.border,
                              child: Text(
                                catName,
                                style: const TextStyle(
                                  fontSize: 7,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _deleteImage(image['id']!),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.buttonDanger,
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ] else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Henüz resim yüklenmedi',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Yukarıdan kategori seçin ve resim yükleyin',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
