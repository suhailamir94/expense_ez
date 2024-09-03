import 'dart:developer';

import 'package:expense_ez/provider/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_ez/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:expense_ez/provider/expense_provider.dart';
import 'package:expense_ez/widgets/custom_line_chart.dart';
import 'package:expense_ez/widgets/custom_pie_chart.dart';
import 'package:expense_ez/models/category.dart';

class Insights extends ConsumerStatefulWidget {
  const Insights({super.key});

  @override
  ConsumerState<Insights> createState() {
    return _InsightsState();
  }
}

class _InsightsState extends ConsumerState<Insights> {
  late Future<void> _expensesFuture;
  List<Category> categories = [];

  Map<double, double> convertExpensesToLineChartData(List<Expense> expenses) {
    log(expenses.toString());
    Map<double, double> data = {};
    for (var expense in expenses) {
      if (data.containsKey(expense.timestamp.day)) {
        data[double.parse('${expense.timestamp.day}')] =
            data[expense.timestamp.day]! + expense.amount;
      } else {
        data[double.parse('${expense.timestamp.day}')] =
            double.parse('${expense.amount}');
      }
    }
    return data;
  }

  List<Map<String, dynamic>> convertExpensesToPieChartData(
      List<Expense> expenses) {
    List<Map<String, dynamic>> data = [];
    for (var element in categories) {
      data.add({
        'categoryName': element.name,
        'categoryTotal': 0,
        'categoryIcon': element.icon,
      });
    }
    for (var expense in expenses) {
      for (var element in data) {
        if (element['categoryName'] == expense.category.name) {
          element['categoryTotal'] += expense.amount;
        }
      }
    }
    return data.where((element) => element['categoryTotal'] > 0).toList();
  }

  @override
  void initState() {
    super.initState();
    _expensesFuture =
        ref.read(expenseProvider.notifier).loadCurrentMonthTransactions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final List<Category> loadedCategories = ref.watch(categoryProvider);
    setState(() {
      categories = loadedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Expense> expenses = ref.watch(expenseProvider);

    final lineChartData = convertExpensesToLineChartData(expenses);
    final pieChartData = convertExpensesToPieChartData(expenses);

    return FutureBuilder(
        future: _expensesFuture,
        builder: ((context, snapshot) {
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
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomLineChart(lineChartData: lineChartData),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'EXPENSES BY CATEGORY',
                  style: TextStyle(color: Colors.black38),
                ),
                const SizedBox(
                  height: 15,
                ),
                PieChartSample3(pieChartData: pieChartData)
                // .animate(effects: [FadeEffect(duration: 1.seconds)]),
              ],
            ),
          );
        }));
  }
}
