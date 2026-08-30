import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'category_gallery_page.dart';
import '../custom_image/custom_image_page.dart';
import '../coloring/coloring_page.dart';
import '../../core/utils/responsive_helper.dart';

/// Kategori modeli
class CategoryItem {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final int imageCount;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.imageCount = 0,
  });
}

/// Modern kategori seçim sayfası
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  /// Tüm kategoriler (güncel resim sayılarıyla)
  static const List<CategoryItem> _allCategories = [
    CategoryItem(id: 'ciftlik', name: 'Çiftlik', icon: '🐄', color: Color(0xFF8D6E63), imageCount: 83),
    CategoryItem(id: 'deniz_alti', name: 'Deniz Altı', icon: '🐠', color: Color(0xFF00BCD4), imageCount: 92),
    CategoryItem(id: 'dinozor', name: 'Dinozor', icon: '🦕', color: Color(0xFF4CAF50), imageCount: 100),
    CategoryItem(id: 'doga_gokyuzu', name: 'Doğa Gökyüzü', icon: '🌤️', color: Color(0xFF29B6F6), imageCount: 42),
    CategoryItem(id: 'emoji', name: 'Emoji', icon: '😊', color: Color(0xFFFFC107), imageCount: 90),
    CategoryItem(id: 'erkek_karakter', name: 'Erkek Karakter', icon: '👦', color: Color(0xFF42A5F5), imageCount: 50),
    CategoryItem(id: 'harfler', name: 'Harfler', icon: '🔤', color: Color(0xFF26C6DA), imageCount: 30),
    CategoryItem(id: 'insaat', name: 'İnşaat', icon: '🏗️', color: Color(0xFFFFA726), imageCount: 80),
    CategoryItem(id: 'kahraman', name: 'Kahramanlar', icon: '🦸', color: Color(0xFFEF5350), imageCount: 37),
    CategoryItem(id: 'kiz_karakter', name: 'Kız Karakter', icon: '👧', color: Color(0xFFEC407A), imageCount: 50),
    CategoryItem(id: 'meslekler', name: 'Meslekler', icon: '👨‍⚕️', color: Color(0xFF78909C), imageCount: 47),
    CategoryItem(id: 'meyveler', name: 'Meyveler', icon: '🍎', color: Color(0xFFFF7043), imageCount: 25),
    CategoryItem(id: 'oyuncak', name: 'Oyuncaklar', icon: '🧸', color: Color(0xFFFF8A65), imageCount: 50),
    CategoryItem(id: 'robot', name: 'Robotlar', icon: '🤖', color: Color(0xFF9E9E9E), imageCount: 66),
    CategoryItem(id: 'sayilar', name: 'Sayılar', icon: '🔢', color: Color(0xFFFF9800), imageCount: 22),
    CategoryItem(id: 'sevimli_dostlar', name: 'Sevimli Dostlar', icon: '🐻', color: Color(0xFF8BC34A), imageCount: 15),
    CategoryItem(id: 'tamamlayici', name: 'Tamamlayıcı', icon: '✨', color: Color(0xFF9C27B0), imageCount: 35),
    CategoryItem(id: 'tasitlar', name: 'Taşıtlar', icon: '🚗', color: Color(0xFF607D8B), imageCount: 55),
    CategoryItem(id: 'uzay', name: 'Uzay', icon: '🚀', color: Color(0xFF3F51B5), imageCount: 35),
    CategoryItem(id: 'vahsi_dostlar', name: 'Vahşi Dostlar', icon: '🦁', color: Color(0xFF795548), imageCount: 43),
    CategoryItem(id: 'mandalalar', name: 'Mandalalar', icon: '🔮', color: Color(0xFF7B1FA2), imageCount: 49),
    CategoryItem(id: 'cicekler', name: 'Çiçekler', icon: '🌸', color: Color(0xFFE91E63), imageCount: 30),
    CategoryItem(id: 'prensesler', name: 'Prensesler', icon: '👑', color: Color(0xFFF06292), imageCount: 100),
    CategoryItem(id: 'masal_kahramanlari', name: 'Masal Kahramanları', icon: '🧚', color: Color(0xFF7C4DFF), imageCount: 50),
    CategoryItem(id: 'spor', name: 'Spor', icon: '⚽', color: Color(0xFF43A047), imageCount: 33),
    CategoryItem(id: 'muzik_aletleri', name: 'Müzik Aletleri', icon: '🎸', color: Color(0xFFFF6F00), imageCount: 29),
    CategoryItem(id: 'manzaralar', name: 'Manzaralar', icon: '🏔️', color: Color(0xFF00897B), imageCount: 34),
    CategoryItem(id: 'bahceler', name: 'Bahçeler', icon: '🌻', color: Color(0xFF689F38), imageCount: 30),
    CategoryItem(id: 'custom', name: 'Kendi Resmini Seç', icon: '🖼️', color: Color(0xFF9C27B0)),
    CategoryItem(id: 'blank', name: 'Boş Defter', icon: '📓', color: Color(0xFFFFF9C4)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern AppBar
              _buildModernAppBar(context),
              // Kategori grid'i
              Expanded(
                child: _buildCategoryGrid(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Geri butonu
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Başlık
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎨 Kategori Seçin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_allCategories.length} kategori mevcut',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Toplam resim sayısı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              '🖼️ ${_allCategories.fold(0, (sum, c) => sum + c.imageCount)}+',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final columns = ResponsiveHelper.getCategoryGridColumns(context);
    final padding = ResponsiveHelper.getPadding(context);
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.3,
        ),
        itemCount: _allCategories.length,
        itemBuilder: (context, index) {
          final category = _allCategories[index];
          return _buildCategoryCard(context, category, index);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryItem category, int index) {
    return GestureDetector(
      onTap: () => _onCategoryTap(context, category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category.color,
              category.color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: category.color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onCategoryTap(context, category),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // İkon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Başlık
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 30 * index),
          duration: 400.ms,
        )
        .scale(begin: const Offset(0.9, 0.9));
  }

  void _onCategoryTap(BuildContext context, CategoryItem category) {
    if (category.id == 'custom') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomImagePage(),
        ),
      );
    } else if (category.id == 'blank') {
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
  }
}
