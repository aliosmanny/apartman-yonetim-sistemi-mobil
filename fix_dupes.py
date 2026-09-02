import re

def fix(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Blocks
    content = content.replace("onTap: () => context.push('/manager/properties/block/edit', extra: {'block': item, 'cubit': _cubit}),\n        child: Column(\n        onTap: () => context.push('/manager/properties/block/edit', extra: {'block': item, 'cubit': _cubit}),\n        child: Column(", "onTap: () => context.push('/manager/properties/block/edit', extra: {'block': item, 'cubit': _cubit}),\n        child: Column(")
    
    # Units
    content = content.replace("onTap: () => context.push('/manager/properties/unit/edit', extra: {'unit': item, 'cubit': _cubit}),\n        child: Column(\n        onTap: () => context.push('/manager/properties/unit/edit', extra: {'unit': item, 'cubit': _cubit}),\n        child: Column(", "onTap: () => context.push('/manager/properties/unit/edit', extra: {'unit': item, 'cubit': _cubit}),\n        child: Column(")
    
    # Owners
    content = content.replace("onTap: () => context.push('/manager/properties/owner/edit', extra: {'owner': item, 'cubit': _cubit, 'userCubit': _userCubit}),\n        child: Column(\n        onTap: () => context.push('/manager/properties/owner/edit', extra: {'owner': item, 'cubit': _cubit, 'userCubit': _userCubit}),\n        child: Column(", "onTap: () => context.push('/manager/properties/owner/edit', extra: {'owner': item, 'cubit': _cubit, 'userCubit': _userCubit}),\n        child: Column(")
    
    # Tenants
    content = content.replace("onTap: () => context.push('/manager/properties/tenant/edit', extra: {'tenant': item, 'cubit': _cubit}),\n        child: Column(\n        onTap: () => context.push('/manager/properties/tenant/edit', extra: {'tenant': item, 'cubit': _cubit}),\n        child: Column(", "onTap: () => context.push('/manager/properties/tenant/edit', extra: {'tenant': item, 'cubit': _cubit}),\n        child: Column(")
    
    with open(filepath, 'w') as f:
        f.write(content)

fix('lib/features/dashboard/presentation/pages/manager_properties_page.dart')
