import re

def fix():
    path = 'lib/features/dashboard/presentation/pages/manager_properties_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Find the Düzenle button to insert our new Sözleşme button right before it
    button_to_find = """        TextButton.icon(
          onPressed: () {
            if (type == 'apartment') context.push('/manager/properties/apartment/edit', extra: {'apartment': item, 'cubit': _cubit});
            if (type == 'block') context.push('/manager/properties/block/edit', extra: {'block': item, 'cubit': _cubit});
            if (type == 'unit') context.push('/manager/properties/unit/edit', extra: {'unit': item, 'cubit': _cubit});
            if (type == 'owner') context.push('/manager/properties/owner/edit', extra: {'owner': item, 'cubit': _cubit, 'userCubit': _userCubit});
            if (type == 'tenant') context.push('/manager/properties/tenant/edit', extra: {'tenant': item, 'cubit': _cubit});
          },
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Düzenle'),
        ),"""

    new_button = """        if (type == 'owner' || type == 'tenant')
          TextButton.icon(
            onPressed: () {
              int? ownerId = type == 'owner' ? item.userId : null;
              int? tenantId = type == 'tenant' ? item.userId : null;
              int? unitId = item.unitId;
              
              context.push('/manager/properties/contracts/create', extra: {
                'cubit': _cubit,
                'unitId': unitId,
                'ownerId': ownerId,
                'tenantId': tenantId,
              });
            },
            icon: const Icon(Icons.description, size: 16),
            label: const Text('Sözleşme'),
          ),
""" + button_to_find

    content = content.replace(button_to_find, new_button)
    
    with open(path, 'w') as f:
        f.write(content)

fix()
