import re

def fix_file(filepath):
    try:
        with open(filepath, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        return

    original_content = content
    
    # We want to find occurrences of `_dio.get('/some-path/')` 
    # or `_apiClient.dio.get('/some-path/')` 
    # and add `queryParameters: {'page_size': 1000, 'limit': 1000}`
    
    # Case 1: FinanceRemoteDataSourceImpl
    # final response = await _dio.get(path);
    content = content.replace(
        "final response = await _dio.get(path);",
        "final response = await _dio.get(path, queryParameters: {'page_size': 1000, 'limit': 1000});"
    )
    
    # Case 2: PropertiesRemoteDataSourceImpl
    # final res = await _dio.get('/apartments/');
    endpoints = [
        "'/apartments/'",
        "'/contracts/'",
        "'/apartments/$aptId/blocks/'",
        "'/blocks/$blockId/units/'",
        "'/owners/'",
        "'/tenants/'"
    ]
    for endpoint in endpoints:
        content = content.replace(
            f"final res = await _dio.get({endpoint});",
            f"final res = await _dio.get({endpoint}, queryParameters: {{'page_size': 1000, 'limit': 1000}});"
        )
        content = content.replace(
            f"final response = await _dio.get({endpoint});",
            f"final response = await _dio.get({endpoint}, queryParameters: {{'page_size': 1000, 'limit': 1000}});"
        )

    # Case 3: StaffRemoteDataSourceImpl
    content = content.replace(
        "final response = await _apiClient.dio.get('/staff/');",
        "final response = await _apiClient.dio.get('/staff/', queryParameters: {'page_size': 1000, 'limit': 1000});"
    )
    
    # Case 4: AnnouncementsRemoteDataSourceImpl
    content = content.replace(
        """    final Map<String, dynamic> queryParams = {};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }""",
        """    final Map<String, dynamic> queryParams = {'page_size': 1000, 'limit': 1000};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }"""
    )
    
    # Case 5: MaintenanceRemoteDataSourceImpl (assuming similar queryParams logic)
    content = content.replace(
        """    final Map<String, dynamic> queryParameters = {};""",
        """    final Map<String, dynamic> queryParameters = {'page_size': 1000, 'limit': 1000};"""
    )
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed: {filepath}")

files = [
    'lib/features/properties/data/datasources/properties_remote_data_source.dart',
    'lib/features/finance/data/datasources/finance_remote_data_source.dart',
    'lib/features/staff/data/datasources/staff_remote_data_source.dart',
    'lib/features/announcements/data/datasources/announcement_remote_data_source.dart',
    'lib/features/maintenance/data/datasources/maintenance_remote_data_source.dart'
]

for f in files:
    fix_file(f)
