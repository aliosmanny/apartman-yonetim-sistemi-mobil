import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class ManagerDocumentsPage extends StatefulWidget {
  const ManagerDocumentsPage({super.key});

  @override
  State<ManagerDocumentsPage> createState() => _ManagerDocumentsPageState();
}

class _ManagerDocumentsPageState extends State<ManagerDocumentsPage> {
  final List<Map<String, dynamic>> _mockDocs = [
    {
      'title': 'Ekim 2025 Gelir Gider Tablosu.pdf',
      'type': 'pdf',
      'size': '2.4 MB',
      'date': '15.10.2025'
    },
    {
      'title': 'Yönetim Kurulu Kararları.docx',
      'type': 'doc',
      'size': '850 KB',
      'date': '01.09.2025'
    },
  ];

  void _uploadDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dosya seçici (File Picker) açılacak...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Belgeler'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _mockDocs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = _mockDocs[index];
          return _ManagerDocumentCard(document: doc);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadDocument,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ManagerDocumentCard extends StatelessWidget {
  final Map<String, dynamic> document;

  const _ManagerDocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    IconData fileIcon;
    Color iconColor;

    switch (document['type']) {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf_outlined;
        iconColor = AppColors.error;
        break;
      case 'doc':
      case 'docx':
        fileIcon = Icons.description_outlined;
        iconColor = AppColors.primary;
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
          document['title'],
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(document['size'], style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              Text(
                '• ${document['date']}',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${document['title']} silindi.'), backgroundColor: AppColors.error),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
