import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/debt.dart';
import '../../data/dto/finance_dto.dart';
import '../controllers/finance_cubit.dart';
import 'payment_webview_page.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../auth/domain/models/auth_user.dart';

class PaymentDialog extends StatefulWidget {
  final Debt debt;

  const PaymentDialog({super.key, required this.debt});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isLoading = false;
  String _selectedInstallment = 'Tek Çekim';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _numberController.addListener(() => setState(() {}));
    _expiryController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _fillTestCard() {
    _nameController.text = 'İYZİCO TEST KULLANICISI';
    _numberController.text = '5890 0400 0000 0016';
    _expiryController.text = '12/30';
    _cvvController.text = '123';
  }

  String _formatCardNumber(String input) {
    String cleaned = input.replaceAll(RegExp(r'\s+\b|\b\s'), '');
    cleaned = cleaned.replaceAll(' ', '');
    if (cleaned.isEmpty) return '**** **** **** ****';
    
    String formatted = '';
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += cleaned[i];
    }
    return formatted;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = PaymentInitiateRequestDto(
        cardName: _nameController.text,
        cardNumber: _numberController.text.replaceAll(' ', ''),
        cardExpiry: _expiryController.text,
        cardCvv: _cvvController.text,
      );

      final cubit = context.read<FinanceCubit>();
      final result = await cubit.initiatePayment(widget.debt.id, request);

      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.detail ?? 'Ödeme başlatılamadı.'),
          backgroundColor: AppColors.error,
        ));
      } else if (result.needs3ds && result.htmlContent != null) {
        Navigator.of(context).pop();
        final success = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (ctx) => PaymentWebViewPage(htmlContent: result.htmlContent!),
          ),
        );
        
        if (success == true) {
          final authState = context.read<AuthCubit>().state;
          final isManager = authState is AuthAuthenticated && authState.user.role.isManager;
          if (isManager) {
            cubit.fetchManagerFinance();
          } else {
            cubit.fetchDebts();
          }
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ödeme başarıyla alındı!'),
          backgroundColor: AppColors.success,
        ));
        final authState = context.read<AuthCubit>().state;
        final isManager = authState is AuthAuthenticated && authState.user.role.isManager;
        if (isManager) {
          cubit.fetchManagerFinance();
        } else {
          cubit.fetchDebts();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Bir hata oluştu: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCreditCardPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B247A), Color(0xFF6B48FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B48FF).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chip Icon
              Container(
                width: 45,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
                  gradient: LinearGradient(
                    colors: [Colors.yellow.shade400, Colors.yellow.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(width: 1, color: Colors.orangeAccent.withValues(alpha: 0.5)),
                    Container(width: 1, color: Colors.orangeAccent.withValues(alpha: 0.5)),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.lock_outline, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text('SSL', style: AppTextStyles.labelMedium.copyWith(color: Colors.white70)),
                ],
              )
            ],
          ),
          Text(
            _formatCardNumber(_numberController.text),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Courier',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kart Sahibi', style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                    Text(
                      _nameController.text.isEmpty ? 'AD SOYAD' : _nameController.text.toUpperCase(),
                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Son Kullanma', style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                  Text(
                    _expiryController.text.isEmpty ? 'AA/YY' : _expiryController.text,
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Güvenli Online Ödeme',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                        ),
                        child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Debt Info Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
                          ]
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('Borç', widget.debt.description),
                            const Divider(height: 16),
                            _buildInfoRow('Daire', widget.debt.unitDisplay ?? '-'),
                            const Divider(height: 16),
                            _buildInfoRow('Ödenecek', '₺${widget.debt.totalAmount.toStringAsFixed(2)}', isAmount: true),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Card Preview
                      _buildCreditCardPreview(),
                      
                      const SizedBox(height: 20),
                      
                      // Iyzico Fill Button
                      InkWell(
                        onTap: _fillTestCard,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF), // Light purple
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD8B4FE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on, color: Color(0xFF7C3AED), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('İyzico Test Kartı (3DS)', style: AppTextStyles.labelLarge.copyWith(color: const Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                                    Text('5890 0400 0000 0016 • 12/30 • 123', style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF9333EA))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Doldur', style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Form Fields
                      Text('KART SAHİBİNİN ADI SOYADI', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(),
                        validator: (v) => v!.isEmpty ? 'Boş bırakılamaz' : null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text('KART NUMARASI', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _numberController,
                        decoration: _inputDecoration(),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.replaceAll(' ', '').length < 15 ? 'Geçersiz kart numarası' : null,
                        onChanged: (v) {
                           // Basic spacing formatting for real time UX
                           String cleaned = v.replaceAll(' ', '');
                           if (cleaned.length > 16) cleaned = cleaned.substring(0, 16);
                           String formatted = '';
                           for (int i = 0; i < cleaned.length; i++) {
                             if (i > 0 && i % 4 == 0) formatted += ' ';
                             formatted += cleaned[i];
                           }
                           if (formatted != v) {
                             _numberController.value = TextEditingValue(
                               text: formatted,
                               selection: TextSelection.collapsed(offset: formatted.length),
                             );
                           }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SON KULLANMA', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _expiryController,
                                  decoration: _inputDecoration(hint: 'AA/YY'),
                                  keyboardType: TextInputType.datetime,
                                  validator: (v) => v!.length < 5 ? 'Geçersiz' : null,
                                  onChanged: (v) {
                                    if (v.length == 2 && !_expiryController.text.contains('/')) {
                                      _expiryController.text = '$v/';
                                      _expiryController.selection = TextSelection.collapsed(offset: 3);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CVV / CVC', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _cvvController,
                                  decoration: _inputDecoration(hint: '***'),
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  obscuringCharacter: '*',
                                  maxLength: 3,
                                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                                  validator: (v) => v!.length < 3 ? 'Hata' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Taksit Seçeneği
                      Text('TAKSİT SEÇENEĞİ', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedInstallment,
                        icon: const Icon(Icons.unfold_more, color: AppColors.textSecondary, size: 20),
                        decoration: _inputDecoration(),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        items: ['Tek Çekim', '2 Taksit', '3 Taksit', '6 Taksit']
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e, style: AppTextStyles.bodyMedium),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedInstallment = val);
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B48FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock, size: 18),
                                  const SizedBox(width: 8),
                                  Text('₺${widget.debt.totalAmount.toStringAsFixed(2)} Öde', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.security, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('256-bit SSL', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          const Icon(Icons.verified_user, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('3D Secure', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          const Icon(Icons.favorite, size: 12, color: Colors.purple),
                          const SizedBox(width: 4),
                          const Text('iyzico', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
            color: isAmount ? const Color(0xFF6B48FF) : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6B48FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }
}
