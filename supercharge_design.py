import re

def update_colors():
    path = 'lib/app/theme/app_colors.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Premium Indigo/Blurple theme
    content = content.replace('Color(0xFF2563EB)', 'Color(0xFF4F46E5)') # Primary (Indigo 600)
    content = content.replace('Color(0xFF60A5FA)', 'Color(0xFF818CF8)') # Primary Light
    content = content.replace('Color(0xFF1D4ED8)', 'Color(0xFF3730A3)') # Primary Dark
    
    # Warmer/Softer background
    content = content.replace('Color(0xFFF9FAFB)', 'Color(0xFFF4F6F8)') # Slightly more contrast for cards to pop
    
    with open(path, 'w') as f:
        f.write(content)

def update_theme():
    path = 'lib/app/theme/app_theme.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Cards: ultra soft shadow, 24px radius, no border
    content = re.sub(
        r'cardTheme: CardThemeData\(.*?\),',
        """cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 12,
        shadowColor: const Color(0xFF0F172A).withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),""",
        content,
        flags=re.DOTALL
    )

    # AppBar: transparent, left aligned, larger font
    content = re.sub(
        r'appBarTheme: const AppBarTheme\(.*?\),',
        """appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 28),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.8,
        ),
      ),""",
        content,
        flags=re.DOTALL
    )
    
    # FAB: Pill shape (fully rounded)
    content = re.sub(
        r'floatingActionButtonTheme: FloatingActionButtonThemeData\(.*?\),',
        """floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),""",
        content,
        flags=re.DOTALL
    )

    # Inputs: softer, 16px radius
    content = content.replace('borderRadius: BorderRadius.circular(12)', 'borderRadius: BorderRadius.circular(16)')

    with open(path, 'w') as f:
        f.write(content)

update_colors()
update_theme()
print("Supercharged design!")
