import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/properties_cubit.dart';
import '../controllers/properties_state.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class LeaseContractListPage extends StatelessWidget {
  const LeaseContractListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertiesCubit, PropertiesState>(
      builder: (context, state) {

        if (state is PropertiesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PropertiesError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        }
        
        final contracts = state is PropertiesLoaded ? state.contracts : [];

        if (contracts.isEmpty) {

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.description_outlined, size: 64, color: AppColors.primary.withOpacity(0.5)),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sonuç bulunamadı',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kira sözleşmesi bulunmamaktadır.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/manager/properties/contracts/create', extra: {'cubit': context.read<PropertiesCubit>()});
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Kira Sözleşmesi Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        final formatCurrency = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16).copyWith(bottom: 80),
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                final contract = contracts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.description, color: AppColors.primary),
                    ),
                    title: Text(contract.title, style: AppTextStyles.titleMedium),
                    subtitle: Text('${contract.tenantName} • ${contract.unitDisplay}', style: AppTextStyles.bodySmall),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Malik:', contract.ownerName),
                            _buildInfoRow('Kiracı:', contract.tenantName),
                            _buildInfoRow('Başlangıç:', contract.startDate),
                            _buildInfoRow('Bitiş:', contract.endDate),
                            _buildInfoRow('Kira Bedeli:', formatCurrency.format(contract.monthlyRent)),
                            _buildInfoRow('Depozito:', formatCurrency.format(contract.depositAmount)),
                            _buildInfoRow('Durum:', contract.statusDisplay),
                            if (contract.contractFileUrl != null) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final url = Uri.parse(contract.contractFileUrl!);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  },
                                  icon: const Icon(Icons.download),
                                  label: const Text('Sözleşmeyi İndir / Görüntüle'),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  context.push('/manager/properties/contracts/create', extra: {'cubit': context.read<PropertiesCubit>()});
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
