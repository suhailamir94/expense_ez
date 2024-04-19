import 'package:expense_ez/provider/filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<String> filters = ['Today', 'Week', 'Month', 'Year'];

class NewFilters extends ConsumerStatefulWidget {
  const NewFilters({super.key, required this.updateHomePage});

  final Function updateHomePage;

  @override
  ConsumerState<NewFilters> createState() => _NewFiltersState();
}

class _NewFiltersState extends ConsumerState<NewFilters> {
  int selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < filters.length; i++)
          Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              padding: selectedFilterIndex == i
                  ? const EdgeInsets.symmetric(horizontal: 10.0)
                  : null,
              decoration: selectedFilterIndex == i
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Theme.of(context).colorScheme.primary,
                      boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 3,
                            offset: Offset(0, 3),
                          )
                        ])
                  : null,
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilterIndex = i;
                    });
                    ref
                        .read(filterProvider.notifier)
                        .setFilter(selectedFilterIndex: i);
                    widget.updateHomePage();
                  },
                  child: Text(
                    filters[i],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedFilterIndex == i
                            ? Colors.white
                            : Theme.of(context).primaryColor),
                  ))),
      ],
    );
  }
}
