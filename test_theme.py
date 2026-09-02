import re

def fix():
    path = 'lib/app/theme/app_theme.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Let's insert pageTransitionsTheme to make it snappy
    theme_part = """      // Snappy and fast page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
"""
    
    # We will use ZoomPageTransitionsBuilder? No, FadeUpwards is faster perceived. Or we can just disable transition completely using a custom builder.
