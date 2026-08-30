import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../coloring/coloring_page.dart';
import '../../data/services/ad_service.dart';
import '../../core/utils/responsive_helper.dart';

/// Kategori isimlerini klasör isimlerine eşle (güncel)
const Map<String, String> _categoryFolderMap = {
  'Çiftlik': 'ciftlik',
  'Deniz Altı': 'deniz_alti',
  'Dinozor': 'dinozor',
  'Doğa Gökyüzü': 'doga_gokyuzu',
  'Emoji': 'emoji',
  'Erkek Karakter': 'erkek_karakter',
  'Harfler': 'harfler',
  'İnşaat': 'insaat',
  'Kahramanlar': 'kahraman',
  'Kız Karakter': 'kiz_karakter',
  'Meslekler': 'meslekler',
  'Meyveler': 'meyveler',
  'Oyuncaklar': 'oyuncak',
  'Robotlar': 'robot',
  'Sayılar': 'sayilar',
  'Sevimli Dostlar': 'sevimli_dostlar',
  'Tamamlayıcı': 'tamamlayici',
  'Taşıtlar': 'tasitlar',
  'Uzay': 'uzay',
  'Vahşi Dostlar': 'vahsi_dostlar',
  'Mandalalar': 'mandalalar',
  'Çiçekler': 'cicekler',
  'Prensesler': 'prensesler',
  'Masal Kahramanları': 'masal_kahramanlari',
  'Spor': 'spor',
  'Müzik Aletleri': 'muzik_aletleri',
  'Manzaralar': 'manzaralar',
  'Bahçeler': 'bahceler',
};

/// Her kategorideki resim sayıları (güncel - tümü SVG)
const Map<String, int> _categoryImageCounts = {
  'ciftlik': 83,
  'deniz_alti': 92,
  'dinozor': 100,
  'doga_gokyuzu': 42,
  'emoji': 90,
  'erkek_karakter': 50,
  'harfler': 30,
  'insaat': 80,
  'kahraman': 37,
  'kiz_karakter': 50,
  'meslekler': 47,
  'meyveler': 25,
  'oyuncak': 50,
  'robot': 66,
  'sayilar': 22,
  'sevimli_dostlar': 15,
  'tamamlayici': 35,
  'tasitlar': 55,
  'uzay': 35,
  'vahsi_dostlar': 43,
  'mandalalar': 49,
  'cicekler': 30,
  'prensesler': 100,
  'masal_kahramanlari': 50,
  'spor': 33,
  'muzik_aletleri': 29,
  'manzaralar': 34,
  'bahceler': 30,
};

/// Kategori resim galerisi sayfası
class CategoryGalleryPage extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;

  const CategoryGalleryPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<CategoryGalleryPage> createState() => _CategoryGalleryPageState();
}

class _CategoryGalleryPageState extends State<CategoryGalleryPage> {
  late List<String> _imagePaths;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    final folderName = _categoryFolderMap[widget.categoryName] ?? 'ciftlik';
    final imageCount = _categoryImageCounts[folderName] ?? 11;

    _imagePaths = [];

    for (int i = 1; i <= imageCount; i++) {
      // PNG formatını ekle (optimize edilmiş)
      String pngPath = 'assets/images/$folderName/${folderName}_$i.png';
      _imagePaths.add(pngPath);
    }

    setState(() => _isLoading = false);
  }

  void _openColoringPage(int index) {
    // Boyama sayfasına geçişte reklam göster
    AdService.instance.showInterstitialAd(
      onAdClosed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColoringPage(
              categoryName: widget.categoryName,
              categoryIcon: widget.categoryIcon,
              categoryColor: widget.categoryColor,
              initialImageIndex: index,
              imagePaths: _imagePaths,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: widget.categoryColor.withOpacity(0.3),
        title: Text(
          '${widget.categoryIcon} ${widget.categoryName}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.buttonSecondary,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Text(
                  '${_imagePaths.length} resim',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.getGridColumns(context),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _imagePaths.length,
                itemBuilder: (context, index) => _buildImageCard(index),
              ),
            ),
    );
  }

  Widget _buildImageCard(int index) {
    return GestureDetector(
      onTap: () => _openColoringPage(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: AppConstants.borderWidth),
          boxShadow: const [BoxShadow(color: AppColors.shadow, offset: Offset(AppConstants.shadowOffset, AppConstants.shadowOffset))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${index + 1}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: widget.categoryColor),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildImageWithIndex(index),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.2),
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: const Text(
                'Boyamaya Başla 🎨',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 30 * index), duration: 300.ms)
          .scale(begin: const Offset(0.95, 0.95)),
    );
  }

  /// PNG formatında resim göster
  Widget _buildImageWithIndex(int index) {
    final folderName = _categoryFolderMap[widget.categoryName] ?? 'ciftlik';
    final imageIndex = index + 1;

    String pngPath = 'assets/images/$folderName/${folderName}_$imageIndex.png';

    return Image.asset(
      pngPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(Icons.image, size: 32, color: widget.categoryColor.withOpacity(0.5)),
        );
      },
    );
  }
}
