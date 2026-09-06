import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/neubrutal_button.dart';

/// Ebeveyn Doğrulama Diyaloğu (Parental Gate)
/// Google Play Families ve Apple Kids politikalarına uygundur.
class ParentalGateDialog extends StatefulWidget {
  const ParentalGateDialog({super.key});

  /// Ebeveyn onayını çalıştırır, doğrulanırsa true döner
  static Future<bool> verify(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ParentalGateDialog(),
    );
    return result ?? false;
  }

  @override
  State<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<ParentalGateDialog> {
  late int _num1;
  late int _num2;
  late int _correctAnswer;
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    // 6..9 arası çarpma işlemi (çocukların tahmin etmesini zorlaştırır)
    _num1 = 6 + random.nextInt(4); // 6, 7, 8, 9
    _num2 = 4 + random.nextInt(6); // 4, 5, 6, 7, 8, 9
    _correctAnswer = _num1 * _num2;
    _controller.clear();
    _errorMessage = null;
  }

  void _checkAnswer() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Lütfen cevabı girin');
      return;
    }

    final answer = int.tryParse(text);
    if (answer == _correctAnswer) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = 'Yanlış cevap, lütfen tekrar deneyin.';
        _generateQuestion();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 3),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İkon & Başlık
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: const Center(
                child: Text('🔒', style: TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ebeveyn Onayı',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu alana devam etmek için lütfen aşağıdaki soruyu bir yetişkine çözdürün:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Soru Alanı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: Text(
                '$_num1 × $_num2 = ?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cevap Girişi
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Sonucu girin',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                errorText: _errorMessage,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2.5),
                ),
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
            const SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'İptal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeubrutalButton(
                    label: 'Onayla',
                    backgroundColor: AppColors.buttonPrimary,
                    height: 50,
                    onPressed: _checkAnswer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
