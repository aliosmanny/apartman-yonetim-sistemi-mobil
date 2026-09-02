import re

def fix():
    path = 'lib/app/theme/app_theme.dart'
    with open(path, 'r') as f:
        content = f.read()

    fast_builder = """import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

// Sayfalar arası geçişi hızlandırmak (minimize etmek) için özel transition builder
class FastPageTransitionsBuilder extends PageTransitionsBuilder {
  const FastPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Sadece çok hızlı bir fade (solma) efekti uygular, slide veya zoom yapmaz.
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
"""
    
    content = content.replace(
        "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';\nimport 'app_colors.dart';\nimport 'app_text_styles.dart';",
        fast_builder
    )

    find_theme = """    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.cardBackground,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,"""
      
    theme_data = """    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.cardBackground,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      
      // Geçiş animasyonlarını minimize ettik (çok hızlı Fade)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FastPageTransitionsBuilder(),
          TargetPlatform.iOS: FastPageTransitionsBuilder(),
        },
      ),"""
      
    content = content.replace(find_theme, theme_data)
    
    with open(path, 'w') as f:
        f.write(content)

fix()
