import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/neubrutal_button.dart';

/// Gizli Admin Sayfası
/// Ana sayfada logoya 7 kez tıklayarak girilir
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String _status = '';
  bool _isLoading = false;
  List<String> _addedFiles = [];

  // Tüm kategoriler
  static const Map<String, String> _categories = {
    'animals': '🐻 Hayvanlar',
    'girl_character': '👧 Kız Karakter',
    'vehicles': '🚗 Taşıtlar',
    'numbers': '🔢 Sayılar',
    'food': '🍎 Yiyecekler',
    'nature': '🌳 Doğa',
    'space': '🚀 Uzay Maceraları',
    'dinosaur': '🦕 Dinozor Dünyası',
    'magic': '✨ Sihirli Dünya',
    'underwater': '🐠 Deniz Altı',
    'fairy_tale': '🏰 Masal Dünyası',
    'robots': '🤖 Robotlar',
    'flowers': '🌸 Çiçekler',
    'emojis': '😊 Emojiler',
    'heroes': '🦸 Kahramanlar',
    'farm': '🐄 Çiftlik',
    'professions': '👨‍⚕️ Meslekler',
    'letters': '🔤 Harfler Dünyası',
    'toys': '🧸 Oyuncak Dünyası',
    'work_vehicles': '🚜 İş Arabaları',
  };

  String _selectedCategory = 'animals';

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isLoading = true;
          _status = '${result.files.length} resim seçildi, kopyalanıyor...';
        });

        // Uygulama dizinini al
        final appDir = await getApplicationDocumentsDirectory();
        final categoryDir = Directory(
          '${appDir.path}/assets/images/$_selectedCategory',
        );

        // Klasör yoksa oluştur
        if (!await categoryDir.exists()) {
          await categoryDir.create(recursive: true);
        }

        int successCount = 0;
        for (final file in result.files) {
          if (file.path != null) {
            final fileName = '${file.name}';
            final newPath = '${categoryDir.path}/$fileName';

            // Dosyayı kopyala
            await File(file.path!).copy(newPath);
            _addedFiles.add(newPath);
            successCount++;
          }
        }

        setState(() {
          _isLoading = false;
          _status = '✅ $successCount resim başarıyla kopyalandı!\n'
              'Konum: ${categoryDir.path}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Hata: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '🔑 Admin Paneli',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.buttonDanger,
        foregroundColor: Colors.white,
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
            // Uyarı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.buttonDanger.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.buttonDanger,
                  width: 3,
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    '⚠️ GELİŞTİRİCİ ALANI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.buttonDanger,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bu alan sadece uygulama geliştiricisi içindir.\n'
                    'Bu sayfada yüklediğiniz resimler uygulamanın\n'
                    'assets klasörüne kopyalanır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            // Kategori seçimi
            const Text(
              '📂 Kategori Seçin:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Kategori grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.3,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final entry = _categories.entries.elementAt(index);
                final isSelected = _selectedCategory == entry.key;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = entry.key),
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.buttonPrimary
                          : Colors.white,
                      border: Border.all(
                        color: AppColors.border,
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
                    child: Center(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Yükle butonu
            NeubrutalButton(
              label: _isLoading
                  ? '⏳ Yükleniyor...'
                  : '📁 $_selectedCategory Kategorisine Resim Ekle',
              backgroundColor: AppColors.buttonAccent,
              width: double.infinity,
              height: 56,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _pickImages,
            ),

            const SizedBox(height: 16),

            // Durum mesajı
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.border,
                    width: 2,
                  ),
                ),
                child: Text(
                  _status,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Eklenen dosyalar
            if (_addedFiles.isNotEmpty) ...[
              Text(
                '📋 Eklenen Dosyalar (${_addedFiles.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _addedFiles.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.border.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Text(
                        _addedFiles[index].split('/').last,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
