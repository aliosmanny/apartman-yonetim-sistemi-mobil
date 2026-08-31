import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../announcements/domain/models/announcement.dart';
import '../../../announcements/presentation/controllers/announcement_cubit.dart';
import '../../../announcements/presentation/controllers/announcement_state.dart';

class ManagerAnnouncementPage extends StatefulWidget {
  const ManagerAnnouncementPage({super.key});

  @override
  State<ManagerAnnouncementPage> createState() => _ManagerAnnouncementPageState();
}

class _ManagerAnnouncementPageState extends State<ManagerAnnouncementPage> {
  String _selectedStatus = 'all';
  String _selectedApartment = 'all';

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

  void _showFilterBottomSheet(BuildContext context, AnnouncementLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempStatus = _selectedStatus;
        String tempApt = _selectedApartment;

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
                            _selectedStatus = tempStatus;
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnnouncementCubit>()..fetchAnnouncements(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Duyurular'),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) {
                return BlocBuilder<AnnouncementCubit, AnnouncementState>(
                  builder: (context, state) {
                    if (state is! AnnouncementLoaded) return const SizedBox();
                    final hasFilter = _selectedStatus != 'all' || _selectedApartment != 'all';
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
                );
              }
            ),
          ],
        ),
        body: BlocBuilder<AnnouncementCubit, AnnouncementState>(
          builder: (context, state) {
            if (state is AnnouncementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AnnouncementError) {
              return Center(
                child: Text('Hata: ${state.message}', style: const TextStyle(color: AppColors.error)),
              );
            } else if (state is AnnouncementLoaded) {
              final filtered = state.announcements.where((a) {
                final matchesStatus = _selectedStatus == 'all' || (a.statusDisplay ?? a.status) == _selectedStatus;
                final matchesApt = _selectedApartment == 'all' || a.apartmentName == _selectedApartment;
                return matchesStatus && matchesApt;
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('Duyuru bulunamadı.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final ann = filtered[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ann.title,
                                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ann.apartmentName ?? 'Genel',
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (ann.status == 'published' || ann.status == 'Yayında')
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.textTertiary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ann.statusDisplay ?? ann.status,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: (ann.status == 'published' || ann.status == 'Yayında')
                                      ? AppColors.success
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          ann.content,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: AppColors.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  ann.createdByName ?? 'Bilinmiyor',
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(ann.publishDate ?? ann.createdAt),
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.push('/manager/announcements/edit', extra: {
                                    'announcement': ann,
                                    'cubit': context.read<AnnouncementCubit>()
                                  });
                                },
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Düzenle'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Silme Onayı'),
                                      content: const Text('Bu duyuruyu silmek istediğinize emin misiniz?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Sil', style: TextStyle(color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    context.read<AnnouncementCubit>().deleteAnnouncement(ann.id);
                                  }
                                },
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                label: const Text('Sil', style: TextStyle(color: AppColors.error)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                context.push('/manager/announcements/create', extra: context.read<AnnouncementCubit>());
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
        ),
      ),
    );
  }
}
