import 'dart:developer';

import 'package:expense_ez/models/expense.dart';
import 'package:expense_ez/models/category.dart';
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

    if (!categoriesLoaded) {
      // Load categories into the box
      await _loadCategories();

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

  static Future<List<Expense>> getAllExpenses() async {
    final expenseBox = Hive.box<Expense>('expenses');
    return expenseBox.values.toList();
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
