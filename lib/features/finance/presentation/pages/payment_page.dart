import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/debt.dart';
import '../controllers/finance_cubit.dart';

class PaymentPage extends StatefulWidget {
  final Debt debt;

  const PaymentPage({super.key, required this.debt});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;
  bool _isSuccess = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Ödeme yapılıyormuş gibi bekle (Mock gecikme)
    await Future.delayed(const Duration(seconds: 2));

    // Normalde burada cubit üzerinden `payDebt(debtId, cardToken)` çağrılır.
    // Şimdilik sadece görsel akışı tamamlıyoruz.
    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });

    // Başarı ekranını biraz gösterdikten sonra geri dön ve borçları yenile
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.read<FinanceCubit>().fetchDebts();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return _buildSuccessView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ödeme Yap'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Borç Özeti
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text('Ödenecek Tutar', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Text(
                    '₺${widget.debt.amount.toStringAsFixed(2)}',
                    style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Açıklama', style: AppTextStyles.bodySmall),
                      Text(widget.debt.description, style: AppTextStyles.labelMedium),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Kredi Kartı Formu (Mock)
            Text('Kart Bilgileri', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            
            _buildTextField('Kart Üzerindeki İsim', 'Örn: ALİ YILMAZ', Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField('Kart Numarası', '0000 0000 0000 0000', Icons.credit_card),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildTextField('SKT', 'AA/YY', Icons.calendar_today_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('CVV', '***', Icons.lock_outline)),
              ],
            ),
            
            const SizedBox(height: 48),
            
            // Ödeme Butonu
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        '₺${widget.debt.amount.toStringAsFixed(2)} Öde',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 80, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            Text('Ödeme Başarılı!', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Borcunuz başarıyla ödendi.\nYönlendiriliyorsunuz...',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
