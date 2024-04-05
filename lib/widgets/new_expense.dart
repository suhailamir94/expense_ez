import 'dart:developer';

import 'package:expense_ez/models/expense.dart';
import 'package:expense_ez/models/category.dart';
import 'package:expense_ez/provider/expense_provider.dart';
import 'package:expense_ez/provider/category_provider.dart.dart';
import 'package:expense_ez/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

DateFormat customFormatter = DateFormat('M/d/yyyy');

class NewExpense extends ConsumerStatefulWidget {
  const NewExpense({super.key, this.newExpense});

  final Expense? newExpense;

  @override
  ConsumerState<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends ConsumerState<NewExpense> {
  final TextEditingController _dateTime =
      TextEditingController(text: customFormatter.format(DateTime.now()));
  final _form = GlobalKey<FormState>();
  var _title = '';
  var _amount = '';
  var _description = '';
  int _selectedPaymentIndex = 0;
  String _category = '';
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    if (widget.newExpense != null) {
      setState(() {
        _title = widget.newExpense!.title;
        _amount = widget.newExpense!.amount.toString();
        _description = widget.newExpense!.description;
        _dateTime.text = formatter.format(widget.newExpense!.timestamp);
        _selectedPaymentIndex =
            widget.newExpense!.paymentMode == PaymentMode.cash ? 0 : 1;
        _category = widget.newExpense!.category.id;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final List<Category> loadedCategories = ref.watch(categoryProvider);
    setState(() {
      categories = loadedCategories;
      if (_category.isEmpty) {
        _category =
            loadedCategories.firstWhere((e) => e.name == 'Miscellaneous').id;
      }
    });
  }

  String? _validateTitle(String? value) {
    if (value != null && value != '' && value.trim().length > 10) {
      return 'Please enter atleast 4 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value != null && value.trim().length > 50) {
      return 'Please enter less than 50 characters';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null ||
        value.trim().length > 10 ||
        int.tryParse(value.trim()) == null) {
      return 'Not a valid Amount';
    }
    return null;
  }

  void _openDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);

    final pickedDate = await showDatePicker(
        context: context,
        firstDate: firstDate,
        initialDate: now,
        lastDate: now);

    setState(() {
      if (pickedDate != null) {
        _dateTime.text = formatter.format(pickedDate);
      }
    });
  }

  void _submitExpense() async {
    final valid = _form.currentState!.validate();
    if (!valid || _category.isEmpty) return;
    _form.currentState!.save();

    String snackbarMessage = widget.newExpense != null
        ? 'Transaction edited!'
        : 'Transaction added!';

    Category category = categories.firstWhere((e) => e.id == _category);
    PaymentMode paymentMode =
        _selectedPaymentIndex == 0 ? PaymentMode.cash : PaymentMode.online;
    Expense expense = Expense(
        id: widget.newExpense?.id,
        title: _title,
        amount: int.parse(_amount),
        timestamp: customFormatter.parse(_dateTime.text),
        description: _description,
        paymentMode: paymentMode,
        category: category);

    try {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (widget.newExpense != null) {
        await ref.read(expenseProvider.notifier).updateExpense(expense);
      } else {
        await ref.read(expenseProvider.notifier).addExpense(expense);
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(snackbarMessage),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ));
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to add Expense!'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log(_category);
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  onSaved: (newValue) => _amount = newValue!,
                  initialValue: _amount,
                  clipBehavior: Clip.hardEdge,
                  autofocus: true,
                  maxLength: 10,
                  validator: _validateAmount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'How much did you pay?',
                    hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .primary), // Placeholder text
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                      borderSide: BorderSide.none, // No border
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onSaved: (newValue) => _title = newValue!,
                  initialValue: _title,
                  maxLength: 10,
                  validator: _validateTitle,
                  decoration: InputDecoration(
                    hintStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    hintText:
                        'Where did you pay? (Optional)', // Placeholder text
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                      borderSide: BorderSide.none, // No border
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onSaved: (newValue) => _description = newValue!,
                  initialValue: _description,
                  validator: _validateDescription,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    hintText: 'Add a note. (Optional)', // Placeholder text
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                      borderSide: BorderSide.none, // No border
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateTime,
                        onTap: _openDatePicker,
                        clipBehavior: Clip.hardEdge,
                        keyboardType: TextInputType.none,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_month_rounded),
                          prefixIconColor:
                              Theme.of(context).colorScheme.primary,
                          // Placeholder text
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 16.0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(20.0), // Rounded corners
                            borderSide: BorderSide.none, // No border
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ...PaymentMode.values.asMap().entries.map(
                      (entry) {
                        final int index = entry.key;
                        final PaymentMode mode = entry.value;

                        // Create a widget for each fruit
                        return ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(
                              () {
                                _selectedPaymentIndex = index;
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedPaymentIndex == index
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: index == 0
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(30.0),
                                      bottomLeft: Radius.circular(30.0),
                                    )
                                  : const BorderRadius.only(
                                      topRight: Radius.circular(30.0),
                                      bottomRight: Radius.circular(30.0),
                                    ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 12.0),
                            child: Text(
                              capitalizeFirst(mode.name),
                              style: TextStyle(
                                  color: _selectedPaymentIndex == index
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                  fontSize: 16),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select category',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: categories.map(
                        (category) {
                          return ElevatedButton(
                            onPressed: _category.isNotEmpty
                                ? () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _category = category.id;
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _category == category.id
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                  color: _category == category.id
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _submitExpense,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Text(
                            widget.newExpense == null ? 'Add' : 'Update',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
