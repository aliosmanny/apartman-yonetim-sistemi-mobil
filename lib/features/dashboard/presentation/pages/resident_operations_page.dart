import 'package:flutter/material.dart';
import '../../../announcements/presentation/pages/announcement_list_page.dart';
import '../../../maintenance/presentation/pages/maintenance_list_page.dart';

class ResidentOperationsPage extends StatelessWidget {
  const ResidentOperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Operasyon & Hizmetler'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bakım Talepleri'),
              Tab(text: 'Duyurular'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MaintenanceListPage(showAppBar: false),
            AnnouncementListPage(showAppBar: false),
          ],
        ),
      ),
    );
  }
}
