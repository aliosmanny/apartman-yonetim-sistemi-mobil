import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/announcement_cubit.dart';
import '../../domain/models/announcement.dart';

class CreateAnnouncementPage extends StatefulWidget {
  final AnnouncementCubit cubit;
  final Announcement? announcementToEdit;

  const CreateAnnouncementPage({
    super.key,
    required this.cubit,
    this.announcementToEdit,
  });

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcementToEdit?.title ?? '');
    _contentController = TextEditingController(text: widget.announcementToEdit?.content ?? '');
    
    final status = widget.announcementToEdit?.status ?? 'published';
    // Normalize status just in case backend returns short codes
    if (status == 'Yayında') {
      _selectedStatus = 'published';
    } else if (status == 'Arşivlendi') {
      _selectedStatus = 'archived';
    } else if (status == 'Taslak') {
      _selectedStatus = 'draft';
    } else {
      _selectedStatus = ['published', 'archived', 'draft'].contains(status) ? status : 'published';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      if (widget.announcementToEdit != null) {
        await widget.cubit.updateAnnouncement(
          widget.announcementToEdit!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          status: _selectedStatus,
        );
      } else {
        await widget.cubit.createAnnouncement(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          status: _selectedStatus,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.announcementToEdit != null ? 'Duyuru güncellendi.' : 'Duyuru başarıyla yayınlandı.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.announcementToEdit != null;
    final aptName = widget.announcementToEdit?.apartmentName ?? 'Gülbahçe Evleri';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Duyuruyu Düzenle' : 'Duyuru Yayınla'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apartman / Site', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: 'default',
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
                ),
                items: [
                  DropdownMenuItem(value: 'default', child: Text(aptName)),
                ],
                onChanged: null, // Disabled for now, as user said they will fetch from DB later
              ),
              const SizedBox(height: 20),

              Text('Duyuru Başlığı', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Örn: Asansör Bakımı Hakkında',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Başlık zorunludur' : null,
              ),
              const SizedBox(height: 20),

              Text('Duyuru İçeriği', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 7,
                decoration: const InputDecoration(
                  hintText: 'Duyuru detaylarını buraya yazın...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'İçerik zorunludur' : null,
              ),
              const SizedBox(height: 20),

              Text('Durum', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
                ),
                items: const [
                  DropdownMenuItem(value: 'published', child: Text('Yayında')),
                  DropdownMenuItem(value: 'draft', child: Text('Taslak')),
                  DropdownMenuItem(value: 'archived', child: Text('Arşivlendi')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEditing ? 'Kaydet' : 'Yayınla', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
