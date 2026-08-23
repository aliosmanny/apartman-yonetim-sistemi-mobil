
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../properties/presentation/controllers/properties_cubit.dart';
import '../../../properties/presentation/pages/lease_contract_list_page.dart';

class ResidentPropertiesPage extends StatelessWidget {
  const ResidentPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PropertiesCubit>()..fetchContracts(),
      child: DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Yapı & Sakin Yönetimi'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Kira Sözleşmeleri'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              LeaseContractListPage(),
            ],
          ),
        ),
      ),
    );
  }
}
