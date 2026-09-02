def fix():
    path = 'lib/app/router/app_router.dart'
    with open(path, 'r') as f:
        content = f.read()

    find_router = """                    GoRoute(
                      path: 'contracts/create',
                      name: 'managerCreateContract',
                      builder: (_, state) {
                        final map = state.extra as Map<String, dynamic>?;
                        final cubit = map?['cubit'] as PropertiesCubit?;
                        return cubit != null
                            ? BlocProvider.value(value: cubit, child: const CreateLeaseContractPage())
                            : const CreateLeaseContractPage();
                      },
                    ),"""

    replace_router = """                    GoRoute(
                      path: 'contracts/create',
                      name: 'managerCreateContract',
                      builder: (_, state) {
                        final map = state.extra as Map<String, dynamic>?;
                        final cubit = map?['cubit'] as PropertiesCubit?;
                        final unitId = map?['unitId'] as int?;
                        final ownerId = map?['ownerId'] as int?;
                        final tenantId = map?['tenantId'] as int?;
                        
                        final page = CreateLeaseContractPage(
                          preSelectedUnitId: unitId,
                          preSelectedOwnerId: ownerId,
                          preSelectedTenantId: tenantId,
                        );
                        
                        return cubit != null
                            ? BlocProvider.value(value: cubit, child: page)
                            : page;
                      },
                    ),"""

    content = content.replace(find_router, replace_router)

    with open(path, 'w') as f:
        f.write(content)

fix()
