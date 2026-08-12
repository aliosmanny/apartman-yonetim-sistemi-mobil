/// Uygulama rota isimleri.
/// Tüm navigasyon bu sabitlerle yapılır — magic string kullanılmaz.
abstract class RouteNames {
  // ── Auth ─────────────────────────────────────
  static const splash = 'splash';
  static const login = 'login';
  static const forgotPassword = 'forgot-password';
  static const otpVerify = 'otp-verify';
  static const resetPassword = 'reset-password';

  // ── Manager Shell ─────────────────────────────
  static const managerShell = 'manager-shell';
  static const managerDashboard = 'manager-dashboard';
  static const managerProperties = 'manager-properties';
  static const managerFinance = 'manager-finance';
  static const managerMaintenance = 'manager-maintenance';
  static const managerMore = 'manager-more';

  // ── Resident Shell ────────────────────────────
  static const residentShell = 'resident-shell';
  static const residentDashboard = 'resident-dashboard';
  static const residentDebts = 'resident-debts';
  static const residentMaintenance = 'resident-maintenance';
  static const residentAnnouncements = 'resident-announcements';
  static const residentProfile = 'resident-profile';

  // ── Staff Shell ───────────────────────────────
  static const staffShell = 'staff-shell';
  static const staffDashboard = 'staff-dashboard';
  static const staffAssigned = 'staff-assigned';
  static const staffCompleted = 'staff-completed';
  static const staffNotifications = 'staff-notifications';
  static const staffProfile = 'staff-profile';
}
