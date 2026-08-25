import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../properties/presentation/controllers/properties_cubit.dart';
import '../../../properties/presentation/controllers/properties_state.dart';
import '../../../properties/presentation/pages/lease_contract_list_page.dart';

class ResidentPropertiesPage extends StatefulWidget {
  const ResidentPropertiesPage({super.key});

  @override
  State<ResidentPropertiesPage> createState() => _ResidentPropertiesPageState();
}

class _ResidentPropertiesPageState extends State<ResidentPropertiesPage> {
  String _selectedContractStatus = 'all';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempContractStatus = _selectedContractStatus;

        final statuses = const [
          {'value': 'all', 'label': 'Tümü'},
          {'value': 'active', 'label': 'Aktif'},
          {'value': 'expired', 'label': 'Süresi Doldu'},
        ];

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final count = state.contracts.where((c) {
              return tempContractStatus == 'all' || c.status == tempContractStatus;
            }).length;

            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
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
                              tempContractStatus = 'all';
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
                        Text('Sözleşme Durumu süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildListCard(
                          items: statuses,
                          selectedValue: tempContractStatus,
                          onChanged: (val) => setBottomSheetState(() => tempContractStatus = val),
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
                            _selectedContractStatus = tempContractStatus;
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
    return BlocProvider(
      create: (_) => sl<PropertiesCubit>()..fetchContracts(),
      child: DefaultTabController(
        length: 1,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Yapı & Sakin Yönetimi'),
            actions: [
              BlocBuilder<PropertiesCubit, PropertiesState>(
                builder: (context, state) {
                  if (state is! PropertiesLoaded) return const SizedBox();
                  final hasFilter = _selectedContractStatus != 'all';
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
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Kira Sözleşmeleri'),
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
                final filteredContracts = state.contracts.where((c) {
                  return _selectedContractStatus == 'all' || c.status == _selectedContractStatus;
                }).toList();
  
                return TabBarView(
                  children: [
                    LeaseContractListPage(filteredContracts: filteredContracts),
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
}
