import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Due Periods
    content = content.replace(
        "child: ListTile(\n              title: Text(p.periodDisplay",
        "child: ListTile(\n              onTap: () => context.pushNamed('managerEditDuePeriod', extra: {'period': p, 'cubit': context.read<FinanceCubit>()}),\n              title: Text(p.periodDisplay"
    )

    # Debts
    content = content.replace(
        "side: BorderSide(color: isOverdue ? AppColors.error.withValues(alpha: 0.5) : Colors.transparent),\n            ),\n            child: Padding(",
        "side: BorderSide(color: isOverdue ? AppColors.error.withValues(alpha: 0.5) : Colors.transparent),\n            ),\n            child: InkWell(\n              onTap: () => context.pushNamed('managerEditDebt', extra: {'debt': debt, 'cubit': context.read<FinanceCubit>()}),\n              borderRadius: BorderRadius.circular(12),\n              child: Padding("
    )
    
    # And close the child for Debts... wait, the closing of Padding is tricky because there are many braces. 
    # Let me just write a targeted replace for Debts closing if needed. 
    # Actually, InkWell wraps Padding.
    # Where does Padding end?
    # It ends at:
    #                 ],
    #               ),
    #             ),
    #           );
    content = content.replace(
        "                  ),\n                ],\n              ),\n            ),\n          );",
        "                  ),\n                ],\n              ),\n            ),\n            ),\n          );"
    )
    
    # Payments
    content = content.replace(
        "child: ListTile(\n              title: Text(p.debtDescription ?? 'Ödeme'",
        "child: ListTile(\n              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Düzenleme özelliği yakında eklenecek'))),\n              title: Text(p.debtDescription ?? 'Ödeme'"
    )

    # Incomes
    content = content.replace(
        "child: ListTile(\n              title: Text(inc.title",
        "child: ListTile(\n              onTap: () => context.pushNamed('managerEditTransaction', extra: {'income': inc, 'cubit': context.read<FinanceCubit>()}),\n              title: Text(inc.title"
    )

    # Expenses
    content = content.replace(
        "child: ListTile(\n              title: Text(exp.title",
        "child: ListTile(\n              onTap: () => context.pushNamed('managerEditTransaction', extra: {'expense': exp, 'cubit': context.read<FinanceCubit>()}),\n              title: Text(exp.title"
    )

    with open(filepath, 'w') as f:
        f.write(content)
    print("Patched!")

patch_file('lib/features/dashboard/presentation/pages/manager_finance_page.dart')
