def fix():
    path = 'lib/features/dashboard/presentation/pages/manager_finance_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    content = content.replace("class _SliverAppBarDelegate", "}\n\nclass _SliverAppBarDelegate")
    
    with open(path, 'w') as f:
        f.write(content)

fix()
