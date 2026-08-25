import '../../features/maintenance/domain/models/maintenance_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/finance/presentation/controllers/finance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/properties/presentation/controllers/properties_cubit.dart';
import '../../features/properties/presentation/pages/apartment_form_page.dart';
import '../../features/properties/presentation/pages/block_form_page.dart';
import '../../features/properties/presentation/pages/unit_form_page.dart';
import '../../features/properties/presentation/pages/owner_form_page.dart';
import '../../features/properties/presentation/pages/tenant_form_page.dart';
import '../../features/properties/presentation/pages/create_lease_contract_page.dart';





import 'package:flutter_bloc/flutter_bloc.dart';

import 'route_names.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/domain/models/auth_user.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/manager_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/manager_properties_page.dart';
import '../../features/dashboard/presentation/pages/manager_finance_page.dart';
import '../../features/dashboard/presentation/pages/manager_edit_due_period_page.dart';
import '../../features/dashboard/presentation/pages/manager_edit_debt_page.dart';
import '../../features/dashboard/presentation/pages/manager_edit_transaction_page.dart';
import '../../features/dashboard/presentation/pages/manager_add_expense_page.dart';
import '../../features/dashboard/presentation/pages/manager_maintenance_page.dart';
import '../../features/dashboard/presentation/pages/manager_services_page.dart';
import '../../features/staff/domain/models/staff_member.dart';
import '../../features/staff/presentation/controllers/staff_cubit.dart';
import '../../features/dashboard/presentation/pages/manager_staff_form_page.dart';
import '../../features/dashboard/presentation/pages/manager_more_page.dart';
import '../../features/dashboard/presentation/pages/manager_documents_page.dart';
import '../../features/dashboard/presentation/pages/manager_staff_page.dart';
import '../../features/dashboard/presentation/pages/manager_profile_page.dart';
import '../../features/dashboard/presentation/pages/manager_settings_page.dart';
import '../../features/dashboard/presentation/pages/manager_maintenance_detail_page.dart';
import '../../features/announcements/presentation/pages/create_announcement_page.dart';
import '../../features/dashboard/presentation/pages/manager_add_resident_page.dart';
import '../../features/dashboard/presentation/pages/manager_staff_form_page.dart';

import '../../features/dashboard/presentation/pages/resident_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/resident_properties_page.dart';
import '../../features/dashboard/presentation/pages/resident_finance_page.dart';
import '../../features/dashboard/presentation/pages/resident_operations_page.dart';

import '../../features/finance/presentation/pages/debt_list_page.dart';
import '../../features/finance/domain/models/debt.dart';
import '../../features/maintenance/presentation/pages/maintenance_list_page.dart';
import '../../features/maintenance/presentation/pages/create_maintenance_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/announcements/presentation/pages/announcement_list_page.dart';
import '../../features/dashboard/presentation/pages/manager_announcement_page.dart';
import '../../features/announcements/presentation/controllers/announcement_cubit.dart';
import '../../features/announcements/domain/models/announcement.dart';
import '../../features/documents/presentation/pages/document_list_page.dart';
import '../../features/dashboard/presentation/pages/manager_add_document_page.dart';
import '../../features/documents/presentation/controllers/document_cubit.dart';
import '../../features/dashboard/presentation/pages/staff_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/staff_assigned_page.dart';
import '../../features/dashboard/presentation/pages/staff_completed_page.dart';
import '../../features/dashboard/presentation/pages/staff_profile_page.dart';
import '../../features/dashboard/presentation/pages/staff_edit_profile_page.dart';
import '../../features/dashboard/presentation/pages/staff_settings_page.dart';


import '../../features/users/presentation/pages/user_list_page.dart';
import '../../features/users/presentation/pages/user_form_page.dart';
import '../../features/users/presentation/controllers/user_cubit.dart';
import '../../features/users/domain/models/user.dart';

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
              path: '/manager/users',
              name: 'managerUsers',
              builder: (_, __) => const UserListPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'managerAddUser',
                  builder: (context, state) {
                    final cubit = state.extra as UserCubit;
                    return UserFormPage(cubit: cubit);
                  },
                ),
                GoRoute(
                  path: 'edit',
                  name: 'managerEditUser',
                  builder: (context, state) {
                    final args = state.extra as Map<String, dynamic>;
                    return UserFormPage(
                      cubit: args['cubit'] as UserCubit,
                      user: args['user'] as AppUser,
                    );
                  },
                ),
              ],
            ),

            GoRoute(
              path: '/manager/properties',
              name: RouteNames.managerProperties,
              builder: (_, __) => const ManagerPropertiesPage(),
              routes: [
                GoRoute(
                  path: 'apartment/edit',
                  name: 'managerEditApartment',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return ApartmentFormPage(
                      apartment: extra['apartment'],
                      cubit: extra['cubit'],
                    );
                  },
                ),
                GoRoute(
                  path: 'block/edit',
                  name: 'managerEditBlock',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return BlockFormPage(
                      block: extra['block'],
                      cubit: extra['cubit'],
                    );
                  },
                ),

                GoRoute(
                  path: 'unit/edit',
                  name: 'managerEditUnit',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return UnitFormPage(
                      unit: extra['unit'],
                      cubit: extra['cubit'],
                    );
                  },
                ),


                GoRoute(
                  path: 'owner/edit',
                  name: 'managerEditOwner',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return OwnerFormPage(
                      owner: extra['owner'],
                      cubit: extra['cubit'],
                    );
                  },
                ),


                GoRoute(
                  path: 'tenant/edit',
                  name: 'managerEditTenant',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return TenantFormPage(
                      tenant: extra['tenant'],
                      cubit: extra['cubit'],
                    );
                  },
                ),

                GoRoute(
                  path: 'contracts/create',
                  name: 'managerCreateContract',
                  builder: (_, state) {
                    final map = state.extra as Map<String, dynamic>?;
                    final cubit = map?['cubit'] as PropertiesCubit?;
                    return cubit != null
                        ? BlocProvider.value(value: cubit, child: const CreateLeaseContractPage())
                        : const CreateLeaseContractPage();
                  },
                ),

                GoRoute(
                  path: 'add_resident',
                  name: 'managerAddResident',
                  builder: (_, __) => const ManagerAddResidentPage(),
                ),
              ],
            ),
            GoRoute(
              path: '/manager/finance',
              name: RouteNames.managerFinance,
              builder: (_, __) => const ManagerFinancePage(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'managerFinanceAdd',
                  builder: (_, __) => const ManagerAddExpensePage(),
                ),
                GoRoute(
                  path: 'edit_due_period',
                  name: 'managerEditDuePeriod',
                  builder: (_, state) {
                    final map = state.extra as Map<String, dynamic>;
                    final cubit = map['cubit'] as FinanceCubit;
                    return BlocProvider.value(
                      value: cubit,
                      child: ManagerEditDuePeriodPage(period: map['period'] as dynamic),
                    );
                  },
                ),
                GoRoute(
                  path: 'edit_debt',
                  name: 'managerEditDebt',
                  builder: (_, state) {
                    final map = state.extra as Map<String, dynamic>;
                    final cubit = map['cubit'] as FinanceCubit;
                    return BlocProvider.value(
                      value: cubit,
                      child: ManagerEditDebtPage(debt: map['debt'] as dynamic),
                    );
                  },
                ),
                GoRoute(
                  path: 'edit_transaction',
                  name: 'managerEditTransaction',
                  builder: (_, state) {
                    final map = state.extra as Map<String, dynamic>;
                    final cubit = map['cubit'] as FinanceCubit;
                    Widget page;
                    if (map.containsKey('income')) {
                      page = ManagerEditTransactionPage(income: map['income']);
                    } else {
                      page = ManagerEditTransactionPage(expense: map['expense']);
                    }
                    return BlocProvider.value(value: cubit, child: page);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/manager/services',
              name: 'managerServices',
              builder: (_, __) => const ManagerServicesPage(),
            ),
            GoRoute(
              path: '/manager/announcements',
              name: 'managerAnnouncements',
              builder: (_, __) => const ManagerAnnouncementPage(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'managerCreateAnnouncement',
                  builder: (context, state) {
                    final cubit = state.extra as AnnouncementCubit;
                    return CreateAnnouncementPage(cubit: cubit);
                  },
                ),
                GoRoute(
                  path: 'edit',
                  name: 'managerEditAnnouncement',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    final announcement = extra['announcement'] as Announcement;
                    final cubit = extra['cubit'] as AnnouncementCubit;
                    return CreateAnnouncementPage(
                      cubit: cubit,
                      announcementToEdit: announcement,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/manager/maintenance',
              name: RouteNames.managerMaintenance,
              builder: (_, __) => const ManagerMaintenancePage(),
            ),
            GoRoute(
              path: '/manager/maintenance/:id',
              name: 'managerMaintenanceDetail',
              builder: (_, state) {
                final req = state.extra as MaintenanceRequest;
                return ManagerMaintenanceDetailPage(request: req);
              },
            ),
            GoRoute(
              path: '/manager/more',
              name: RouteNames.managerMore,
              builder: (_, __) => const ManagerMorePage(),
              routes: [
                GoRoute(
                  path: 'documents',
                  name: 'managerDocuments',
                  builder: (_, __) => const ManagerDocumentsPage(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      name: 'managerAddDocument',
                      builder: (context, state) {
                        final cubit = state.extra as DocumentCubit;
                        return ManagerAddDocumentPage(cubit: cubit);
                      },
                    ),
                  ],
                ),
                
GoRoute(path: 'staff', name: 'managerStaff', builder: (_, __) => const ManagerStaffPage(), routes: [
                  GoRoute(
                    path: 'form',
                    name: 'managerStaffForm',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      final staff = extra?['staff'] as StaffMember?;
                      final cubit = extra?['cubit'] as StaffCubit?;
                      
                      Widget page = ManagerStaffFormPage(staff: staff);
                      if (cubit != null) {
                        page = BlocProvider.value(value: cubit, child: page);
                      }
                      return page;
                    },
                  ),
                ]),
                GoRoute(path: 'profile', name: 'managerProfile', builder: (_, __) => const ManagerProfilePage()),
                GoRoute(path: 'settings', name: 'managerSettings', builder: (_, __) => const ManagerSettingsPage()),
              ]
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
              path: '/resident/properties',
              name: 'residentProperties',
              builder: (_, __) => const ResidentPropertiesPage(),
            ),
            GoRoute(
              path: '/resident/finance',
              name: 'residentFinance',
              builder: (_, __) => const ResidentFinancePage(),
            ),
            GoRoute(
              path: '/resident/operations',
              name: 'residentOperations',
              builder: (_, __) => const ResidentOperationsPage(),
            ),
            GoRoute(
              path: '/resident/maintenance/create',
              name: 'residentMaintenanceCreate',
              builder: (_, __) => const CreateMaintenancePage(),
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
              builder: (_, __) => const StaffAssignedPage(),
            ),
            GoRoute(
              path: '/staff/completed',
              name: RouteNames.staffCompleted,
              builder: (_, __) => const StaffCompletedPage(),
            ),
            GoRoute(
              path: '/staff/notifications',
              name: RouteNames.staffNotifications,
              builder: (_, __) => const _PlaceholderPage(title: 'Bildirimler'),
            ),
            GoRoute(
              path: '/staff/profile',
              name: RouteNames.staffProfile,
              builder: (_, __) => const StaffProfilePage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'staffEditProfile',
                  builder: (_, __) => const StaffEditProfilePage(),
                ),
                GoRoute(
                  path: 'settings',
                  name: 'staffSettings',
                  builder: (_, __) => const StaffSettingsPage(),
                ),
              ],
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
    if (location.startsWith('/manager/users')) {
      index = 1;
    } else if (location.startsWith('/manager/properties')) {
      index = 2;
    } else if (location.startsWith('/manager/finance')) {
      index = 3;
    } else if (location.startsWith('/manager/services') || location.startsWith('/manager/maintenance') || location.startsWith('/manager/staff') || location.startsWith('/manager/documents') || location.contains('create_announcement')) {
      index = 4;
    } else if (location.startsWith('/manager/more')) {
      index = 5;
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
              context.go('/manager/users');
              break;
            case 2:
              context.go('/manager/properties');
              break;
            case 3:
              context.go('/manager/finance');
              break;
            case 4:
              context.go('/manager/services');
              break;
            case 5:
              context.go('/manager/more');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Kullanıcılar'),
          NavigationDestination(icon: Icon(Icons.apartment_outlined), selectedIcon: Icon(Icons.apartment), label: 'Yapı & Sakin'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Finans'),
          NavigationDestination(icon: Icon(Icons.dashboard_customize_outlined), selectedIcon: Icon(Icons.dashboard_customize), label: 'Hizmetler'),
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
    if (location.startsWith('/resident/properties')) {
      index = 1;
    } else if (location.startsWith('/resident/finance')) {
      index = 2;
    } else if (location.startsWith('/resident/operations')) {
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
              context.go('/resident/properties');
              break;
            case 2:
              context.go('/resident/finance');
              break;
            case 3:
              context.go('/resident/operations');
              break;
            case 4:
              context.go('/resident/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.apartment_outlined), selectedIcon: Icon(Icons.apartment), label: 'Yapı Sakin'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Finans'),
          NavigationDestination(icon: Icon(Icons.build_outlined), selectedIcon: Icon(Icons.build), label: 'Operasyon'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
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