import re

with open('lib/features/finance/data/datasources/finance_remote_data_source.dart', 'r') as f:
    content = f.read()

# Remove the bad lines
content = re.sub(r'  @override \n  Future<void> createPayment\(Map<String, dynamic> data\) async \{ \n    await _dio.post\(\'/payments/\', data: data\); \n  \}\n', '', content)

# Add to FinanceRemoteDataSourceImpl
content = content.replace(
    '  @override\n  Future<void> createDuePeriod(Map<String, dynamic> data) async {',
    '  @override\n  Future<void> createPayment(Map<String, dynamic> data) async {\n    await _dio.post(\'/payments/\', data: data);\n  }\n\n  @override\n  Future<void> createDuePeriod(Map<String, dynamic> data) async {'
)

with open('lib/features/finance/data/datasources/finance_remote_data_source.dart', 'w') as f:
    f.write(content)

with open('lib/features/dashboard/presentation/pages/manager_add_expense_page.dart', 'r') as f:
    content2 = f.read()

content2 = content2.replace(
    "import '../../../finance/presentation/controllers/finance_cubit.dart';",
    "import '../../../finance/presentation/controllers/finance_cubit.dart';\nimport '../../../finance/presentation/controllers/finance_state.dart';"
)

with open('lib/features/dashboard/presentation/pages/manager_add_expense_page.dart', 'w') as f:
    f.write(content2)

