import 'dart:developer';

import 'package:expense_ez/db/hive_db.dart';
import 'package:expense_ez/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]);

  Future<void> loadData() async {
    try {
      state = await HiveDB.getAllExpenses();
    } catch (error) {
      log('Error fetching all expenses ${error.toString()}');
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await HiveDB.addExpense(expense);
      state = [expense, ...state];
    } catch (error) {
      log('Error adding expenses ${error.toString()}');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await HiveDB.deleteExpense(id);
      state = state.where((expense) => expense.id != id).toList();
    } catch (error) {
      log('Error adding expenses ${error.toString()}');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await HiveDB.updateExpense(expense);
      state = state.map((e) {
        if (e.id == expense.id) {
          return expense;
        } else {
          return e;
        }
      }).toList();
    } catch (error) {
      log('Error adding expenses ${error.toString()}');
    }
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>(
    (ref) => ExpenseNotifier());
