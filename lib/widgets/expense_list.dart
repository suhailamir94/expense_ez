import 'package:expense_ez/models/expense.dart';
import 'package:expense_ez/provider/filter_provider.dart';
import 'package:expense_ez/widgets/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseList extends ConsumerWidget {
  const ExpenseList(
      {super.key, required this.expenses, required this.handleOnSort});

  final List<Expense> expenses;
  final Function handleOnSort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, dynamic> filters = ref.watch(filterProvider);
    String listTitle = 'Today';

    if (filters['selectedFilterIndex'] > -1) {
      switch (filters['selectedFilterIndex']) {
        case 0:
          listTitle = 'All Expenses';
          break;
        case 1:
          listTitle = 'This Month';
          break;
        case 2:
          listTitle = 'On ${customFormatter.format(filters['selectedDate'])}';
          break;
        case 3:
          listTitle =
              '${customFormatter.format(filters['fromDate'])} - ${customFormatter.format(filters['toDate'])}';
          break;
        default:
          listTitle = 'Today';
      }
    }
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
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                listTitle,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              IconButton(
                  onPressed: () => handleOnSort(), icon: const Icon(Icons.sort))
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
