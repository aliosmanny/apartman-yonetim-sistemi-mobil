def fix(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Replace all double-closing brackets back to normal
    content = content.replace("                  ),\n                ],\n              ),\n            ),\n            ),\n          );", "                  ),\n                ],\n              ),\n            ),\n          );")

    # The issue is actually "            ),\n            ),\n          );"
    # Let's fix that specific pattern.
    content = content.replace("            ),\n            ),\n          );", "            ),\n          );")
    
    with open(filepath, 'w') as f:
        f.write(content)

fix('lib/features/dashboard/presentation/pages/manager_finance_page.dart')
