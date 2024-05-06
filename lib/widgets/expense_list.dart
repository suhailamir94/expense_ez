import 'package:expense_ez/models/expense.dart';
import 'package:expense_ez/widgets/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final formatter = NumberFormat('#,##,000');

class ExpenseList extends ConsumerWidget {
  const ExpenseList(
      {super.key, required this.expenses, required this.handleOnSort});

  final List<Expense> expenses;
  final Function handleOnSort;

  getTotalExpense(List<Expense> expenses) {
    return expenses
        .fold(0, (previousValue, element) => previousValue + element.amount)
        .ceil();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transactions',
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ₹ ${formatter.format(getTotalExpense(expenses))}',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              IconButton(
                onPressed: () => handleOnSort(),
                icon: const Icon(Icons.sort),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: ((context, index) {
                return ExpenseItem(expense: expenses[index]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}
