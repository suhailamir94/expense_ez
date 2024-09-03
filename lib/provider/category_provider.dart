import 'dart:developer';

import 'package:expense_ez/db/hive_db.dart';
import 'package:expense_ez/models/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]);

  Future<void> loadData() async {
    try {
      state = await HiveDB.getAllCategories();
    } catch (error) {
      log('Error fetching all categories ${error.toString()}');
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>(
        (ref) => CategoryNotifier());
