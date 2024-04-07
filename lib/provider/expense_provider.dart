import 'dart:developer';

import 'package:expense_ez/db/hive_db.dart';
import 'package:expense_ez/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]);

  Future<void> loadAllTransactions() async {
    try {
      state = await HiveDB.getAllTransactions();
    } catch (error) {
      log('Error fetching all expenses ${error.toString()}');
    }
  }

  Future<void> loadTransactionsByDate(DateTime date) async {
    try {
      state = await HiveDB.getTransactionsByDate(date);
    } catch (error) {
      log('Error fetching all expenses ${error.toString()}');
    }
  }

  Future<void> loadCurrentMonthTransactions() async {
    try {
      state = await HiveDB.getAllTransactionsForCurrentMonth();
    } catch (error) {
      log('Error fetching expenses for current month ${error.toString()}');
    }
  }

  Future<void> loadTransactionBetweenDates(
      DateTime fromDate, DateTime toDate) async {
    try {
      state = await HiveDB.getTransactionsBetweenDates(fromDate, toDate);
    } catch (error) {
      log('Error fetching expenses for current month ${error.toString()}');
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

  void sortExpenses(bool isAscending) {
    if (isAscending) {
      state.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } else {
      state.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    state = [...state];
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
