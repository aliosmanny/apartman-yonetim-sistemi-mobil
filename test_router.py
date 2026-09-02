import re

def fix():
    path = 'lib/app/router/app_router.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Just making sure we understand where the route is.
    print(len(re.findall(r'StatefulShellBranch', content)))

fix()
