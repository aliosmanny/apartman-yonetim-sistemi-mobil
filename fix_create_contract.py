def fix():
    path = 'lib/features/properties/presentation/pages/create_lease_contract_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    # 1. Update constructor
    content = content.replace(
        "const CreateLeaseContractPage({super.key});",
        "final int? preSelectedUnitId;\n  final int? preSelectedOwnerId;\n  final int? preSelectedTenantId;\n\n  const CreateLeaseContractPage({super.key, this.preSelectedUnitId, this.preSelectedOwnerId, this.preSelectedTenantId});"
    )
    
    # 2. Update initState to use widget.preSelected
    init_state_find = """  void initState() {
    super.initState();
    final state = context.read<PropertiesCubit>().state;
    if (state is PropertiesLoaded) {
      if (state.units.isEmpty) context.read<PropertiesCubit>().fetchAll();
      
      
    } else {
      context.read<PropertiesCubit>().fetchAll();
      
    }
  }"""
    
    init_state_replace = """  void initState() {
    super.initState();
    _selectedUnitId = widget.preSelectedUnitId;
    _selectedOwnerId = widget.preSelectedOwnerId;
    _selectedTenantId = widget.preSelectedTenantId;
    
    final state = context.read<PropertiesCubit>().state;
    if (state is PropertiesLoaded) {
      if (state.units.isEmpty) context.read<PropertiesCubit>().fetchAll();
    } else {
      context.read<PropertiesCubit>().fetchAll();
    }
  }"""
  
    content = content.replace(init_state_find, init_state_replace)
    
    with open(path, 'w') as f:
        f.write(content)

fix()
