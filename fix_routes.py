import re

def fix():
    path = 'lib/features/dashboard/presentation/pages/manager_dashboard_page.dart'
    with open(path, 'r') as f:
        content = f.read()
        
    find_str = """                          _buildActionBtn(context, Icons.campaign_rounded, 'Duyuru\\nYayınla', AppColors.primary, '/manager/more'),
                          _buildActionBtn(context, Icons.receipt_long_rounded, 'Gider\\nEkle', AppColors.warning, '/manager/finance'),
                          _buildActionBtn(context, Icons.person_add_rounded, 'Sakin\\nEkle', AppColors.secondary, '/manager/properties'),"""
                          
    replace_str = """                          _buildActionBtn(context, Icons.campaign_rounded, 'Duyuru\\nYayınla', AppColors.primary, '/manager/announcements'),
                          _buildActionBtn(context, Icons.receipt_long_rounded, 'Gider\\nEkle', AppColors.warning, '/manager/finance'),
                          _buildActionBtn(context, Icons.person_add_rounded, 'Sakin\\nEkle', AppColors.secondary, '/manager/users'),"""
                          
    content = content.replace(find_str, replace_str)
    
    with open(path, 'w') as f:
        f.write(content)

fix()
