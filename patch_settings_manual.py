import re

def patch(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    start_str = "// ── Görünüm Ayarları ──"
    end_str = "// ── Hakkında ──"
    
    if start_str in content and end_str in content:
        start_idx = content.find(start_str)
        end_idx = content.find(end_str)
        
        new_content = content[:start_idx] + content[end_idx:]
        with open(filepath, 'w') as f:
            f.write(new_content)
            print(f"Patched {filepath}")

patch('lib/features/dashboard/presentation/pages/manager_settings_page.dart')
patch('lib/features/dashboard/presentation/pages/staff_settings_page.dart')
