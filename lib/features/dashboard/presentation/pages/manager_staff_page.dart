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
    return BlocProvider<StaffCubit>(
      create: (context) => sl<StaffCubit>()..fetchStaff(),
      child: const _ManagerStaffPageView(),
    );
  }
}

class _ManagerStaffPageView extends StatefulWidget {
  const _ManagerStaffPageView();

  @override
  State<_ManagerStaffPageView> createState() => _ManagerStaffPageViewState();
}

class _ManagerStaffPageViewState extends State<_ManagerStaffPageView> {
  void _addStaff() async {
    context.pushNamed('managerStaffForm', extra: {'cubit': context.read<StaffCubit>()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personeller'),
        centerTitle: true,
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
            final staffList = state.staffList;
            if (staffList.isEmpty) {
              return const Center(child: Text('Kayıtlı personel bulunamadı.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: staffList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ManagerStaffCard(staff: staffList[index]);
              },
            );
          }
          return const SizedBox();
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
  final StaffMember staff;

  const _ManagerStaffCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    final bool isActive = staff.isActive;

    return InkWell(
      onTap: () {
        context.pushNamed('managerStaffForm', extra: {
          'staff': staff,
          'cubit': context.read<StaffCubit>(),
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            staff.userName.isNotEmpty ? staff.userName.substring(0, 1) : 'P',
            style: AppTextStyles.titleLarge.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          '${staff.userName} (${staff.userPhone})',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(staff.apartmentName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(staff.roleDisplay, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isActive ? AppColors.success : AppColors.error,
          ),
        ),
      ),
    ),
    );
  }
}
