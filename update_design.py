import re

def update_colors():
    path = 'lib/app/theme/app_colors.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Update primary to a more vibrant modern blue (Tailwind Blue 600)
    content = content.replace('Color(0xFF1E40AF)', 'Color(0xFF2563EB)')
    content = content.replace('Color(0xFF3B82F6)', 'Color(0xFF60A5FA)')
    content = content.replace('Color(0xFF1E3A8A)', 'Color(0xFF1D4ED8)')
    
    # Update background to be very slightly warmer/cleaner
    content = content.replace('Color(0xFFF8FAFC)', 'Color(0xFFF9FAFB)') # Gray 50
    
    with open(path, 'w') as f:
        f.write(content)

def update_theme():
    path = 'lib/app/theme/app_theme.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Add AppBarTheme
    appbar_theme = """
      // ── AppBar ─────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),

      // ── BottomNavigationBar ──────────────────────"""
    
    content = content.replace('      // ── BottomNavigationBar ──────────────────────', appbar_theme)
    
    # Update CardTheme to have a subtle shadow instead of a hard border
    old_card = """      // ── Card ─────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),"""
      
    new_card = """      // ── Card ─────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),"""
      
    content = content.replace(old_card, new_card)

    # Update FAB to be rounded rect instead of circle
    old_fab = """      // ── FloatingActionButton ─────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),"""
      
    new_fab = """      // ── FloatingActionButton ─────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 6,
        shadowColor: AppColors.primary.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),"""
      
    content = content.replace(old_fab, new_fab)
    
    # Update ElevatedButton
    old_elevated = """      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),"""
      
    new_elevated = """      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.buttonLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),"""
      
    content = content.replace(old_elevated, new_elevated)

    with open(path, 'w') as f:
        f.write(content)

update_colors()
update_theme()
print("Design updated!")
