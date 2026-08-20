import 'package:flutter/material.dart';
import '../../domain/models/property.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import 'package:go_router/go_router.dart';

class ManagerPropertiesPage extends StatefulWidget {
  const ManagerPropertiesPage({super.key});

  @override
  State<ManagerPropertiesPage> createState() => _ManagerPropertiesPageState();
}

class _ManagerPropertiesPageState extends State<ManagerPropertiesPage> {
  String _searchQuery = '';
  String _selectedBlock = 'Tümü';

  List<PropertyUnit> get _filteredProperties {
    return mockProperties.where((p) {
      final query = _searchQuery.normalizeTurkish();
      final residentNameNormalized = p.residentName?.normalizeTurkish() ?? '';
      
      final matchesSearch = residentNameNormalized.contains(query);
      final matchesFlat = p.flatNumber.contains(_searchQuery);
      final searchOk = _searchQuery.isEmpty || matchesSearch || matchesFlat;
      
      final blockOk = _selectedBlock == 'Tümü' || p.blockName == _selectedBlock;
      return searchOk && blockOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yapı ve Sakinler'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Yeni Sakin Ekle',
            onPressed: () {
              context.push('/manager/properties/add');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Arama ve Filtre ───────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Sakin adı veya Daire No ara...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Tümü', 'A Blok', 'B Blok', 'C Blok'].map((block) {
                      final isSelected = _selectedBlock == block;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(block),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedBlock = block);
                          },
                          showCheckmark: false,
                          backgroundColor: AppColors.surfaceVariant,
                          selectedColor: AppColors.primary,
                          elevation: 0,
                          pressElevation: 0,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          labelStyle: AppTextStyles.labelMedium.copyWith(
                            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Liste ───────────────────────────────────
          Expanded(
            child: _filteredProperties.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Aramanızla eşleşen daire bulunamadı',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredProperties.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final property = _filteredProperties[index];
                return _PropertyCard(property: property);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final PropertyUnit property;

  const _PropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final occupied = property.isOccupied;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: occupied ? AppColors.border : AppColors.textTertiary.withOpacity(0.4),
        ),
        boxShadow: occupied
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: occupied ? AppColors.primary.withOpacity(0.1) : AppColors.textTertiary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                property.blockName.substring(0, 1),
                style: AppTextStyles.labelSmall.copyWith(
                  color: occupied ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                property.flatNumber,
                style: AppTextStyles.titleMedium.copyWith(
                  color: occupied ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          occupied ? property.residentName! : 'Boş Daire',
          style: AppTextStyles.titleMedium.copyWith(
            color: occupied ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (occupied && property.residentPhone != null)
                Text(property.residentPhone!, style: AppTextStyles.bodySmall),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(property.type, style: AppTextStyles.labelSmall),
                  ),
                  if (!occupied) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SAKİN YOK',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          // TODO: Sakin/Daire Detay Sayfası
        },
      ),
    );
  }
}