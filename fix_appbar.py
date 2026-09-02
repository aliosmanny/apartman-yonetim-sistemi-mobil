import re
def fix():
    path = 'lib/app/theme/app_theme.dart'
    with open(path, 'r') as f:
        content = f.read()

    # AppBar: transparent, left aligned, larger font
    content = re.sub(
        r'appBarTheme: AppBarTheme\(.*?\),',
        """appBarTheme: const AppBarTheme(
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
      ),""",
        content,
        flags=re.DOTALL
    )

    with open(path, 'w') as f:
        f.write(content)
fix()
