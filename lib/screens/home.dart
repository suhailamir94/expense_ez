import 'package:expense_ez/provider/category_provider.dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import 'package:expense_ez/models/expense.dart';
import 'package:expense_ez/provider/expense_provider.dart';
import 'package:expense_ez/widgets/expense_list.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  late Future<void> _expensesFuture;
  late Future<void> _categoryFuture;

  @override
  void initState() {
    super.initState();
    _expensesFuture = ref.read(expenseProvider.notifier).loadData();
    _categoryFuture = ref.read(categoryProvider.notifier).loadData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Expense> expenses = ref.watch(expenseProvider);
    return SafeArea(
        child: FutureBuilder(
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
              return ExpenseList(expenses: expenses);
            }));
  }
}
