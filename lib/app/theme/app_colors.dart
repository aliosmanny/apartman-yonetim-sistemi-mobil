import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Primary ─────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // ── Secondary ────────────────────────────────────
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryLight = Color(0xFF38BDF8);

  // ── Semantic ─────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF6366F1);
  static const Color infoLight = Color(0xFFE0E7FF);

  // ── Backgrounds ──────────────────────────────────
  static const Color background = Color(0xFFF0F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFAFBFF);

  // ── Text ─────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Border ───────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = Color(0xFF818CF8);
  static const Color divider = Color(0xFFF1F5F9);

  // ── Rol renkleri ──────────────────────────────────
  static const Color roleSystemAdmin = Color(0xFF7C3AED);
  static const Color roleManager = Color(0xFF4F46E5);
  static const Color roleOwner = Color(0xFF0D9488);
  static const Color roleTenant = Color(0xFF059669);
  static const Color roleStaff = Color(0xFFD97706);

  // ── Borç durumları ────────────────────────────────
  static const Color debtUnpaid = Color(0xFFEF4444);
  static const Color debtPartial = Color(0xFFF59E0B);
  static const Color debtPaid = Color(0xFF10B981);
  static const Color debtOverdue = Color(0xFF7F1D1D);

  // ── Bakım talep durumları ─────────────────────────
  static const Color maintenancePending = Color(0xFFF59E0B);
  static const Color maintenanceAssigned = Color(0xFF818CF8);
  static const Color maintenanceInProgress = Color(0xFF8B5CF6);
  static const Color maintenanceCompleted = Color(0xFF10B981);
  static const Color maintenanceCancelled = Color(0xFF6B7280);

  // ── Gradient ─────────────────────────────────────
  // Manager — indigo → purple (derin, kurumsal)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Resident debt card — dinamik (yeşil borçsuz, kırmızı borçlu)
  // Varsayılan: koyu mavi-lacivert (tarafsız)
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient debtFreeGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient debtPendingGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient debtOverdueGradient = LinearGradient(
    colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Staff — amber (sıcak, enerji)
  static const LinearGradient staffGradient = LinearGradient(
    colors: [Color(0xFFB45309), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Resident — teal (huzurlu, ev hissi)
  static const LinearGradient residentGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Warning gradient
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
