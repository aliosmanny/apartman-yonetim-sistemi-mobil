def fix():
    path = 'lib/features/maintenance/data/datasources/maintenance_remote_data_source.dart'
    with open(path, 'r') as f:
        content = f.read()

    broken = "final queryParameters = <String, dynamic>{};"
    fixed = "final queryParameters = <String, dynamic>{'page_size': 1000, 'limit': 1000};"
    content = content.replace(broken, fixed)
    
    with open(path, 'w') as f:
        f.write(content)

fix()
