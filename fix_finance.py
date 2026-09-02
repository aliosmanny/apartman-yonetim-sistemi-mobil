def fix(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # The block inside DuePeriods:
    old = """                ],
              ),
          );"""
    new = """                ],
              ),
            ),
          );"""
    content = content.replace(old, new)
    
    with open(filepath, 'w') as f:
        f.write(content)

fix('lib/features/dashboard/presentation/pages/manager_finance_page.dart')
