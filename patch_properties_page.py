import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Change _buildCard signature
    old_build_card = """  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }"""
    
    new_build_card = """  Widget _buildCard({required Widget child, VoidCallback? onTap}) {
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
    content = content.replace(old_build_card, new_build_card)

    def replacer(match):
        method_name = match.group(1)
        
        route_map = {
            '_buildApartments': "context.push('/manager/properties/apartment/edit', extra: {'apartment': item, 'cubit': _cubit})",
            '_buildBlocks': "context.push('/manager/properties/block/edit', extra: {'block': item, 'cubit': _cubit})",
            '_buildUnits': "context.push('/manager/properties/unit/edit', extra: {'unit': item, 'cubit': _cubit})",
            '_buildOwners': "context.push('/manager/properties/owner/edit', extra: {'owner': item, 'cubit': _cubit, 'userCubit': _userCubit})",
            '_buildTenants': "context.push('/manager/properties/tenant/edit', extra: {'tenant': item, 'cubit': _cubit})"
        }
        
        onTapCode = route_map.get(method_name, "")
        
        if onTapCode:
            return f"Widget {method_name}{match.group(2)}      builder: (item) => _buildCard(\n        onTap: () => {onTapCode},\n        child: Column("
        else:
            return match.group(0)

    pattern = r'Widget (_build[A-Za-z]+)(.*?      builder: \(item\) => _buildCard\(\n        child: Column\()'
    content = re.sub(pattern, replacer, content, flags=re.DOTALL)

    with open(filepath, 'w') as f:
        f.write(content)
    print("Patched!")

patch_file('lib/features/dashboard/presentation/pages/manager_properties_page.dart')
