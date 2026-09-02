import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Change "Push Bildirimleri" to "Uygulama Bildirimleri"
    content = content.replace("Push Bildirimleri", "Anlık Bildirimler")

    # Remove "Görünüm Ayarları" and "Dil Ayarları" sections
    # They start at "// ── Görünüm Ayarları ──" and end right before "// ── Hakkında ──"
    pattern = r'// ── Görünüm Ayarları ──.*?const SizedBox\(height: 40\);'
    content = re.sub(pattern, '', content, flags=re.DOTALL)

    # We might have left a trailing SizedBox, let's just make sure it's cleanly removed
    # Check if there is a rogue const SizedBox(height: 24); before // ── Hakkında ──
    content = re.sub(r'const SizedBox\(height: 24\);\s*// ── Hakkında ──', '// ── Hakkında ──', content)

    with open(filepath, 'w') as f:
        f.write(content)

patch_file('lib/features/dashboard/presentation/pages/manager_settings_page.dart')
patch_file('lib/features/dashboard/presentation/pages/staff_settings_page.dart')

