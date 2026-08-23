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

class _ManagerPropertiesPageState extends State<ManagerPropertiesPage> {
  late final PropertiesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<PropertiesCubit>()..fetchAll();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: DefaultTabController(
        length: 6,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Yapı & Sakin Yönetimi'),
            centerTitle: true,
            bottom: const TabBar(
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
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
                return TabBarView(
                  children: [
                    _buildApartments(state.apartments),
                    _buildBlocks(state.blocks),
                    _buildUnits(state.units),
                    _buildOwners(state.owners),
                    _buildTenants(state.tenants),
                    const LeaseContractListPage(),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
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
