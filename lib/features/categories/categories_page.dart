import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/category_card.dart';
import 'category_gallery_page.dart';
import '../custom_image/custom_image_page.dart';
import '../coloring/coloring_page.dart';

/// Kategori modeli
class CategoryItem {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Kategori seçim sayfası
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  /// Tüm kategoriler (23 adet)
  static const List<CategoryItem> _allCategories = [
    // 1. 🐄 Çiftlik
    CategoryItem(
      id: 'ciftlik',
      name: 'Çiftlik',
      icon: '🐄',
      color: Color(0xFF8D6E63),
    ),
    // 2. 🐠 Deniz Altı
    CategoryItem(
      id: 'deniz_alti',
      name: 'Deniz Altı',
      icon: '🐠',
      color: Color(0xFF00BCD4),
    ),
    // 3. 🦕 Dinozor
    CategoryItem(
      id: 'dinozor',
      name: 'Dinozor',
      icon: '🦕',
      color: Color(0xFF4CAF50),
    ),
    // 4. 🌤️ Doğa Gökyüzü
    CategoryItem(
      id: 'doga_gokyuzu',
      name: 'Doğa Gökyüzü',
      icon: '🌤️',
      color: Color(0xFF29B6F6),
    ),
    // 6. 😊 Emoji
    CategoryItem(
      id: 'emoji',
      name: 'Emoji',
      icon: '😊',
      color: Color(0xFFFFC107),
    ),
    // 7. 👦 Erkek Karakter
    CategoryItem(
      id: 'erkek_karakter',
      name: 'Erkek Karakter',
      icon: '👦',
      color: Color(0xFF42A5F5),
    ),
    // 8. 🔤 Harfler
    CategoryItem(
      id: 'harfler',
      name: 'Harfler',
      icon: '🔤',
      color: Color(0xFF26C6DA),
    ),
    // 9. 🏗️ İnşaat
    CategoryItem(
      id: 'insaat',
      name: 'İnşaat',
      icon: '🏗️',
      color: Color(0xFFFFA726),
    ),
    // 10. 🦸 Kahramanlar
    CategoryItem(
      id: 'kahraman',
      name: 'Kahramanlar',
      icon: '🦸',
      color: Color(0xFFEF5350),
    ),
    // 11. 👧 Kız Karakter
    CategoryItem(
      id: 'kiz_karakter',
      name: 'Kız Karakter',
      icon: '👧',
      color: Color(0xFFEC407A),
    ),
    // 12. 👨‍⚕️ Meslekler
    CategoryItem(
      id: 'meslekler',
      name: 'Meslekler',
      icon: '👨‍⚕️',
      color: Color(0xFF78909C),
    ),
    // 13. 🍎 Meyveler
    CategoryItem(
      id: 'meyveler',
      name: 'Meyveler',
      icon: '🍎',
      color: Color(0xFFFF7043),
    ),
    // 14. 🌊 Okyanus
    CategoryItem(
      id: 'okyanus',
      name: 'Okyanus',
      icon: '🌊',
      color: Color(0xFF0288D1),
    ),
    // 15. 🧸 Oyuncaklar
    CategoryItem(
      id: 'oyuncak',
      name: 'Oyuncaklar',
      icon: '🧸',
      color: Color(0xFFFF8A65),
    ),
    // 16. 🤖 Robotlar
    CategoryItem(
      id: 'robot',
      name: 'Robotlar',
      icon: '🤖',
      color: Color(0xFF9E9E9E),
    ),
    // 17. 🔢 Sayılar
    CategoryItem(
      id: 'sayilar',
      name: 'Sayılar',
      icon: '🔢',
      color: Color(0xFFFF9800),
    ),
    // 18. 🐻 Sevimli Dostlar
    CategoryItem(
      id: 'sevimli_dostlar',
      name: 'Sevimli Dostlar',
      icon: '🐻',
      color: Color(0xFF8BC34A),
    ),
    // 19. ✨ Tamamlayıcı
    CategoryItem(
      id: 'tamamlayici',
      name: 'Tamamlayıcı',
      icon: '✨',
      color: Color(0xFF9C27B0),
    ),
    // 20. 🚗 Taşıtlar
    CategoryItem(
      id: 'tasitlar',
      name: 'Taşıtlar',
      icon: '🚗',
      color: Color(0xFF607D8B),
    ),
    // 21. 🚀 Uzay
    CategoryItem(
      id: 'uzay',
      name: 'Uzay',
      icon: '🚀',
      color: Color(0xFF3F51B5),
    ),
    // 22. 🦁 Vahşi Dostlar
    CategoryItem(
      id: 'vahsi_dostlar',
      name: 'Vahşi Dostlar',
      icon: '🦁',
      color: Color(0xFF795548),
    ),
    // 23. 🍽️ Yiyecekler
    CategoryItem(
      id: 'yiyecekler',
      name: 'Yiyecekler',
      icon: '🍽️',
      color: Color(0xFFF44336),
    ),
    // 24. 🖼️ Kendi Resmini Seç
    CategoryItem(
      id: 'custom',
      name: 'Kendi Resmini Seç',
      icon: '🖼️',
      color: Color(0xFF9C27B0),
    ),
    // 25. 📓 Boş Defter
    CategoryItem(
      id: 'blank',
      name: 'Boş Defter',
      icon: '📓',
      color: Color(0xFFFFF9C4),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '🎨 Kategori Seçin',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: _allCategories.length,
          itemBuilder: (context, index) {
            final category = _allCategories[index];

            return CategoryCard(
              title: category.name,
              icon: category.icon,
              color: category.color,
              progress: 0.0,
              onTap: () {
                // Özel resim ise custom image sayfasına git
                if (category.id == 'custom') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomImagePage(),
                    ),
                  );
                } else if (category.id == 'blank') {
                  // Boş defter - doğrudan boyama sayfasına git
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ColoringPage(
                        categoryName: 'Boş Defter',
                        categoryIcon: '📓',
                        categoryColor: category.color,
                        initialImageIndex: 0,
                        imagePaths: [],
                        isBlankCanvas: true,
                      ),
                    ),
                  );
                } else {
                  // Gallery sayfasına git
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryGalleryPage(
                        categoryName: category.name,
                        categoryIcon: category.icon,
                        categoryColor: category.color,
                      ),
                    ),
                  );
                }
              },
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 30 * index),
                  duration: 400.ms,
                )
                .scale(begin: const Offset(0.95, 0.95));
          },
        ),
      ),
    );
  }
}
