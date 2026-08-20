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
            // ── Borç Özeti ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Ödenecek Tutar',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₺${widget.debt.totalAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.amountLarge.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Açıklama', style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.7))),
                      Flexible(
                        child: Text(
                          widget.debt.description,
                          textAlign: TextAlign.end,
                          style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Kredi Kartı Formu (Mock) ──
            Text('Kart Bilgileri', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField('Kart Üzerindeki İsim', 'Örn: ALİ YILMAZ', Icons.person_outline_rounded),
                  const SizedBox(height: 16),
                  _buildTextField('Kart Numarası', '0000 0000 0000 0000', Icons.credit_card_rounded),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('SKT', 'AA/YY', Icons.calendar_today_rounded)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('CVV', '***', Icons.lock_rounded)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Ödeme Butonu ──
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              child: _isProcessing
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Text('₺${widget.debt.totalAmount.toStringAsFixed(2)} Öde'),
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
                color: AppColors.debtPaid.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.debtPaid),
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