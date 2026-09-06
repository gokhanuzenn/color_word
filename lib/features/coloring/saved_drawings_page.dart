import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import 'coloring_page.dart';

/// Kayıtlı çizimler sayfası
/// Kullanıcının kaydettiği tüm boyamaları gösterir
class SavedDrawingsPage extends StatefulWidget {
  const SavedDrawingsPage({super.key});

  @override
  State<SavedDrawingsPage> createState() => _SavedDrawingsPageState();
}

class _SavedDrawingsPageState extends State<SavedDrawingsPage> {
  List<FileSystemEntity> _savedFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedDrawings();
  }

  Future<void> _loadSavedDrawings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savedDir = Directory('${directory.path}/saved_drawings');
      if (!await savedDir.exists()) {
        await savedDir.create(recursive: true);
      }
      final files = savedDir.listSync()
        ..sort((a, b) => b.path.compareTo(a.path)); // En yenisi üstte

      setState(() {
        _savedFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDrawing(FileSystemEntity file) async {
    try {
      await file.delete();
      setState(() {
        _savedFiles.remove(file);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Çizim silindi'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openDrawing(FileSystemEntity file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColoringPage(
          categoryName: 'Kayıtlı Çizim',
          categoryIcon: '💾',
          categoryColor: Colors.blue,
          initialImageIndex: 0,
          imagePaths: const [],
          isBlankCanvas: true,
          savedDrawingPath: file.path,
        ),
      ),
    ).then((_) => _loadSavedDrawings());
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(0.3),
        title: const Text(
          '💾 Kayıtlı Çizimlerim',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
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
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_savedFiles.length} çizim',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedFiles.isEmpty
              ? _buildEmptyState()
              : _buildDrawingsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📝', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Henüz kayıtlı çizim yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Boş defterde bir şey çiz ve kaydet!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ColoringPage(
                    categoryName: 'Boş Defter',
                    categoryIcon: '📝',
                    categoryColor: Colors.orange,
                    initialImageIndex: 0,
                    imagePaths: [],
                    isBlankCanvas: true,
                  ),
                ),
              ).then((_) => _loadSavedDrawings());
            },
            icon: const Icon(Icons.add),
            label: const Text('Yeni Çizim Başla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawingsList() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _savedFiles.length,
        itemBuilder: (context, index) => _buildDrawingCard(_savedFiles[index]),
      ),
    );
  }

  Widget _buildDrawingCard(FileSystemEntity file) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileDate = file.statSync().modified;

    return GestureDetector(
      onTap: () => _openDrawing(file),
      onLongPress: () => _showDeleteDialog(file),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Çizim önizlemesi (kalem ikonu)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child: const Center(
                child: Text('🎨', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 8),
            // Tarih
            Text(
              _formatDate(fileDate),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Dosya boyutu
            Text(
              '${(file.statSync().size / 1024).toStringAsFixed(1)} KB',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
            const Spacer(),
            // Alt bilgi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Text(
                'Dokunarak aç 🖌️',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(FileSystemEntity file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ Çizimi Sil'),
        content: const Text('Bu çizimi silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDrawing(file);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
