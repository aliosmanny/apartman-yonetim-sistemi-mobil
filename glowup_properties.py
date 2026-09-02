import re

def fix():
    path = 'lib/features/dashboard/presentation/pages/manager_properties_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    broken = """  Widget _buildCard({required Widget child, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }"""
  
    fixed = """  Widget _buildCard({required Widget child, VoidCallback? onTap}) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }"""
  
    content = content.replace(broken, fixed)
    
    with open(path, 'w') as f:
        f.write(content)

fix()
