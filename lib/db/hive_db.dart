import 'dart:developer';

import 'package:expense_ez/models/expense.dart';
import 'package:expense_ez/models/category.dart';
import 'package:expense_ez/utils/util.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HiveDB {
  static Future<void> initHive() async {
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(PaymentModeAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(CategoryAdapter());

    // Open the categories box
    await openBoxes();

    // Check if categories have already been loaded
    final Box<dynamic> box = await Hive.openBox<dynamic>('settings');
    final bool categoriesLoaded =
        box.get('categoriesLoaded', defaultValue: false);
    final DateTime lastHitTimestamp =
        box.get('lastHitTimestamp', defaultValue: DateTime.now());
    final currentTimestamp = DateTime.now();
    if (checkIfNextDayStarted(lastHitTimestamp, currentTimestamp)) {
      await box.put('lastHitTimestamp', currentTimestamp);
      await box.put('apiHitCount', 20);
    }

    if (!categoriesLoaded) {
      // Load categories into the box
      await _loadCategories();

      await box.put('lastHitTimestamp', currentTimestamp);
      await box.put('apiHitCount', 20);
      // Set the flag to indicate that categories have been loaded
      await box.put('categoriesLoaded', true);
    }
  }

  static Future<void> openBoxes() async {
    await Hive.openBox<Expense>('expenses');
    await Hive.openBox<Category>('categories');
  }

  static Future<List<Category>> getAllCategories() async {
    final categoryBox = Hive.box<Category>('categories');
    return categoryBox.values.toList();
  }

  static Future<Map<dynamic, dynamic>> getAppSettings() async {
    final settingsBox = Hive.box<dynamic>('settings');
    return settingsBox.toMap();
  }

  static Future<void> updateApiHitCount(int newCount) async {
    final settingsBox = Hive.box<dynamic>('settings');
    await settingsBox.put('apiHitCount', newCount);
    await settingsBox.put('lastHitTimestamp', DateTime.now());
  }

  static Future<void> _loadCategories() async {
    final categoryBox = Hive.box<Category>('categories');
    // Add your categories here
    final List<Category> categories = [
      Category(name: 'Food', icon: 'food'),
      Category(name: 'Groceries', icon: 'groceries'),
      Category(name: 'Transport', icon: 'transport'),
      Category(name: 'Health', icon: 'health'),
      Category(name: 'Shopping', icon: 'shopping'),
      Category(name: 'Vacation', icon: 'vacation'),
      Category(name: 'Miscellaneous', icon: 'miscellaneous'),
      // Add more categories as needed
    ];
    for (final category in categories) {
      await categoryBox.add(category);
    }
  }

  static Future<List<Expense>> getAllTransactionsForCurrentMonth() async {
    final box = await Hive.openBox<Expense>('expenses');
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 0);
    final today = DateTime(now.year, now.month, now.day + 1);

    final List<Expense> expenses = box.values
        .where((expense) =>
            expense.timestamp.isAfter(firstDayOfMonth) &&
            expense.timestamp.isBefore(today))
        .toList();
    expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return expenses;
  }

  static Future<List<Expense>> getTransactionsBetweenDates(
      DateTime startDate, DateTime endDate) async {
    final box = await Hive.openBox<Expense>('expenses');

    final List<Expense> expenses = box.values
        .where((expense) =>
            expense.timestamp
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            expense.timestamp.isBefore(endDate.add(const Duration(days: 1))))
        .toList();

    expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return expenses;
  }

  static Future<List<Expense>> getAllTransactions() async {
    final expenseBox = Hive.box<Expense>('expenses');
    List<Expense> expenses = expenseBox.values.toList();
    expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return expenses;
  }

  static Future<List<Expense>> getTransactionsByDate(DateTime date) async {
    final Box<Expense> expenseBox = Hive.box<Expense>('expenses');

    final DateTime today = DateTime(date.year, date.month, date.day);

    List<Expense> todayTransactions = expenseBox.values.where((expense) {
      final DateTime expenseDate = DateTime(expense.timestamp.year,
          expense.timestamp.month, expense.timestamp.day);
      return expenseDate.isAtSameMomentAs(today);
    }).toList();

    todayTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return todayTransactions;
  }

  static Future<void> addExpense(Expense expense) async {
    final expenseBox = Hive.box<Expense>('expenses');
    await expenseBox.add(expense);
  }

  static Future<void> updateExpense(Expense expense) async {
    final expenseBox = Hive.box<Expense>('expenses');
    final expenseIndex =
        expenseBox.values.toList().indexWhere((e) => expense.id == e.id);
    if (expenseIndex != -1) {
      final updatedExpense = expenseBox.getAt(expenseIndex)?.copyWith(
          id: expense.id,
          title: expense.title,
          description: expense.description,
          amount: expense.amount,
          timestamp: expense.timestamp,
          paymentMode: expense.paymentMode,
          category: expense.category);
      if (updatedExpense != null) {
        expenseBox.putAt(expenseIndex, updatedExpense);
        log('Expense updated successfully: $updatedExpense');
      }
    }
  }

// Delete an expense
  static Future<void> deleteExpense(String id) async {
    final expenseBox = Hive.box<Expense>('expenses');
    final expenseIndex =
        expenseBox.values.toList().indexWhere((expense) => expense.id == id);
    if (expenseIndex != -1) {
      final deletedExpense = expenseBox.getAt(expenseIndex);
      expenseBox.deleteAt(expenseIndex);
      log('Expense deleted successfully: $deletedExpense');
    }
  }
}
