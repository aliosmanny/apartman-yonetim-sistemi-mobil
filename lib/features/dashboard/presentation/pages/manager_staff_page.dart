import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../staff/presentation/controllers/staff_cubit.dart';
import '../../../staff/domain/models/staff_member.dart';

class ManagerStaffPage extends StatelessWidget {
  const ManagerStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ManagerStaffPageView();
  }
}

class _ManagerStaffPageView extends StatefulWidget {
  const _ManagerStaffPageView();

  @override
  State<_ManagerStaffPageView> createState() => _ManagerStaffPageViewState();
}

class _ManagerStaffPageViewState extends State<_ManagerStaffPageView> {
  String _selectedDuty = 'all';
  String _selectedIsActive = 'all';
  String _selectedApartment = 'all';

  void _addStaff() async {
    context.pushNamed('managerStaffForm', extra: {'cubit': context.read<StaffCubit>()});
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

  Widget _buildSegmentBtn({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, StaffLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempDuty = _selectedDuty;
        String tempIsActive = _selectedIsActive;
        String tempApt = _selectedApartment;

        final duties = ['all', ...state.staffList.map((s) => s.roleDisplay).toSet()];
        final apartments = ['all', ...state.staffList.map((s) => s.apartmentName).toSet()];

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final count = state.staffList.where((s) {
              final matchesDuty = tempDuty == 'all' || s.roleDisplay == tempDuty;
              final matchesActive = tempIsActive == 'all' ||
                  (tempIsActive == 'yes' && s.isActive) ||
                  (tempIsActive == 'no' && !s.isActive);
              final matchesApt = tempApt == 'all' || s.apartmentName == tempApt;
              return matchesDuty && matchesActive && matchesApt;
            }).length;

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
                              tempDuty = 'all';
                              tempIsActive = 'all';
                              tempApt = 'all';
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
                        Text('Görev süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildListCard(
                          items: _toOptions(duties),
                          selectedValue: tempDuty,
                          onChanged: (val) => setBottomSheetState(() => tempDuty = val),
                        ),
                        const SizedBox(height: 24),
                        Text('Aktif süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSegmentBtn(
                              label: 'Tümü', 
                              isSelected: tempIsActive == 'all',
                              onTap: () => setBottomSheetState(() => tempIsActive = 'all'),
                            ),
                            const SizedBox(width: 8),
                            _buildSegmentBtn(
                              label: 'Evet', 
                              isSelected: tempIsActive == 'yes',
                              onTap: () => setBottomSheetState(() => tempIsActive = 'yes'),
                            ),
                            const SizedBox(width: 8),
                            _buildSegmentBtn(
                              label: 'Hayır', 
                              isSelected: tempIsActive == 'no',
                              onTap: () => setBottomSheetState(() => tempIsActive = 'no'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Apartman / Site süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildListCard(
                          items: _toOptions(apartments),
                          selectedValue: tempApt,
                          onChanged: (val) => setBottomSheetState(() => tempApt = val),
                        ),
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
                            _selectedDuty = tempDuty;
                            _selectedIsActive = tempIsActive;
                            _selectedApartment = tempApt;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personeller'),
        centerTitle: true,
        actions: [
          BlocBuilder<StaffCubit, StaffState>(
            builder: (context, state) {
              if (state is! StaffLoaded) return const SizedBox();
              final hasFilter = _selectedDuty != 'all' || _selectedIsActive != 'all' || _selectedApartment != 'all';
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
      ),
      body: BlocBuilder<StaffCubit, StaffState>(
        builder: (context, state) {
          if (state is StaffLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StaffError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hata: ${state.message}', style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<StaffCubit>().fetchStaff(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          } else if (state is StaffLoaded) {
            final filteredList = state.staffList.where((s) {
              final matchesDuty = _selectedDuty == 'all' || s.roleDisplay == _selectedDuty;
              final matchesActive = _selectedIsActive == 'all' ||
                  (_selectedIsActive == 'yes' && s.isActive) ||
                  (_selectedIsActive == 'no' && !s.isActive);
              final matchesApt = _selectedApartment == 'all' || s.apartmentName == _selectedApartment;
              return matchesDuty && matchesActive && matchesApt;
            }).toList();

            if (filteredList.isEmpty) {
              return const Center(child: Text('Kayıtlı personel bulunamadı.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: filteredList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ManagerStaffCard(staff: filteredList[index]);
              },
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStaff,
        backgroundColor: AppColors.primary,
        /* using global shape */
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ManagerStaffCard extends StatelessWidget {
  final StaffMember staff;

  const _ManagerStaffCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    final bool isActive = staff.isActive;

    return Card(
      child: InkWell(
        onTap: () {
          context.pushNamed('managerStaffForm', extra: {
            'staff': staff,
            'cubit': context.read<StaffCubit>(),
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: isActive ? AppColors.primary.withValues(alpha: 0.12) : AppColors.textTertiary.withValues(alpha: 0.2),
              child: Text(
                staff.userName.isNotEmpty ? staff.userName.substring(0, 1) : 'P',
                style: AppTextStyles.titleLarge.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            title: Text(
              '${staff.userName} (${staff.userPhone})',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.apartmentName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(staff.roleDisplay, style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: (isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          isActive ? 'Aktif' : 'Pasif',
                          style: TextStyle(fontSize: 10, color: isActive ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ),
        ),
      ),
    );
  }
}
