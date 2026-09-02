import re

def fix():
    path = 'lib/app/theme/app_theme.dart'
    with open(path, 'r') as f:
        content = f.read()

    # The broken block:
    #       cardTheme: CardThemeData(
    #         color: AppColors.cardBackground,
    #         elevation: 12,
    #         shadowColor: const Color(0xFF0F172A).withOpacity(0.06),
    #         shape: RoundedRectangleBorder(
    #           borderRadius: BorderRadius.circular(24),
    #           side: BorderSide.none,
    #         ),
    #         margin: EdgeInsets.zero,
    #       ),
    #         shape: RoundedRectangleBorder(
    #           borderRadius: BorderRadius.circular(20),
    #           side: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1),
    #         ),
    #         margin: EdgeInsets.zero,
    #       ),
    broken_str = """      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 12,
        shadowColor: const Color(0xFF0F172A).withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),"""
      
    fixed_str = """      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 12,
        shadowColor: const Color(0xFF0F172A).withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),"""
      
    content = content.replace(broken_str, fixed_str)
    
    # Also I messed up inputs borderRadius:
    # content = content.replace('borderRadius: BorderRadius.circular(12)', 'borderRadius: BorderRadius.circular(16)')
    # This might have replaced too many things (like dialogTheme borderRadius, inputDecorationTheme, etc). Let's see if there are other syntax errors.
    
    with open(path, 'w') as f:
        f.write(content)

fix()
