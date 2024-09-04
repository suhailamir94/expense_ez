import 'dart:developer';

import 'package:expense_ez/db/hive_db.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends StateNotifier<Map<dynamic, dynamic>> {
  SettingsNotifier() : super({});

  Future<void> loadData() async {
    try {
      state = await HiveDB.getAppSettings();
    } catch (error) {
      log('Error fetching all settings ${error.toString()}');
    }
  }

  Future<void> updateApiHitCount(int newCount) async {
    try {
      await HiveDB.updateApiHitCount(newCount);
      state = {...state, 'apiHitCount': newCount};
    } catch (error) {
      log('Error updating apiHitCount setting ${error.toString()}');
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Map<dynamic, dynamic>>(
        (ref) => SettingsNotifier());
