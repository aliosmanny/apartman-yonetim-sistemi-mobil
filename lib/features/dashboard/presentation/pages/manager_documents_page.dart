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

class ManagerDocumentsPage extends StatelessWidget {
  const ManagerDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DocumentCubit>()..fetchDocuments(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Belgeler'),
          centerTitle: true,
        ),
        body: BlocBuilder<DocumentCubit, DocumentState>(
          builder: (context, state) {
            if (state is DocumentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DocumentError) {
              return Center(child: Text('Hata: ${state.message}', style: const TextStyle(color: AppColors.error)));
            } else if (state is DocumentLoaded) {
              final documents = state.documents;
              if (documents.isEmpty) {
                return const Center(child: Text('Henüz belge yüklenmemiş.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: documents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _ManagerDocumentCard(document: documents[index]);
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
