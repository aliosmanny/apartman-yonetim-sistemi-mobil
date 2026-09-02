import re

def fix():
    path = 'lib/features/dashboard/presentation/pages/manager_staff_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    start_idx = content.find("class _ManagerStaffCard extends StatelessWidget {")
    if start_idx == -1:
        return
        
    new_card = """class _ManagerStaffCard extends StatelessWidget {
  final StaffMember staff;

  const _ManagerStaffCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    final bool isActive = staff.isActive;

    return Card(
      child: InkWell(
        onTap: () {
          context.pushNamed('managerStaffForm', extra: {
            'staff': staff,
            'cubit': context.read<StaffCubit>(),
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: isActive ? AppColors.primary.withValues(alpha: 0.12) : AppColors.textTertiary.withValues(alpha: 0.2),
              child: Text(
                staff.userName.isNotEmpty ? staff.userName.substring(0, 1) : 'P',
                style: AppTextStyles.titleLarge.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            title: Text(
              '${staff.userName} (${staff.userPhone})',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.apartmentName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(staff.roleDisplay, style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: (isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          isActive ? 'Aktif' : 'Pasif',
                          style: TextStyle(fontSize: 10, color: isActive ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ),
        ),
      ),
    );
  }
}
"""
    content = content[:start_idx] + new_card
    
    # Also fix FAB in this page which has hardcoded shape
    content = content.replace("shape: const CircleBorder(),", "/* using global shape */")
    
    with open(path, 'w') as f:
        f.write(content)

fix()
