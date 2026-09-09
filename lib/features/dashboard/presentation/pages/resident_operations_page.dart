import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../announcements/domain/models/announcement.dart';
import '../../../announcements/presentation/controllers/announcement_cubit.dart';
import '../../../announcements/presentation/controllers/announcement_state.dart';
import '../../../announcements/presentation/pages/announcement_list_page.dart';
import '../../../maintenance/domain/models/maintenance_request.dart';
import '../../../maintenance/presentation/controllers/maintenance_cubit.dart';
import '../../../maintenance/presentation/controllers/maintenance_state.dart';
import '../../../maintenance/presentation/pages/maintenance_list_page.dart';

class ResidentOperationsPage extends StatefulWidget {
  const ResidentOperationsPage({super.key});

  @override
  State<ResidentOperationsPage> createState() => _ResidentOperationsPageState();
}

class _ResidentOperationsPageState extends State<ResidentOperationsPage> {
  // Maintenance Filters
  String _selectedMaintenanceStatus = 'all';
  String _selectedMaintenanceCategory = 'all';

  // Announcement Filters
  String _selectedAnnouncementStatus = 'all';
  String _selectedAnnouncementApartment = 'all';

  String _normalizeStatusDisplay(MaintenanceRequest r) {
    final status = (r.statusDisplay ?? r.status).toLowerCase();
    if (status == 'pending' || status == 'beklemede' || status == 'p') {
      return 'Beklemede';
    }
    if (status == 'assigned' || status == 'personel atandı' || status == 'a') {
      return 'Personel Atandı';
    }
    if (status == 'in_progress' || status == 'işlem devam ediyor' || status == 'devam ediyor' || status == 'i') {
      return 'İşlem Devam Ediyor';
    }
    if (status == 'completed' || status == 'tamamlandı' || status == 'resolved' || status == 'c') {
      return 'Tamamlandı';
    }
    if (status == 'cancelled' || status == 'iptal edildi' || status == 'rejected') {
      return 'İptal Edildi';
    }
    return r.statusDisplay ?? r.status;
  }

  String _normalizeCategoryDisplay(MaintenanceRequest r) {
    final category = (r.categoryDisplay ?? r.category).toLowerCase();
    if (category == 'electricity' || category == 'electrical' || category == 'elektrik' || category == 'e') {
      if (r.title.toLowerCase().contains('asansör')) {
        return 'Asansör';
      }
      return 'Elektrik';
    }
    if (category == 'plumbing' || category == 'su tesisatı' || category == 'su' || category == 'p') {
      if (r.title.toLowerCase().contains('otopark')) {
        return 'Otopark';
      }
      return 'Su Tesisatı';
    }
    if (category == 'elevator' || category == 'asansör') return 'Asansör';
    if (category == 'cleaning' || category == 'temizlik' || category == 'c') {
      if (r.title.toLowerCase().contains('ortak')) {
        return 'Ortak Alan';
      }
      return 'Temizlik';
    }
    if (category == 'security' || category == 'güvenlik' || category == 's') return 'Güvenlik';
    if (category == 'common_area' || category == 'ortak alan') return 'Ortak Alan';
    if (category == 'garden' || category == 'bahçe' || category == 'g') return 'Bahçe';
    if (category == 'parking' || category == 'otopark') return 'Otopark';
    if (category == 'other' || category == 'diğer' || category == 'o') return 'Diğer';
    return r.categoryDisplay ?? r.category;
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

  void _showMaintenanceFilterBottomSheet(BuildContext context, MaintenanceLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempStatus = _selectedMaintenanceStatus;
        String tempCategory = _selectedMaintenanceCategory;

        final statuses = ['all', ...state.requests.map((r) => _normalizeStatusDisplay(r)).toSet()];
        final categories = ['all', ...state.requests.map((r) => _normalizeCategoryDisplay(r)).toSet()];

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final count = state.requests.where((r) {
              final matchesStatus = tempStatus == 'all' || _normalizeStatusDisplay(r) == tempStatus;
              final matchesCategory = tempCategory == 'all' || _normalizeCategoryDisplay(r) == tempCategory;
              return matchesStatus && matchesCategory;
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
                              tempStatus = 'all';
                              tempCategory = 'all';
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
                        Text('Durum süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildListCard(
                          items: _toOptions(statuses),
                          selectedValue: tempStatus,
                          onChanged: (val) => setBottomSheetState(() => tempStatus = val),
                        ),
                        const SizedBox(height: 24),
                        Text('Kategori süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildListCard(
                          items: _toOptions(categories),
                          selectedValue: tempCategory,
                          onChanged: (val) => setBottomSheetState(() => tempCategory = val),
                        ),
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
                            _selectedMaintenanceStatus = tempStatus;
                            _selectedMaintenanceCategory = tempCategory;
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

  void _showAnnouncementFilterBottomSheet(BuildContext context, AnnouncementLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempStatus = _selectedAnnouncementStatus;
        String tempApt = _selectedAnnouncementApartment;

        final statuses = ['all', ...state.announcements.map((a) => a.statusDisplay ?? a.status).toSet()];
        final apartments = ['all', ...state.announcements.map((a) => a.apartmentName).whereType<String>().toSet()];

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final count = state.announcements.where((a) {
              final matchesStatus = tempStatus == 'all' || (a.statusDisplay ?? a.status) == tempStatus;
              final matchesApt = tempApt == 'all' || a.apartmentName == tempApt;
              return matchesStatus && matchesApt;
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
                              tempStatus = 'all';
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
                        Text('Durum süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildListCard(
                          items: _toOptions(statuses),
                          selectedValue: tempStatus,
                          onChanged: (val) => setBottomSheetState(() => tempStatus = val),
                        ),
                        const SizedBox(height: 24),
                        Text('Apartman / Site süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildListCard(
                          items: _toOptions(apartments),
                          selectedValue: tempApt,
                          onChanged: (val) => setBottomSheetState(() => tempApt = val),
                        ),
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
                            _selectedAnnouncementStatus = tempStatus;
                            _selectedAnnouncementApartment = tempApt;
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
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Operasyon & Hizmetler'),
            actions: [
              Builder(
                builder: (context) {
                  final tabController = DefaultTabController.of(context);
                  return AnimatedBuilder(
                    animation: tabController,
                    builder: (context, _) {
                      final index = tabController.index;
                      if (index == 0) {
                        return BlocBuilder<MaintenanceCubit, MaintenanceState>(
                          builder: (context, state) {
                            if (state is! MaintenanceLoaded) return const SizedBox();
                            final hasFilter = _selectedMaintenanceStatus != 'all' || _selectedMaintenanceCategory != 'all';
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: IconButton(
                                onPressed: () => _showMaintenanceFilterBottomSheet(context, state),
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
                        );
                      } else {
                        return BlocBuilder<AnnouncementCubit, AnnouncementState>(
                          builder: (context, state) {
                            if (state is! AnnouncementLoaded) return const SizedBox();
                            final hasFilter = _selectedAnnouncementStatus != 'all' || _selectedAnnouncementApartment != 'all';
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: IconButton(
                                onPressed: () => _showAnnouncementFilterBottomSheet(context, state),
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
                        );
                      }
                    },
                  );
                },
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Bakım Talepleri'),
                Tab(text: 'Duyurular'),
              ],
            ),
          ),
          body: BlocBuilder<MaintenanceCubit, MaintenanceState>(
            builder: (context, maintenanceState) {
              return BlocBuilder<AnnouncementCubit, AnnouncementState>(
                builder: (context, announcementState) {
                  List<MaintenanceRequest>? filteredReqs;
                  if (maintenanceState is MaintenanceLoaded) {
                    filteredReqs = maintenanceState.requests.where((r) {
                      final matchesStatus = _selectedMaintenanceStatus == 'all' || _normalizeStatusDisplay(r) == _selectedMaintenanceStatus;
                      final matchesCategory = _selectedMaintenanceCategory == 'all' || _normalizeCategoryDisplay(r) == _selectedMaintenanceCategory;
                      return matchesStatus && matchesCategory;
                    }).toList();
                  }

                  List<Announcement>? filteredAnns;
                  if (announcementState is AnnouncementLoaded) {
                    filteredAnns = announcementState.announcements.where((a) {
                      final matchesStatus = _selectedAnnouncementStatus == 'all' || (a.statusDisplay ?? a.status) == _selectedAnnouncementStatus;
                      final matchesApt = _selectedAnnouncementApartment == 'all' || a.apartmentName == _selectedAnnouncementApartment;
                      return matchesStatus && matchesApt;
                    }).toList();
                  }

                  return TabBarView(
                    children: [
                      MaintenanceListPage(showAppBar: false, filteredRequests: filteredReqs),
                      AnnouncementListPage(showAppBar: false, filteredAnnouncements: filteredAnns),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );
  }
}
