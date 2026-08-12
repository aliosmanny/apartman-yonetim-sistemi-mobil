import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'route_names.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/domain/models/auth_user.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/manager_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/resident_dashboard_page.dart';
import '../../features/finance/presentation/pages/debt_list_page.dart';
import '../../features/finance/presentation/pages/payment_page.dart';
import '../../features/finance/domain/models/debt.dart';
import '../../features/maintenance/presentation/pages/maintenance_list_page.dart';
import '../../features/maintenance/presentation/pages/create_maintenance_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/announcements/presentation/pages/announcement_list_page.dart';
import '../../features/documents/presentation/pages/document_list_page.dart';
import '../../features/dashboard/presentation/pages/staff_dashboard_page.dart';

class AppRouter {
  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      refreshListenable: _AuthChangeNotifier(authCubit),
      redirect: (context, state) {
        final authState = authCubit.state;
        final currentPath = state.uri.path;

        final isAuthPage = currentPath == '/login' ||
            currentPath.startsWith('/forgot-password') ||
            currentPath == '/splash';

        if (authState is AuthInitial || authState is AuthLoading) {
          return '/splash';
        }

        if (authState is AuthUnauthenticated || authState is AuthError) {
          if (currentPath == '/splash') return '/login';
          return isAuthPage ? null : '/login';
        }

        if (authState is AuthAuthenticated) {
          if (isAuthPage) {
            return _dashboardRouteForRole(authState.user.role);
          }
        }

        return null;
      },
      routes: [
        // ── Splash ───────────────────────────────────
        GoRoute(
          path: '/splash',
          name: RouteNames.splash,
          builder: (_, __) => const SplashPage(),
        ),

        // ── Auth ─────────────────────────────────────
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: RouteNames.forgotPassword,
          builder: (_, __) => const ForgotPasswordPage(),
        ),

        // ── Manager Shell ─────────────────────────────
        ShellRoute(
          builder: (context, state, child) =>
              _ManagerShell(child: child),
          routes: [
            GoRoute(
              path: '/manager',
              name: RouteNames.managerDashboard,
              builder: (_, __) => const ManagerDashboardPage(),
            ),
            GoRoute(
              path: '/manager/properties',
              name: RouteNames.managerProperties,
              builder: (_, __) =>
                  const _PlaceholderPage(title: 'Yapı Yönetimi'),
            ),
            GoRoute(
              path: '/manager/finance',
              name: RouteNames.managerFinance,
              builder: (_, __) =>
                  const _PlaceholderPage(title: 'Finans'),
            ),
            GoRoute(
              path: '/manager/maintenance',
              name: RouteNames.managerMaintenance,
              builder: (_, __) =>
                  const _PlaceholderPage(title: 'Talepler'),
            ),
            GoRoute(
              path: '/manager/more',
              name: RouteNames.managerMore,
              builder: (_, __) => const _PlaceholderPage(title: 'Menü'),
            ),
          ],
        ),

        // ── Resident Shell ────────────────────────────
        ShellRoute(
          builder: (context, state, child) =>
              _ResidentShell(child: child),
          routes: [
            GoRoute(
              path: '/resident',
              name: RouteNames.residentDashboard,
              builder: (_, __) => const ResidentDashboardPage(),
            ),
            GoRoute(
              path: '/resident/debts',
              name: RouteNames.residentDebts,
              builder: (_, __) => const DebtListPage(),
              routes: [
                GoRoute(
                  path: 'pay',
                  name: 'residentPayment',
                  builder: (_, state) {
                    final debt = state.extra as Debt;
                    return PaymentPage(debt: debt);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/resident/maintenance',
              name: RouteNames.residentMaintenance,
              builder: (_, __) => const MaintenanceListPage(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'residentMaintenanceCreate',
                  builder: (_, __) => const CreateMaintenancePage(),
                ),
              ],
            ),
            GoRoute(
              path: '/resident/announcements',
              name: RouteNames.residentAnnouncements,
              builder: (_, __) => const AnnouncementListPage(),
            ),
            GoRoute(
              path: '/resident/documents',
              name: 'residentDocuments',
              builder: (_, __) => const DocumentListPage(),
            ),
            GoRoute(
              path: '/resident/profile',
              name: RouteNames.residentProfile,
              builder: (_, __) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'change-password',
                  name: 'residentChangePassword',
                  builder: (_, __) => const ChangePasswordPage(),
                ),
              ],
            ),
          ],
        ),

        // ── Staff Shell ───────────────────────────────
        ShellRoute(
          builder: (context, state, child) => _StaffShell(child: child),
          routes: [
            GoRoute(
              path: '/staff',
              name: RouteNames.staffDashboard,
              builder: (_, __) => const StaffDashboardPage(),
            ),
            GoRoute(
              path: '/staff/assigned',
              name: RouteNames.staffAssigned,
              builder: (_, __) =>
                  const _PlaceholderPage(title: 'Atanan İşler'),
            ),
            GoRoute(
              path: '/staff/completed',
              name: RouteNames.staffCompleted,
              builder: (_, __) =>
                  const _PlaceholderPage(title: 'Tamamlananlar'),
            ),
            GoRoute(
              path: '/staff/notifications',
              name: RouteNames.staffNotifications,
              builder: (_, __) =>
                  const _PlaceholderPage(title: 'Bildirimler'),
            ),
            GoRoute(
              path: '/staff/profile',
              name: RouteNames.staffProfile,
              builder: (_, __) => const _PlaceholderPage(title: 'Profil'),
            ),
          ],
        ),
      ],
    );
  }

  static String _dashboardRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.systemAdmin:
      case UserRole.apartmentManager:
        return '/manager';
      case UserRole.owner:
      case UserRole.tenant:
        return '/resident';
      case UserRole.staff:
        return '/staff';
    }
  }
}

// ── GoRouter için AuthCubit listeleyici ──────────────────
class _AuthChangeNotifier extends ChangeNotifier {
  final AuthCubit _cubit;

  _AuthChangeNotifier(this._cubit) {
    _cubit.stream.listen((_) => notifyListeners());
  }
}

// ── Shell'ler ────────────────────────────────────────────

class _ManagerShell extends StatelessWidget {
  final Widget child;
  const _ManagerShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int index = 0;
    if (location.startsWith('/manager/properties')) {
      index = 1;
    } else if (location.startsWith('/manager/finance')) {
      index = 2;
    } else if (location.startsWith('/manager/maintenance')) {
      index = 3;
    } else if (location.startsWith('/manager/more')) {
      index = 4;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/manager');
              break;
            case 1:
              context.go('/manager/properties');
              break;
            case 2:
              context.go('/manager/finance');
              break;
            case 3:
              context.go('/manager/maintenance');
              break;
            case 4:
              context.go('/manager/more');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.apartment_outlined), selectedIcon: Icon(Icons.apartment), label: 'Yapılar'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Finans'),
          NavigationDestination(icon: Icon(Icons.build_outlined), selectedIcon: Icon(Icons.build), label: 'Talepler'),
          NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'Menü'),
        ],
      ),
    );
  }
}

class _ResidentShell extends StatelessWidget {
  final Widget child;
  const _ResidentShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int index = 0;
    if (location.startsWith('/resident/debts')) {
      index = 1;
    } else if (location.startsWith('/resident/maintenance')) {
      index = 2;
    } else if (location.startsWith('/resident/announcements')) {
      index = 3;
    } else if (location.startsWith('/resident/profile')) {
      index = 4;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/resident');
              break;
            case 1:
              context.go('/resident/debts');
              break;
            case 2:
              context.go('/resident/maintenance');
              break;
            case 3:
              context.go('/resident/announcements');
              break;
            case 4:
              context.go('/resident/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Borçlar'),
          NavigationDestination(icon: Icon(Icons.build_outlined), selectedIcon: Icon(Icons.build), label: 'Talepler'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Duyurular'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _StaffShell extends StatelessWidget {
  final Widget child;
  const _StaffShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int index = 0;
    if (location.startsWith('/staff/assigned')) {
      index = 1;
    } else if (location.startsWith('/staff/completed')) {
      index = 2;
    } else if (location.startsWith('/staff/notifications')) {
      index = 3;
    } else if (location.startsWith('/staff/profile')) {
      index = 4;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/staff');
              break;
            case 1:
              context.go('/staff/assigned');
              break;
            case 2:
              context.go('/staff/completed');
              break;
            case 3:
              context.go('/staff/notifications');
              break;
            case 4:
              context.go('/staff/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Atanan'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: 'Tamamlanan'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Bildirimler'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ── Placeholder ───────────────────────────────────────────
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              '$title yakında burada!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
