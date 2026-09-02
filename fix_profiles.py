def fix_manager():
    path = 'lib/features/dashboard/presentation/pages/manager_profile_page.dart'
    with open(path, 'r') as f:
        content = f.read()
        
    import_auth = "import 'package:flutter_bloc/flutter_bloc.dart';\nimport '../../../auth/presentation/controllers/auth_cubit.dart';\nimport '../../../auth/presentation/controllers/auth_state.dart';"
    
    content = content.replace("import 'package:go_router/go_router.dart';", "import 'package:go_router/go_router.dart';\n" + import_auth)

    init_find = """  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Yönetici');
    _emailController = TextEditingController(text: 'yonetici@apartman.com');
    _phoneController = TextEditingController(text: '0555 000 11 22');
  }"""
  
    init_replace = """  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    String name = 'Yönetici';
    String email = 'yonetici@apartman.com';
    String phone = '0555 000 11 22';
    
    if (state is AuthAuthenticated) {
      name = state.user.fullName;
      email = state.user.email ?? '';
      phone = state.user.phone;
    }
    
    _nameController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);
    _phoneController = TextEditingController(text: phone);
  }"""
  
    content = content.replace(init_find, init_replace)
    
    # Let's also update the avatar text if it's hardcoded "Y"
    avatar_find = """                          child: Text(
                            'Y',
                            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),"""
    avatar_replace = """                          child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              String letter = 'Y';
                              if (state is AuthAuthenticated && state.user.fullName.isNotEmpty) {
                                letter = state.user.fullName[0].toUpperCase();
                              }
                              return Text(
                                letter,
                                style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            },
                          ),"""
    content = content.replace(avatar_find, avatar_replace)

    with open(path, 'w') as f:
        f.write(content)


def fix_staff():
    path = 'lib/features/dashboard/presentation/pages/staff_edit_profile_page.dart'
    with open(path, 'r') as f:
        content = f.read()
        
    import_auth = "import 'package:flutter_bloc/flutter_bloc.dart';\nimport '../../../auth/presentation/controllers/auth_cubit.dart';\nimport '../../../auth/presentation/controllers/auth_state.dart';"
    content = content.replace("import 'package:go_router/go_router.dart';", "import 'package:go_router/go_router.dart';\n" + import_auth)

    init_find = """  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Personel');
    _emailController = TextEditingController(text: 'personel@apartman.com');
    _phoneController = TextEditingController(text: '0555 123 45 67');
  }"""
  
    init_replace = """  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    String name = 'Personel';
    String email = 'personel@apartman.com';
    String phone = '0555 123 45 67';
    
    if (state is AuthAuthenticated) {
      name = state.user.fullName;
      email = state.user.email ?? '';
      phone = state.user.phone;
    }
    
    _nameController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);
    _phoneController = TextEditingController(text: phone);
  }"""
    content = content.replace(init_find, init_replace)

    # Avatar
    avatar_find = """                          child: Text(
                            'P',
                            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),"""
    avatar_replace = """                          child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              String letter = 'P';
                              if (state is AuthAuthenticated && state.user.fullName.isNotEmpty) {
                                letter = state.user.fullName[0].toUpperCase();
                              }
                              return Text(
                                letter,
                                style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            },
                          ),"""
    content = content.replace(avatar_find, avatar_replace)
    
    with open(path, 'w') as f:
        f.write(content)

fix_manager()
fix_staff()
