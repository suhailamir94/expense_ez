import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterNotifier extends StateNotifier<Map<String, Object>> {
  FilterNotifier()
      : super({'showAllExpenses': false, 'selectedDate': DateTime.now()});

  void setFilter(bool showAllExpenses, DateTime selectedDate) {
    state = {'showAllExpenses': showAllExpenses, 'selectedDate': selectedDate};
  }
}

final filterProvider =
    StateNotifierProvider<FilterNotifier, Map<String, Object>>(
        (ref) => FilterNotifier());
