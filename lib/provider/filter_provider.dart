import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterNotifier extends StateNotifier<Map<String, dynamic>> {
  FilterNotifier()
      : super({
          'selectedFilterIndex': -1,
          'showAllExpenses': false,
          'selectedDate': DateTime.now(),
          'fromDate':
              DateTime(DateTime.now().year - 1, DateTime.now().month - 1),
          'toDate': DateTime.now()
        });

  void setFilter(
      {required int selectedFilterIndex,
      required bool showAllExpenses,
      required DateTime selectedDate,
      required DateTime fromDate,
      required DateTime toDate}) {
    state = {
      'selectedFilterIndex': selectedFilterIndex,
      'showAllExpenses': showAllExpenses,
      'selectedDate': selectedDate,
      'fromDate': fromDate,
      'toDate': toDate
    };
  }
}

final filterProvider =
    StateNotifierProvider<FilterNotifier, Map<String, dynamic>>(
        (ref) => FilterNotifier());
