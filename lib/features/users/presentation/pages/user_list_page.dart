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
  String _selectedRole = 'all';
  String _selectedIsActive = 'all';

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

  void _showFilterBottomSheet(BuildContext context, List<AppUser> allUsers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempRole = _selectedRole;
        String tempIsActive = _selectedIsActive;

        final roles = const [
          {'value': 'all', 'label': 'Tümü'},
          {'value': 'system_admin', 'label': 'Sistem Yöneticisi'},
          {'value': 'apartment_manager', 'label': 'Apartman / Site Yöneticisi'},
          {'value': 'owner', 'label': 'Kat Maliki'},
          {'value': 'tenant', 'label': 'Kiracı'},
          {'value': 'staff', 'label': 'Personel'},
          {'value': 'former_system_admin', 'label': 'Eski Sistem Yöneticisi'},
          {
            'value': 'former_apartment_manager',
            'label': 'Eski Apartman / Site Yöneticisi'
          },
          {'value': 'former_owner', 'label': 'Eski Kat Maliki'},
          {'value': 'former_tenant', 'label': 'Eski Kiracı'},
          {'value': 'former_staff', 'label': 'Eski Personel'},
        ];

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final count = allUsers.where((u) {
              final matchesRole = tempRole == 'all' || u.role == tempRole;
              final matchesIsActive = tempIsActive == 'all' ||
                  (tempIsActive == 'yes' && u.isActive) ||
                  (tempIsActive == 'no' && !u.isActive);
              return matchesRole && matchesIsActive;
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
                        Text('Kullanıcı Filtresi',
                            style: AppTextStyles.headlineSmall),
                        TextButton(
                          onPressed: () {
                            setBottomSheetState(() {
                              tempRole = 'all';
                              tempIsActive = 'all';
                            });
                          },
                          child: const Text('Temizle',
                              style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        Text('Rol süzgecine göre',
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: roles.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (context, idx) {
                              final role = roles[idx];
                              final isSelected = tempRole == role['value'];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  role['label']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded,
                                        color: AppColors.primary)
                                    : null,
                                onTap: () {
                                  setBottomSheetState(() {
                                    tempRole = role['value']!;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Sisteme Giriş İzni (Zorunlu) süzgecine göre',
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSegmentBtn(
                              label: 'Tümü',
                              isSelected: tempIsActive == 'all',
                              onTap: () => setBottomSheetState(
                                  () => tempIsActive = 'all'),
                            ),
                            const SizedBox(width: 8),
                            _buildSegmentBtn(
                              label: 'Evet',
                              isSelected: tempIsActive == 'yes',
                              onTap: () => setBottomSheetState(
                                  () => tempIsActive = 'yes'),
                            ),
                            const SizedBox(width: 8),
                            _buildSegmentBtn(
                              label: 'Hayır',
                              isSelected: tempIsActive == 'no',
                              onTap: () => setBottomSheetState(
                                  () => tempIsActive = 'no'),
                            ),
                          ],
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
                            _selectedRole = tempRole;
                            _selectedIsActive = tempIsActive;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Sayıları göster ($count)',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
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

  Widget _buildSegmentBtn(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              if (state is UserLoaded) {
                return Text('Kullanıcılar (${state.users.length})');
              }
              return const Text('Kullanıcılar');
            },
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Arama yapın...',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.toLowerCase();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      final allUsers =
                          state is UserLoaded ? state.users : <AppUser>[];
                      final hasFilter =
                          _selectedRole != 'all' || _selectedIsActive != 'all';
                      return IconButton(
                        onPressed: state is UserLoaded
                            ? () => _showFilterBottomSheet(context, allUsers)
                            : null,
                        icon: Icon(
                          Icons.filter_list_rounded,
                          color: hasFilter
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: hasFilter
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.surface,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserError) {
                    return Center(
                        child: Text('Hata: ${state.message}',
                            style: const TextStyle(color: AppColors.error)));
                  } else if (state is UserLoaded) {
                    final users = state.users.where((u) {
                      // Basic normalization for Turkish characters in search
                      String normalize(String s) => s
                          .toLowerCase()
                          .replaceAll('i̇', 'i')
                          .replaceAll('ı', 'i')
                          .replaceAll('ğ', 'g')
                          .replaceAll('ü', 'u')
                          .replaceAll('ş', 's')
                          .replaceAll('ö', 'o')
                          .replaceAll('ç', 'c');

                      final query = normalize(_searchQuery);
                      final fullName = normalize(u.fullName);
                      final email = normalize(u.email ?? '');
                      final phone = u.phone;
                      final role = normalize(u.roleDisplay ?? u.role);

                      final matchesSearch = query.isEmpty ||
                          fullName.contains(query) ||
                          phone.contains(query) ||
                          email.contains(query) ||
                          role.contains(query);

                      final matchesRole =
                          _selectedRole == 'all' || u.role == _selectedRole;

                      final matchesIsActive = _selectedIsActive == 'all' ||
                          (_selectedIsActive == 'yes' && u.isActive) ||
                          (_selectedIsActive == 'no' && !u.isActive);

                      return matchesSearch && matchesRole && matchesIsActive;
                    }).toList();

                    if (users.isEmpty) {
                      return const Center(child: Text('Kullanıcı bulunamadı.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/manager/users/edit',
            extra: {'user': user, 'cubit': context.read<UserCubit>()}),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            title: Text(
              user.fullName,
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(user.phone,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(user.roleDisplay ?? user.role,
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (user.isActive
                                ? AppColors.success
                                : AppColors.error)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.isActive ? 'Aktif' : 'Pasif',
                        style: TextStyle(
                            fontSize: 10,
                            color: user.isActive
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.bold),
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
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.textSecondary, size: 20),
                  onPressed: () {
                    context.push('/manager/users/edit', extra: {
                      'user': user,
                      'cubit': context.read<UserCubit>()
                    });
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
