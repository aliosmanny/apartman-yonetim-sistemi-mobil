import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Split by "Widget _build"
    parts = content.split("Widget _build")
    for i in range(1, len(parts)):
        part = parts[i]
        
        route = ""
        if part.startswith("Apartments"):
            route = "context.push('/manager/properties/apartment/edit', extra: {'apartment': item, 'cubit': _cubit})"
        elif part.startswith("Blocks"):
            route = "context.push('/manager/properties/block/edit', extra: {'block': item, 'cubit': _cubit})"
        elif part.startswith("Units"):
            route = "context.push('/manager/properties/unit/edit', extra: {'unit': item, 'cubit': _cubit})"
        elif part.startswith("Owners"):
            route = "context.push('/manager/properties/owner/edit', extra: {'owner': item, 'cubit': _cubit, 'userCubit': _userCubit})"
        elif part.startswith("Tenants"):
            route = "context.push('/manager/properties/tenant/edit', extra: {'tenant': item, 'cubit': _cubit})"
        
        if route:
            parts[i] = part.replace(
                "builder: (item) => _buildCard(\n        child: Column(",
                f"builder: (item) => _buildCard(\n        onTap: () => {route},\n        child: Column("
            )
    
    with open(filepath, 'w') as f:
        f.write("Widget _build".join(parts))
    print("Patched 2!")

patch_file('lib/features/dashboard/presentation/pages/manager_properties_page.dart')
