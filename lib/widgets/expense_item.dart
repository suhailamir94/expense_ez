import 'package:expense_ez/models/expense.dart';
import 'package:expense_ez/provider/expense_provider.dart';
import 'package:expense_ez/utils/util.dart';
import 'package:expense_ez/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

DateFormat customFormatter = DateFormat('MMMM d, y');

class ExpenseItem extends ConsumerWidget {
  const ExpenseItem({super.key, required this.expense});

  final Expense expense;

  void _openAddExpenseOverlay(BuildContext context) {
    showModalBottomSheet(
        useSafeArea: true,
        context: context,
        builder: (ctx) => NewExpense(newExpense: expense),
        isScrollControlled: true);
  }

  void _handleDeleteExpense(WidgetRef ref, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.end,
            elevation: 2,
            clipBehavior: Clip.hardEdge,
            content: const Text('Delete Transaction?'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    ref
                        .read(expenseProvider.notifier)
                        .deleteExpense(expense.id);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Yes')),
              ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('No'))
            ],
          );
        });
  }

  void _handleEditExpense(BuildContext context) {
    _openAddExpenseOverlay(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.horizontal,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.2, // Set a threshold for right swipe
        DismissDirection.endToStart: 0.2, // Set a threshold for right swipe
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _handleDeleteExpense(ref, context);
        } else if (direction == DismissDirection.endToStart) {
          _handleEditExpense(context);
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.delete,
          color: Colors.red[300],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.edit,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 0,
                offset: const Offset(0, 3),
              ),
            ]),
        child: ListTile(
          leading: ClipOval(
            clipBehavior: Clip.antiAlias,
            child: Lottie.asset(
                'assets/lottie/${expense.category.name.toLowerCase()}.json', // Replace with your Lottie animation file
                width: 60, // Adjust the size as needed
                height: 100,
                fit: BoxFit.cover // Adjust the size as needed
                ),
          ),
          title: Text(
            capitalizeFirst(expense.title),
          ),
          titleTextStyle: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
          subtitle:
              expense.description.isNotEmpty ? Text(expense.description) : null,
          subtitleTextStyle: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.grey),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹ ${expense.amount.toString()}',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                customFormatter.format(expense.timestamp),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.w500),
              )
            ],
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
