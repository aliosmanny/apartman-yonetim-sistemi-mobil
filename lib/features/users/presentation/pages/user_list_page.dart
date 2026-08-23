import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../domain/models/user.dart';
import '../controllers/user_cubit.dart';
import '../controllers/user_state.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late final UserCubit _cubit;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cubit = sl<UserCubit>()..fetchUsers();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Kullanıcılar'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Arama yapın...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserError) {
                    return Center(child: Text('Hata: ${state.message}', style: const TextStyle(color: AppColors.error)));
                  } else if (state is UserLoaded) {
                    final users = state.users.where((u) {
                      return u.fullName.toLowerCase().contains(_searchQuery) ||
                             u.phone.contains(_searchQuery) ||
                             (u.email?.toLowerCase().contains(_searchQuery) ?? false);
                    }).toList();

                    if (users.isEmpty) {
                      return const Center(child: Text('Kullanıcı bulunamadı.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _UserCard(user: users[index]);
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push('/manager/users/add', extra: _cubit);
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
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
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.fullName,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.phone, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            if (user.email != null && user.email!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(user.email!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.roleDisplay ?? user.role,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10),
              ),
            ),
            if (user.ownedUnits.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Kat Maliki: ${user.ownedUnits.first}', style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: AppColors.success)),
            ],
            if (user.rentedUnits.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Kiracı: ${user.rentedUnits.first}', style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: AppColors.warning)),
            ]
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          onSelected: (val) {
            if (val == 'edit') {
              context.push('/manager/users/edit', extra: {'user': user, 'cubit': context.read<UserCubit>()});
            } else if (val == 'delete') {
              context.read<UserCubit>().deleteUser(user.id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
