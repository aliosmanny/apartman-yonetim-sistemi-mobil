import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../properties/domain/models/models.dart';
import '../../../properties/presentation/controllers/properties_cubit.dart';
import '../../../properties/presentation/controllers/properties_state.dart';
import '../../../properties/presentation/pages/lease_contract_list_page.dart';

class ManagerPropertiesPage extends StatefulWidget {
  const ManagerPropertiesPage({super.key});

  @override
  State<ManagerPropertiesPage> createState() => _ManagerPropertiesPageState();
}

class _ManagerPropertiesPageState extends State<ManagerPropertiesPage> with SingleTickerProviderStateMixin {
  late final PropertiesCubit _cubit;
  late final TabController _tabController;

  // Apartman Filtreleri (Tab 0)
  String _selectedApartmentCity = 'all';
  String _selectedApartmentDistrict = 'all';

  // Blok Filtreleri (Tab 1)
  String _selectedBlockApartment = 'all';

  // Daire Filtreleri (Tab 2)
  String _selectedUnitUsage = 'all';
  String _selectedUnitApartment = 'all';
  String _selectedUnitBlock = 'all';

  // Kat Malikleri Filtreleri (Tab 3)
  String _selectedOwnerApartment = 'all';

  // Kiracılar Filtreleri (Tab 4)
  String _selectedTenantApartment = 'all';

  // Sözleşmeler Filtreleri (Tab 5)
  String _selectedContractStatus = 'all';

  @override
  void initState() {
    super.initState();
    _cubit = sl<PropertiesCubit>()..fetchAll();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cubit.close();
    super.dispose();
  }

  List<Map<String, String>> _toOptions(Iterable<String> list) {
    return list.map((e) => {'value': e, 'label': e == 'all' ? 'Tümü' : e}).toList();
  }

  Widget _buildListCard({
    required List<Map<String, String>> items,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, idx) {
          final item = items[idx];
          final isSelected = selectedValue == item['value'];
          return ListTile(
            dense: true,
            title: Text(
              item['label']!,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected 
                ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                : null,
            onTap: () => onChanged(item['value']!),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, PropertiesLoaded state) {
    final index = _tabController.index;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Geçici durum değişkenleri
        String tempAptCity = _selectedApartmentCity;
        String tempAptDistrict = _selectedApartmentDistrict;
        String tempBlockApt = _selectedBlockApartment;
        String tempUnitUsage = _selectedUnitUsage;
        String tempUnitApt = _selectedUnitApartment;
        String tempUnitBlock = _selectedUnitBlock;
        String tempOwnerApt = _selectedOwnerApartment;
        String tempTenantApt = _selectedTenantApartment;
        String tempContractStatus = _selectedContractStatus;

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            int count = 0;
            Widget filterContent = const SizedBox();

            if (index == 0) {
              // APARTMANLAR
              final cities = ['all', ...state.apartments.map((a) => a.province).toSet()];
              final districts = ['all', ...state.apartments.map((a) => a.district).toSet()];
              count = state.apartments.where((a) {
                final matchesCity = tempAptCity == 'all' || a.province == tempAptCity;
                final matchesDistrict = tempAptDistrict == 'all' || a.district == tempAptDistrict;
                return matchesCity && matchesDistrict;
              }).length;

              filterContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('İl süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(cities),
                    selectedValue: tempAptCity,
                    onChanged: (val) => setBottomSheetState(() => tempAptCity = val),
                  ),
                  const SizedBox(height: 24),
                  Text('İlçe süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(districts),
                    selectedValue: tempAptDistrict,
                    onChanged: (val) => setBottomSheetState(() => tempAptDistrict = val),
                  ),
                ],
              );
            } else if (index == 1) {
              // BLOKLAR
              final apartments = ['all', ...state.blocks.map((b) => b.apartmentName).toSet()];
              count = state.blocks.where((b) {
                return tempBlockApt == 'all' || b.apartmentName == tempBlockApt;
              }).length;

              filterContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apartman / Site süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(apartments),
                    selectedValue: tempBlockApt,
                    onChanged: (val) => setBottomSheetState(() => tempBlockApt = val),
                  ),
                ],
              );
            } else if (index == 2) {
              // DAİRELER
              final usages = const [
                {'value': 'all', 'label': 'Tümü'},
                {'value': 'empty', 'label': 'Boş'},
                {'value': 'owner_occupied', 'label': 'Malik Oturuyor'},
                {'value': 'rented', 'label': 'Kirada'},
              ];
              final apartments = ['all', ...state.units.map((u) => u.apartmentName).toSet()];
              final blocks = ['all', ...state.units.map((u) => '${u.apartmentName} - ${u.blockName}').toSet()];

              count = state.units.where((u) {
                final matchesUsage = tempUnitUsage == 'all' || u.usageStatus == tempUnitUsage;
                final matchesApt = tempUnitApt == 'all' || u.apartmentName == tempUnitApt;
                final matchesBlock = tempUnitBlock == 'all' || '${u.apartmentName} - ${u.blockName}' == tempUnitBlock;
                return matchesUsage && matchesApt && matchesBlock;
              }).length;

              filterContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kullanım Durumu süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: usages,
                    selectedValue: tempUnitUsage,
                    onChanged: (val) => setBottomSheetState(() => tempUnitUsage = val),
                  ),
                  const SizedBox(height: 24),
                  Text('Apartman / Site süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(apartments),
                    selectedValue: tempUnitApt,
                    onChanged: (val) => setBottomSheetState(() => tempUnitApt = val),
                  ),
                  const SizedBox(height: 24),
                  Text('Blok süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(blocks),
                    selectedValue: tempUnitBlock,
                    onChanged: (val) => setBottomSheetState(() => tempUnitBlock = val),
                  ),
                ],
              );
            } else if (index == 3) {
              // KAT MALİKLERİ
              final apartments = ['all', ...state.owners.map((o) => o.apartmentName).whereType<String>().toSet()];
              count = state.owners.where((o) {
                return tempOwnerApt == 'all' || o.apartmentName == tempOwnerApt;
              }).length;

              filterContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apartman / Site süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(apartments),
                    selectedValue: tempOwnerApt,
                    onChanged: (val) => setBottomSheetState(() => tempOwnerApt = val),
                  ),
                ],
              );
            } else if (index == 4) {
              // KİRACILAR
              final apartments = ['all', ...state.tenants.map((t) => t.apartmentName).whereType<String>().toSet()];
              count = state.tenants.where((t) {
                return tempTenantApt == 'all' || t.apartmentName == tempTenantApt;
              }).length;

              filterContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apartman / Site süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(apartments),
                    selectedValue: tempTenantApt,
                    onChanged: (val) => setBottomSheetState(() => tempTenantApt = val),
                  ),
                ],
              );
            } else if (index == 5) {
              // KİRA SÖZLEŞMELERİ
              final statuses = const [
                {'value': 'all', 'label': 'Tümü'},
                {'value': 'active', 'label': 'Aktif'},
                {'value': 'expired', 'label': 'Süresi Doldu'},
              ];

              count = state.contracts.where((c) {
                return tempContractStatus == 'all' || c.status == tempContractStatus;
              }).length;

              filterContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sözleşme Durumu süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: statuses,
                    selectedValue: tempContractStatus,
                    onChanged: (val) => setBottomSheetState(() => tempContractStatus = val),
                  ),
                ],
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filtrele', style: AppTextStyles.headlineSmall),
                        TextButton(
                          onPressed: () {
                            setBottomSheetState(() {
                              if (index == 0) {
                                tempAptCity = 'all';
                                tempAptDistrict = 'all';
                              } else if (index == 1) {
                                tempBlockApt = 'all';
                              } else if (index == 2) {
                                tempUnitUsage = 'all';
                                tempUnitApt = 'all';
                                tempUnitBlock = 'all';
                              } else if (index == 3) {
                                tempOwnerApt = 'all';
                              } else if (index == 4) {
                                tempTenantApt = 'all';
                              } else if (index == 5) {
                                tempContractStatus = 'all';
                              }
                            });
                          },
                          child: const Text('Temizle', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        filterContent,
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (index == 0) {
                              _selectedApartmentCity = tempAptCity;
                              _selectedApartmentDistrict = tempAptDistrict;
                            } else if (index == 1) {
                              _selectedBlockApartment = tempBlockApt;
                            } else if (index == 2) {
                              _selectedUnitUsage = tempUnitUsage;
                              _selectedUnitApartment = tempUnitApt;
                              _selectedUnitBlock = tempUnitBlock;
                            } else if (index == 3) {
                              _selectedOwnerApartment = tempOwnerApt;
                            } else if (index == 4) {
                              _selectedTenantApartment = tempTenantApt;
                            } else if (index == 5) {
                              _selectedContractStatus = tempContractStatus;
                            }
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Sayıları göster ($count)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Yapı & Sakin Yönetimi'),
          centerTitle: true,
          actions: [
            BlocBuilder<PropertiesCubit, PropertiesState>(
              builder: (context, state) {
                if (state is! PropertiesLoaded) return const SizedBox();
                final index = _tabController.index;
                if (index > 5) return const SizedBox();

                bool hasFilter = false;
                if (index == 0) hasFilter = _selectedApartmentCity != 'all' || _selectedApartmentDistrict != 'all';
                if (index == 1) hasFilter = _selectedBlockApartment != 'all';
                if (index == 2) hasFilter = _selectedUnitUsage != 'all' || _selectedUnitApartment != 'all' || _selectedUnitBlock != 'all';
                if (index == 3) hasFilter = _selectedOwnerApartment != 'all';
                if (index == 4) hasFilter = _selectedTenantApartment != 'all';
                if (index == 5) hasFilter = _selectedContractStatus != 'all';

                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    onPressed: () => _showFilterBottomSheet(context, state),
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: hasFilter ? AppColors.primary : AppColors.textSecondary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: hasFilter ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Apartmanlar'),
              Tab(text: 'Bloklar'),
              Tab(text: 'Daireler'),
              Tab(text: 'Kat Malikleri'),
              Tab(text: 'Kiracılar'),
              Tab(text: 'Sözleşmeler'),
            ],
          ),
        ),
        body: BlocBuilder<PropertiesCubit, PropertiesState>(
          builder: (context, state) {
            if (state is PropertiesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PropertiesError) {
              return Center(child: Text('Hata: ${state.message}'));
            } else if (state is PropertiesLoaded) {
              final filteredApartments = state.apartments.where((a) {
                final matchesCity = _selectedApartmentCity == 'all' || a.province == _selectedApartmentCity;
                final matchesDistrict = _selectedApartmentDistrict == 'all' || a.district == _selectedApartmentDistrict;
                return matchesCity && matchesDistrict;
              }).toList();

              final filteredBlocks = state.blocks.where((b) {
                return _selectedBlockApartment == 'all' || b.apartmentName == _selectedBlockApartment;
              }).toList();

              final filteredUnits = state.units.where((u) {
                final matchesUsage = _selectedUnitUsage == 'all' || u.usageStatus == _selectedUnitUsage;
                final matchesApt = _selectedUnitApartment == 'all' || u.apartmentName == _selectedUnitApartment;
                final matchesBlock = _selectedUnitBlock == 'all' || '${u.apartmentName} - ${u.blockName}' == _selectedUnitBlock;
                return matchesUsage && matchesApt && matchesBlock;
              }).toList();

              final filteredOwners = state.owners.where((o) {
                return _selectedOwnerApartment == 'all' || o.apartmentName == _selectedOwnerApartment;
              }).toList();

              final filteredTenants = state.tenants.where((t) {
                return _selectedTenantApartment == 'all' || t.apartmentName == _selectedTenantApartment;
              }).toList();

              final filteredContracts = state.contracts.where((c) {
                return _selectedContractStatus == 'all' || c.status == _selectedContractStatus;
              }).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildApartments(filteredApartments),
                  _buildBlocks(filteredBlocks),
                  _buildUnits(filteredUnits),
                  _buildOwners(filteredOwners),
                  _buildTenants(filteredTenants),
                  LeaseContractListPage(filteredContracts: filteredContracts),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildList<T>({
    required List<T> items,
    required String emptyMsg,
    required Widget Function(T) builder,
  }) {
    if (items.isEmpty) return Center(child: Text(emptyMsg));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => builder(items[index]),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildActionButtons(BuildContext context, String type, int id, dynamic item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () {
            if (type == 'apartment') context.push('/manager/properties/apartment/edit', extra: {'apartment': item, 'cubit': _cubit});
            if (type == 'block') context.push('/manager/properties/block/edit', extra: {'block': item, 'cubit': _cubit});
            if (type == 'unit') context.push('/manager/properties/unit/edit', extra: {'unit': item, 'cubit': _cubit});
            if (type == 'owner') context.push('/manager/properties/owner/edit', extra: {'owner': item, 'cubit': _cubit});
            if (type == 'tenant') context.push('/manager/properties/tenant/edit', extra: {'tenant': item, 'cubit': _cubit});
          },
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Düzenle'),
        ),
        TextButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Silme Onayı'),
                content: const Text('Bu kaydı silmek istediğinize emin misiniz?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (type == 'apartment') _cubit.deleteApartment(id);
                      if (type == 'block') _cubit.deleteBlock(id);
                      if (type == 'unit') _cubit.deleteUnit(id);
                      if (type == 'owner') _cubit.deleteOwner(id);
                      if (type == 'tenant') _cubit.deleteTenant(id);
                    },
                    child: const Text('Sil', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.delete, size: 16, color: Colors.red),
          label: const Text('Sil', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildApartments(List<AppApartment> list) {
    return _buildList<AppApartment>(
      items: list,
      emptyMsg: 'Apartman bulunamadı.',
      builder: (item) => _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Konum: ${item.province} / ${item.district}', style: AppTextStyles.bodyMedium),
            Text('Yönetici: ${item.managerName ?? "-"}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Blok: ${item.totalBlocks}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                Text('Daire: ${item.totalUnits}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const Divider(height: 24),
            _buildActionButtons(context, 'apartment', item.id, item),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocks(List<AppBlock> list) {
    return _buildList<AppBlock>(
      items: list,
      emptyMsg: 'Blok bulunamadı.',
      builder: (item) => _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.apartmentName} - ${item.name}', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kat Sayısı: ${item.floorCount}', style: AppTextStyles.bodyMedium),
                Text('Daire Sayısı: ${item.unitCount}', style: AppTextStyles.bodyMedium),
              ],
            ),
            const Divider(height: 24),
            _buildActionButtons(context, 'block', item.id, item),
          ],
        ),
      ),
    );
  }

  Widget _buildUnits(List<AppUnit> list) {
    return _buildList<AppUnit>(
      items: list,
      emptyMsg: 'Daire bulunamadı.',
      builder: (item) => _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daire ${item.number}', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.usageStatus == 'empty' ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.usageStatusDisplay,
                    style: TextStyle(color: item.usageStatus == 'empty' ? AppColors.error : AppColors.success, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${item.apartmentName} - ${item.blockName}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            Text('Kat: ${item.floor}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            if (item.currentOwner != null) Text('Kat Maliki: ${item.currentOwner!["name"]}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
            if (item.currentTenant != null) Text('Kiracı: ${item.currentTenant!["name"]}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning)),
            const Divider(height: 24),
            _buildActionButtons(context, 'unit', item.id, item),
          ],
        ),
      ),
    );
  }

  Widget _buildOwners(List<AppOwner> list) {
    return _buildList<AppOwner>(
      items: list,
      emptyMsg: 'Kat maliki bulunamadı.',
      builder: (item) => _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.userName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(item.userPhone, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Text(item.unitDisplay, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
            const Divider(height: 24),
            _buildActionButtons(context, 'owner', item.id, item),
          ],
        ),
      ),
    );
  }

  Widget _buildTenants(List<AppTenant> list) {
    return _buildList<AppTenant>(
      items: list,
      emptyMsg: 'Kiracı bulunamadı.',
      builder: (item) => _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.userName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(item.userPhone, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Text(item.unitDisplay, style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning)),
            const Divider(height: 24),
            _buildActionButtons(context, 'tenant', item.id, item),
          ],
        ),
      ),
    );
  }
}
