import 'dart:developer';

import 'package:expense_ez/models/expense.dart';
import 'package:expense_ez/provider/expense_provider.dart';
import 'package:expense_ez/widgets/custom_line_chart.dart';
import 'package:expense_ez/widgets/custom_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class Insights extends ConsumerStatefulWidget {
  const Insights({super.key});

  @override
  ConsumerState<Insights> createState() {
    return _InsightsState();
  }
}

class _InsightsState extends ConsumerState<Insights> {
  late Future<void> _expensesFuture;

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

  Map<double, double> convertExpensesToBarChartData(List<Expense> expenses) {
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

  @override
  void initState() {
    super.initState();
    _expensesFuture =
        ref.read(expenseProvider.notifier).loadCurrentMonthTransactions();
  }

  @override
  Widget build(BuildContext context) {
    List<Expense> expenses = ref.watch(expenseProvider);

    final lineChartData = convertExpensesToLineChartData(expenses);

    if (expenses.isEmpty) {
      return const Center(
        child: Text('No Data!'),
      );
    }

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
          return Column(
            children: [
              CustomLineChart(lineChartData: lineChartData)
                  .animate(effects: [FadeEffect(duration: 1.seconds)]),
              const SizedBox(
                height: 20,
              ),
              // const CustomPieChart()
            ],
          );
        }));
  }
}
