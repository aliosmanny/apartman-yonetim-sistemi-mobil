import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class ManagerStaffPage extends StatefulWidget {
  const ManagerStaffPage({super.key});

  @override
  State<ManagerStaffPage> createState() => _ManagerStaffPageState();
}

class _ManagerStaffPageState extends State<ManagerStaffPage> {
  final List<Map<String, dynamic>> _mockStaff = [
    {
      'name': 'Hasan Usta',
      'role': 'Tesisat / Genel Bakım',
      'phone': '0555 123 45 67',
      'status': 'Aktif',
    },
    {
      'name': 'Ali Veli',
      'role': 'Elektrik Uzmanı',
      'phone': '0532 987 65 43',
      'status': 'İzinde',
    },
    {
      'name': 'Fatma Hanım',
      'role': 'Temizlik Personeli',
      'phone': '0544 111 22 33',
      'status': 'Aktif',
    }
  ];

  void _addStaff() async {
    final result = await context.pushNamed('managerAddStaff');
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _mockStaff.insert(0, result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personel Yönetimi'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _mockStaff.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final staff = _mockStaff[index];
          return _ManagerStaffCard(staff: staff);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStaff,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ManagerStaffCard extends StatelessWidget {
  final Map<String, dynamic> staff;

  const _ManagerStaffCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    final bool isActive = staff['status'] == 'Aktif';

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isActive ? AppColors.primary.withOpacity(0.12) : AppColors.textTertiary.withOpacity(0.2),
          child: Text(
            staff['name'].substring(0, 1),
            style: AppTextStyles.titleLarge.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          staff['name'],
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(staff['role'], style: AppTextStyles.bodySmall),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(staff['phone'], style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            staff['status'],
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
