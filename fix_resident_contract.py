def fix_list_page():
    path = 'lib/features/properties/presentation/pages/lease_contract_list_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Constructor
    content = content.replace(
        "const LeaseContractListPage({super.key, this.filteredContracts});",
        "final bool isManager;\n  const LeaseContractListPage({super.key, this.filteredContracts, this.isManager = true});"
    )

    # Empty state button
    btn_find = """                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/manager/properties/contracts/create', extra: {'cubit': context.read<PropertiesCubit>()});
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Kira Sözleşmesi Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),"""
                
    btn_replace = """                if (isManager)
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/manager/properties/contracts/create', extra: {'cubit': context.read<PropertiesCubit>()});
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Kira Sözleşmesi Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),"""
    content = content.replace(btn_find, btn_replace)

    # FAB
    fab_find = """            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  context.push('/manager/properties/contracts/create', extra: {'cubit': context.read<PropertiesCubit>()});
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),"""

    fab_replace = """            if (isManager)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    context.push('/manager/properties/contracts/create', extra: {'cubit': context.read<PropertiesCubit>()});
                  },
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),"""
    content = content.replace(fab_find, fab_replace)

    with open(path, 'w') as f:
        f.write(content)

def fix_resident_page():
    path = 'lib/features/dashboard/presentation/pages/resident_properties_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    content = content.replace(
        "LeaseContractListPage(filteredContracts: filteredContracts)",
        "LeaseContractListPage(filteredContracts: filteredContracts, isManager: false)"
    )

    with open(path, 'w') as f:
        f.write(content)

fix_list_page()
fix_resident_page()
