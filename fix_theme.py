def fix(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Remove shadowColor from FAB theme
    content = content.replace("shadowColor: AppColors.primary.withOpacity(0.4),\n        ", "")
    
    with open(filepath, 'w') as f:
        f.write(content)

fix('lib/app/theme/app_theme.dart')
