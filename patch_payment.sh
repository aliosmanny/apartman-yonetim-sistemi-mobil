#!/bin/bash
sed -i '' 's/Future<void> deleteItem(String type, String id);/Future<void> deleteItem(String type, String id);\n  Future<void> createPayment(Map<String, dynamic> data);/g' lib/features/finance/data/datasources/finance_remote_data_source.dart
sed -i '' '/Future<void> createDuePeriod(Map<String, dynamic> data);/i \
  @override \
  Future<void> createPayment(Map<String, dynamic> data) async { \
    await _dio.post('\'/payments/\'', data: data); \
  }\
' lib/features/finance/data/datasources/finance_remote_data_source.dart

sed -i '' 's/Future<void> deleteItem(String type, String id);/Future<void> deleteItem(String type, String id);\n  Future<void> createPayment(Map<String, dynamic> data);/g' lib/features/finance/domain/repositories/finance_repository.dart

sed -i '' '/Future<void> createDuePeriod(Map<String, dynamic> data) async {/i \
  @override \
  Future<void> createPayment(Map<String, dynamic> data) async { \
    await _remoteDataSource.createPayment(data); \
  }\
' lib/features/finance/data/repositories/finance_repository_impl.dart

sed -i '' '/Future<void> createDuePeriod(Map<String, dynamic> data) async {/i \
  Future<void> createPayment(Map<String, dynamic> data) async { \
    await _repository.createPayment(data); \
    await fetchManagerFinance(); \
  }\
' lib/features/finance/presentation/controllers/finance_cubit.dart
