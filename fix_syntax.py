def fix():
    path = 'lib/app/theme/app_theme.dart'
    with open(path, 'r') as f:
        content = f.read()

    # The broken part looks like this now:
    '''      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 28),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.8,
        ),
      ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),'''
    
    import re
    broken_pattern = re.compile(
        r"appBarTheme: const AppBarTheme\([^)]*\)\s*,\s*\),\s*systemOverlayStyle: const SystemUiOverlayStyle\([\s\S]*?\),\s*\),",
        re.MULTILINE
    )
    
    # Just replace it based on specific string
    start_str = "appBarTheme: const AppBarTheme("
    end_str = "        ),\n      ),"
    
    # Let me just write a very clean replacement script
    content = content.replace('''      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 28),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.8,
        ),
      ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),''', '''      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 28),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.8,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),''')
    
    with open(path, 'w') as f:
        f.write(content)
fix()
