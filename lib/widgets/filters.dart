// import 'dart:developer';

// import 'package:expense_ez/provider/expense_provider.dart';
// import 'package:expense_ez/provider/filter_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class Filters extends ConsumerStatefulWidget {
//   const Filters({super.key, required this.updateHomePage});

//   final Function updateHomePage;

//   @override
//   ConsumerState<Filters> createState() => _FiltersState();
// }

// class _FiltersState extends ConsumerState<Filters> {
//   final List<String> _options = [
//     'Show All Expenses',
//     'Current Month Expenses',
//     'Expenses for a particular date',
//     'Show expenses b/w 2 dates'
//   ];

//   DateTime? _selectedDate;
//   DateTime? _fromDate;
//   DateTime? _toDate;

//   @override
//   Widget build(BuildContext context) {
//     final Map<String, dynamic> filters = ref.watch(filterProvider);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ...List.generate(
//             _options.length,
//             (index) => SwitchListTile(
//               title: Text(_options[index]),
//               value: filters['selectedFilterIndex'] == index,
//               onChanged: (value) {
//                 ref.read(filterProvider.notifier).setFilter(
//                       selectedFilterIndex: value ? index : -1,
//                       showAllExpenses: filters['showAllExpenses'],
//                       selectedDate: filters['selectedDate'],
//                       fromDate: filters['fromDate'],
//                       toDate: filters['toDate'],
//                     );
//                 if ([0, 1].contains(index) ||
//                     ([2, 3].contains(index) && !value)) {
//                   widget.updateHomePage();
//                   Navigator.pop(context);
//                 }
//               },
//             ),
//           ),
//           if (filters['selectedFilterIndex'] == 2) ...[
//             const SizedBox(
//               height: 20,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text('Select Date:'),
//                 const SizedBox(width: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     final DateTime? pickedDate = await showDatePicker(
//                       context: context,
//                       initialDate: filters['selectedDate'],
//                       firstDate: DateTime(DateTime.now().year - 1),
//                       lastDate: DateTime.now(),
//                     );

//                     if (pickedDate != null) {
//                       setState(() {
//                         _selectedDate = pickedDate;
//                       });
//                     }
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey),
//                     ),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: Text((_selectedDate ?? filters['selectedDate'])
//                         .toString()
//                         .substring(0, 10)),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           if (filters['selectedFilterIndex'] == 3) ...[
//             const SizedBox(
//               height: 20,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('From:',
//                     style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                         color: Theme.of(context).colorScheme.primary,
//                         fontWeight: FontWeight.w700)),
//                 const SizedBox(width: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     final DateTime? pickedFromDate = await showDatePicker(
//                       context: context,
//                       initialDate: filters['fromDate'] as DateTime,
//                       firstDate: DateTime(DateTime.now().year - 1),
//                       lastDate: DateTime.now(),
//                     );
//                     if (pickedFromDate != null) {
//                       setState(() {
//                         _fromDate = pickedFromDate;
//                       });
//                     }
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey),
//                     ),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: Text((_fromDate ?? filters['fromDate'] as DateTime)
//                         .toString()
//                         .substring(0, 10)),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('To:',
//                     style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                         color: Theme.of(context).colorScheme.primary,
//                         fontWeight: FontWeight.w700)),
//                 const SizedBox(width: 40),
//                 GestureDetector(
//                   onTap: () async {
//                     final DateTime? pickedToDate = await showDatePicker(
//                       context: context,
//                       initialDate: filters['toDate'] as DateTime,
//                       firstDate: DateTime(DateTime.now().year - 1),
//                       lastDate: DateTime.now(),
//                     );
//                     if (pickedToDate != null) {
//                       setState(() {
//                         _toDate = pickedToDate;
//                       });
//                     }
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey),
//                     ),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: Text((_toDate ?? filters['toDate'] as DateTime)
//                         .toString()
//                         .substring(0, 10)),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           const SizedBox(
//             height: 20,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               TextButton(
//                   onPressed: () {
//                     ref.read(filterProvider.notifier).setFilter(
//                         selectedFilterIndex: -1,
//                         showAllExpenses: false,
//                         selectedDate: DateTime.now(),
//                         fromDate: DateTime(DateTime.now().year),
//                         toDate: DateTime.now());
//                     ref
//                         .read(expenseProvider.notifier)
//                         .loadTransactionsByDate(DateTime.now());
//                     Navigator.pop(context);
//                   },
//                   child: Text(
//                     'Reset',
//                     style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                         color: Theme.of(context).colorScheme.primary,
//                         fontWeight: FontWeight.w700),
//                   )),
//               if ([2, 3].contains(filters['selectedFilterIndex']))
//                 TextButton(
//                     child: Text(
//                       'Submit',
//                       style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                           color: Theme.of(context).colorScheme.primary,
//                           fontWeight: FontWeight.w700),
//                     ),
//                     onPressed: () {
//                       ref.read(filterProvider.notifier).setFilter(
//                             selectedFilterIndex: filters['selectedFilterIndex'],
//                             showAllExpenses: filters['showAllExpenses'],
//                             selectedDate:
//                                 _selectedDate ?? filters['selectedDate'],
//                             fromDate: _fromDate ?? filters['fromDate'],
//                             toDate: _toDate ?? filters['toDate'],
//                           );
//                       widget.updateHomePage();
//                       Navigator.pop(context);
//                     })
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
