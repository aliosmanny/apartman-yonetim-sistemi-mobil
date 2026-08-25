import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../documents/domain/models/document.dart';
import '../../../documents/presentation/controllers/document_cubit.dart';
import '../../../documents/presentation/controllers/document_state.dart';

class ManagerDocumentsPage extends StatefulWidget {
  const ManagerDocumentsPage({super.key});

  @override
  State<ManagerDocumentsPage> createState() => _ManagerDocumentsPageState();
}

class _ManagerDocumentsPageState extends State<ManagerDocumentsPage> {
  String _selectedCategory = 'all';
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

  void _showFilterBottomSheet(BuildContext context, DocumentLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempCategory = _selectedCategory;
        String tempStatus = _selectedStatus;
        String tempApt = _selectedApartment;

        final categories = ['all', ...state.documents.map((d) => d.categoryDisplay ?? d.category).toSet()];
        final statuses = ['all', ...state.documents.map((d) => d.statusDisplay ?? d.status).toSet()];
        final apartments = ['all', ...state.documents.map((d) => d.apartmentName).whereType<String>().toSet()];

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final count = state.documents.where((d) {
              final matchesCategory = tempCategory == 'all' || (d.categoryDisplay ?? d.category) == tempCategory;
              final matchesStatus = tempStatus == 'all' || (d.statusDisplay ?? d.status) == tempStatus;
              final matchesApt = tempApt == 'all' || d.apartmentName == tempApt;
              return matchesCategory && matchesStatus && matchesApt;
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
                              tempCategory = 'all';
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
                        Text('Kategori süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildListCard(
                          items: _toOptions(categories),
                          selectedValue: tempCategory,
                          onChanged: (val) => setBottomSheetState(() => tempCategory = val),
                        ),
                        const SizedBox(height: 24),
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
                            _selectedCategory = tempCategory;
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DocumentCubit>()..fetchDocuments(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Belgeler'),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) {
                return BlocBuilder<DocumentCubit, DocumentState>(
                  builder: (context, state) {
                    if (state is! DocumentLoaded) return const SizedBox();
                    final hasFilter = _selectedCategory != 'all' || _selectedStatus != 'all' || _selectedApartment != 'all';
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
        body: BlocBuilder<DocumentCubit, DocumentState>(
          builder: (context, state) {
            if (state is DocumentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DocumentError) {
              return Center(child: Text('Hata: ${state.message}', style: const TextStyle(color: AppColors.error)));
            } else if (state is DocumentLoaded) {
              final filtered = state.documents.where((d) {
                final matchesCategory = _selectedCategory == 'all' || (d.categoryDisplay ?? d.category) == _selectedCategory;
                final matchesStatus = _selectedStatus == 'all' || (d.statusDisplay ?? d.status) == _selectedStatus;
                final matchesApt = _selectedApartment == 'all' || d.apartmentName == _selectedApartment;
                return matchesCategory && matchesStatus && matchesApt;
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('Belge bulunamadı.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _ManagerDocumentCard(document: filtered[index]);
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
                context.push('/manager/more/documents/add', extra: context.read<DocumentCubit>());
              },
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
        ),
      ),
    );
  }
}

class _ManagerDocumentCard extends StatelessWidget {
  final AppDocument document;

  const _ManagerDocumentCard({required this.document});

  Future<void> _downloadFile(BuildContext context) async {
    if (document.fileUrl != null && document.fileUrl!.isNotEmpty) {
      final uri = Uri.parse(document.fileUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dosya açılamadı.'), backgroundColor: AppColors.error),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dosya bağlantısı bulunamadı.'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData fileIcon;
    Color iconColor;

    switch (document.fileExtension) {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf_outlined;
        iconColor = AppColors.error;
        break;
      case 'doc':
      case 'docx':
        fileIcon = Icons.description_outlined;
        iconColor = AppColors.primary;
        break;
      case 'xls':
      case 'xlsx':
        fileIcon = Icons.table_chart_outlined;
        iconColor = AppColors.success;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        fileIcon = Icons.image_outlined;
        iconColor = AppColors.warning;
        break;
      default:
        fileIcon = Icons.insert_drive_file_outlined;
        iconColor = AppColors.textSecondary;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(fileIcon, color: iconColor),
        ),
        title: Text(
          document.title,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                document.categoryDisplay ?? document.category,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _formatDate(document.createdAt),
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: document.status == 'active' ? AppColors.success.withOpacity(0.1) : AppColors.textTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      document.statusDisplay ?? document.status,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: document.status == 'active' ? AppColors.success : AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download_outlined, color: AppColors.primary),
              onPressed: () => _downloadFile(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Silme Onayı'),
                    content: const Text('Bu belgeyi silmek istediğinize emin misiniz?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sil', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  context.read<DocumentCubit>().deleteDocument(document.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
