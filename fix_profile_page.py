import re

def fix():
    path = 'lib/features/profile/presentation/pages/profile_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    tile_find = """                        _buildActionTile(
                          context,
                          icon: Icons.help_rounded,
                          title: 'Yardım ve Destek',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Destek sayfası yapım aşamasında.')),
                            );
                          },
                        ),"""
                        
    content = content.replace(tile_find, "")

    with open(path, 'w') as f:
        f.write(content)

fix()
