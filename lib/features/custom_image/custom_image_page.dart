import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../coloring/coloring_page.dart';

/// Kullanıcının kendi resimlerini seçtiği sayfa
class CustomImagePage extends StatefulWidget {
  const CustomImagePage({super.key});

  @override
  State<CustomImagePage> createState() => _CustomImagePageState();
}

class _CustomImagePageState extends State<CustomImagePage> {
  List<String> _pickedImagePaths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  /// Kaydedilmiş resimleri yükle
  Future<void> _loadSavedImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final customDir = io.Directory('${directory.path}/custom_images');
      
      if (await customDir.exists()) {
        final files = await customDir.list().toList();
        setState(() {
          _pickedImagePaths = files
              .where((file) => file.path.endsWith('.png') || file.path.endsWith('.jpg') || file.path.endsWith('.jpeg'))
              .map((file) => file.path)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Galeriden resim seç
  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final directory = await getApplicationDocumentsDirectory();
        final customDir = io.Directory('${directory.path}/custom_images');
        
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        for (final file in result.files) {
          if (file.path != null) {
            // Resmi uygulama klasörüne kopyala
            final fileName = 'custom_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
            final destinationPath = '${customDir.path}/$fileName';
            
            await io.File(file.path!).copy(destinationPath);
          }
        }

        // Resimleri yeniden yükle
        await _loadSavedImages();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.files.length} resim eklendi! 🎨'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resim seçilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Resmi sil
  Future<void> _deleteImage(String path) async {
    try {
      final file = io.File(path);
      if (await file.exists()) {
        await file.delete();
      }
      await _loadSavedImages();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resim silindi! 🗑️'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resim silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Boyama sayfasını aç
  void _openColoringPage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColoringPage(
          categoryName: 'Kendi Resmim',
          categoryIcon: '🖼️',
          categoryColor: Colors.purple,
          initialImageIndex: 0,
          imagePaths: [_pickedImagePaths[index]],
          isCustomImage: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.purple.withOpacity(0.3),
        title: const Text(
          '🖼️ Kendi Resmini Seç',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
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
                  '${_pickedImagePaths.length} resim',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Resim seç butonu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.purple[300]),
                          const SizedBox(height: 8),
                          const Text(
                            '📱 Galerinden Resim Seç',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Telefonundaki veya tabletindeki resimleri seç',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Talimatlar
                if (_pickedImagePaths.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_search, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz resim seçilmedi',
                            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yukarıdaki butona basarak galerinden\nresim seçebilirsin',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Seçilen resimler
                if (_pickedImagePaths.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _pickedImagePaths.length,
                        itemBuilder: (context, index) => _buildImageCard(index),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildImageCard(int index) {
    return GestureDetector(
      onTap: () => _openColoringPage(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
        ),
        child: Column(
          children: [
            // Resim
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.file(
                      io.File(_pickedImagePaths[index]),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_not_supported, size: 32, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  // Sil butonu
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _deleteImage(_pickedImagePaths[index]),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Boyama butonu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                border: Border(top: BorderSide(color: Colors.black, width: 2)),
              ),
              child: const Text(
                'Boyamaya Başla 🎨',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
