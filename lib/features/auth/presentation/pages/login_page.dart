import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';
import '../../../../../../app/theme/app_colors.dart';
import '../../../../../../app/theme/app_text_styles.dart';
import '../../../../../../app/router/route_names.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          // Başarılı giriş → GoRouter redirect halleder
        },
        builder: (context, state) {
          final isLoading = state is AuthActionLoading;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),

                          // ── Logo & Başlık ─────────────────────
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.apartment_rounded,
                                    size: 42,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Tekrar Hoş Geldiniz',
                                  style: AppTextStyles.displayMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Hesabınıza giriş yapın',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // ── Telefon ──────────────────────────
                          Text('Telefon Numarası', style: AppTextStyles.inputLabel),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            enabled: !isLoading,
                            style: AppTextStyles.inputText,
                            decoration: InputDecoration(
                              hintText: '5XX XXX XX XX',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 14, right: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.phone_outlined,
                                        size: 20, color: AppColors.textTertiary),
                                    SizedBox(width: 8),
                                    Text('+90',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 15,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    SizedBox(width: 4),
                                    SizedBox(
                                      height: 20,
                                      child: VerticalDivider(
                                        color: AppColors.border,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Telefon numarası gerekli';
                              }
                              final digits = value.replaceAll(RegExp(r'\D'), '');
                              if (digits.length != 10 && digits.length != 11) {
                                return 'Geçerli bir telefon numarası girin';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // ── Şifre ────────────────────────────
                          Text('Şifre', style: AppTextStyles.inputLabel),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            enabled: !isLoading,
                            style: AppTextStyles.inputText,
                            onFieldSubmitted: (_) => _onLogin(),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: AppColors.textTertiary,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre gerekli';
                              }
                              if (value.length < 6) {
                                return 'Şifre en az 6 karakter olmalı';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── Beni Hatırla & Şifremi Unuttum ───
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _rememberMe = !_rememberMe),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _rememberMe
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: _rememberMe
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: _rememberMe
                                          ? const Icon(Icons.check,
                                              size: 13, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Beni Hatırla',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        )),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => context.pushNamed(
                                        RouteNames.forgotPassword),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Şifremi Unuttum',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // ── Giriş Yap Butonu ─────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _onLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor:
                                    AppColors.primary.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Giriş Yap',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // ── Alt bilgi ────────────────────────
                          Center(
                            child: Text(
                              'Yalnızca yönetici tarafından tanımlanan\nhesaplarla giriş yapılabilir.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => _showQuickLoginSheet(context),
                              icon: const Icon(Icons.bug_report_outlined, size: 18),
                              label: const Text('Hızlı Test Girişi (Mock)'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showQuickLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hızlı Test Girişi', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Aşağıdaki rollerden biriyle şifre girmeden anında giriş yapabilirsiniz. (Sadece Mock modda çalışır)',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 24),
              _MockLoginButton(
                title: '🏢 Sistem Yöneticisi',
                phone: '5001234567',
                onTap: (phone) {
                  Navigator.pop(context);
                  _phoneController.text = phone;
                  _passwordController.text = '123456';
                  _onLogin();
                },
              ),
              const SizedBox(height: 12),
              _MockLoginButton(
                title: '🏠 Sakin (Ev Sahibi)',
                phone: '5001234569',
                onTap: (phone) {
                  Navigator.pop(context);
                  _phoneController.text = phone;
                  _passwordController.text = '123456';
                  _onLogin();
                },
              ),
              const SizedBox(height: 12),
              _MockLoginButton(
                title: '👷 Personel',
                phone: '5001234571',
                onTap: (phone) {
                  Navigator.pop(context);
                  _phoneController.text = phone;
                  _passwordController.text = '123456';
                  _onLogin();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockLoginButton extends StatelessWidget {
  final String title;
  final String phone;
  final Function(String) onTap;

  const _MockLoginButton({
    required this.title,
    required this.phone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(phone),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
