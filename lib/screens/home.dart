import 'dart:developer';

import 'package:expense_ez/provider/category_provider.dart.dart';
import 'package:expense_ez/provider/filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import 'package:expense_ez/models/expense.dart';
import 'package:expense_ez/provider/expense_provider.dart';
import 'package:expense_ez/widgets/expense_list.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key, required this.updateWidget});

  final bool updateWidget;

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  late Future<void> _expensesFuture;
  late Future<void> _categoryFuture;
  bool isAscendingSort = false;

  void onSortChange() {
    setState(() {
      isAscendingSort = !isAscendingSort;
    });
    ref.read(expenseProvider.notifier).sortExpenses(isAscendingSort);
  }

  void loadHomeData() {
    final Map<String, dynamic> filters = ref.watch(filterProvider);
    log(filters.toString());

    switch (filters['selectedFilterIndex']) {
      case 0:
        _expensesFuture =
            ref.read(expenseProvider.notifier).loadAllTransactions();
        break;
      case 1:
        _expensesFuture =
            ref.read(expenseProvider.notifier).loadCurrentMonthTransactions();
        break;
      case 2:
        _expensesFuture = ref
            .read(expenseProvider.notifier)
            .loadTransactionsByDate(filters['selectedDate']);
        break;
      case 3:
        _expensesFuture = ref
            .read(expenseProvider.notifier)
            .loadTransactionBetweenDates(
                filters['fromDate'], filters['toDate']);
        break;
      default:
        _expensesFuture = ref
            .read(expenseProvider.notifier)
            .loadTransactionsByDate(DateTime.now());
    }
    _categoryFuture = ref.read(categoryProvider.notifier).loadData();
  }

  @override
  void didUpdateWidget(covariant Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadHomeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Expense> expenses = ref.watch(expenseProvider);

    return FutureBuilder(
        future: Future.wait([
          _expensesFuture,
          _categoryFuture,
        ]),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (expenses.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/lottie/empty.json'),
                Text(
                  'Yaaay! No Transactions so far!',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ],
            );
          }
          return ExpenseList(
            expenses: expenses,
            handleOnSort: onSortChange,
          );
        });
  }
}
