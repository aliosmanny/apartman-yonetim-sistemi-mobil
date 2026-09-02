import re

def fix():
    path = 'lib/features/users/presentation/pages/user_list_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    broken = """    return Container(
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
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          context.push('/manager/users/edit', extra: {'user': user, 'cubit': context.read<UserCubit>()});
        },"""
        
    fixed = """    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          context.push('/manager/users/edit', extra: {'user': user, 'cubit': context.read<UserCubit>()});
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),"""
            
    content = content.replace(broken, fixed)
    
    # We also need to add a closing parenthesis for InkWell/Padding
    # Wait, ListTile doesn't need to be changed except wrapping.
    # Let's replace the whole _UserCard to be clean.
    
    start_idx = content.find("class _UserCard extends StatelessWidget {")
    if start_idx == -1:
        return
        
    new_user_card = """class _UserCard extends StatelessWidget {
  final AppUser user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/manager/users/edit', extra: {'user': user, 'cubit': context.read<UserCubit>()}),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            title: Text(
              user.fullName,
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(user.phone, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(user.roleDisplay ?? user.role, style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (user.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.isActive ? 'Aktif' : 'Pasif',
                        style: TextStyle(fontSize: 10, color: user.isActive ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
                  onPressed: () {
                    context.push('/manager/users/edit', extra: {'user': user, 'cubit': context.read<UserCubit>()});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
"""
    content = content[:start_idx] + new_user_card
    with open(path, 'w') as f:
        f.write(content)

fix()
