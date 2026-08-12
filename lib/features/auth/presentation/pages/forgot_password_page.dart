import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';
import '../../../../../../app/theme/app_colors.dart';
import '../../../../../../app/theme/app_text_styles.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _identifierController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Adım: 0=telefon gir, 1=OTP gir, 2=yeni şifre
  int _step = 0;
  String _sentPhone = '';

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Şifremi Unuttum'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is AuthForgotPasswordOtpSent) {
            setState(() {
              _sentPhone = state.identifier;
              _step = 1;
            });
          }
          if (state is AuthOtpVerified) {
            setState(() => _step = 2);
          }
          if (state is AuthPasswordReset) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Şifreniz başarıyla sıfırlandı!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthActionLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Adım göstergesi ─────────────────────
                  _StepIndicator(currentStep: _step),
                  const SizedBox(height: 32),

                  if (_step == 0) _buildPhoneStep(isLoading),
                  if (_step == 1) _buildOtpStep(isLoading),
                  if (_step == 2) _buildNewPasswordStep(isLoading),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhoneStep(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kayıtlı telefon numaranızı girin',
            style: AppTextStyles.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Şifre sıfırlama kodu bu numaraya SMS ile gönderilecek.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        Text('Telefon veya E-posta', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: _identifierController,
          keyboardType: TextInputType.text,
          enabled: !isLoading,
          style: AppTextStyles.inputText,
          decoration: const InputDecoration(
            hintText: '5XX XXX XX XX veya e-posta',
            prefixIcon: Icon(Icons.person_outline, size: 20, color: AppColors.textTertiary),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Bu alan zorunlu' : null,
        ),
        const SizedBox(height: 28),
        _ActionButton(
          label: 'Kod Gönder',
          isLoading: isLoading,
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            context.read<AuthCubit>().sendForgotPasswordOtp(
                  identifier: _identifierController.text.trim(),
                );
          },
        ),
      ],
    );
  }

  Widget _buildOtpStep(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Doğrulama Kodu', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            children: [
              const TextSpan(text: ''),
              TextSpan(
                text: _sentPhone,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' numarasına gönderilen 6 haneli kodu girin.'),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Doğrulama Kodu', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          enabled: !isLoading,
          style: AppTextStyles.inputText.copyWith(
            letterSpacing: 8,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            hintText: '000000',
            counterText: '',
            prefixIcon: Icon(Icons.lock_outline, size: 20, color: AppColors.textTertiary),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Kod gerekli';
            if (v.length != 6) return '6 haneli kod girin';
            return null;
          },
        ),
        const SizedBox(height: 28),
        _ActionButton(
          label: 'Kodu Doğrula',
          isLoading: isLoading,
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            context.read<AuthCubit>().verifyOtp(
                  phone: _sentPhone,
                  code: _otpController.text.trim(),
                );
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: isLoading
                ? null
                : () {
                    setState(() => _step = 0);
                    context.read<AuthCubit>().resetState();
                  },
            child: Text(
              'Tekrar Gönder',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Yeni Şifre', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Güvenli bir şifre belirleyin.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        Text('Yeni Şifre', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          enabled: !isLoading,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textTertiary),
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Şifre gerekli';
            if (v.length < 8) return 'En az 8 karakter olmalı';
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text('Şifre Tekrar', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordConfirmController,
          obscureText: _obscureConfirm,
          enabled: !isLoading,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textTertiary),
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Şifre tekrarı gerekli';
            if (v != _passwordController.text) return 'Şifreler eşleşmiyor';
            return null;
          },
        ),
        const SizedBox(height: 28),
        _ActionButton(
          label: 'Şifremi Sıfırla',
          isLoading: isLoading,
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            context.read<AuthCubit>().resetPassword(
                  phone: _sentPhone,
                  code: _otpController.text.trim(),
                  password: _passwordController.text,
                  passwordConfirm: _passwordConfirmController.text,
                );
          },
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i <= currentStep;
        final isCurrent = i == currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < 2) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
