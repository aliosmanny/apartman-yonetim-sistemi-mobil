import re

def fix():
    path = 'lib/app/router/app_router.dart'
    with open(path, 'r') as f:
        content = f.read()

    # 1. Add import
    import_statement = "import '../../features/profile/presentation/pages/change_password_page.dart';"
    new_import = "import '../../features/profile/presentation/pages/change_password_page.dart';\nimport '../../features/profile/presentation/pages/notification_settings_page.dart';"
    content = content.replace(import_statement, new_import)

    # 2. Add route
    route_find = """                    GoRoute(
                      path: 'change-password',
                      name: 'residentChangePassword',
                      builder: (_, __) => const ChangePasswordPage(),
                    ),"""
                    
    route_replace = """                    GoRoute(
                      path: 'change-password',
                      name: 'residentChangePassword',
                      builder: (_, __) => const ChangePasswordPage(),
                    ),
                    GoRoute(
                      path: 'notifications',
                      name: 'residentNotifications',
                      builder: (_, __) => const NotificationSettingsPage(),
                    ),"""
    content = content.replace(route_find, route_replace)

    with open(path, 'w') as f:
        f.write(content)

fix()
