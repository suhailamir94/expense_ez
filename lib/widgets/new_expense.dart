import 'package:expense_ez/utils/constants.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:expense_ez/models/expense.dart';
import 'package:expense_ez/models/category.dart';
import 'package:expense_ez/provider/expense_provider.dart';
import 'package:expense_ez/provider/category_provider.dart.dart';
import 'package:expense_ez/provider/filter_provider.dart';
import 'package:expense_ez/utils/util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

DateFormat customFormatter = DateFormat('M/d/yyyy');

class Config {
  static const String apiKey = String.fromEnvironment('API_KEY');
}

class NewExpense extends ConsumerStatefulWidget {
  const NewExpense({super.key, this.newExpense});

  final Expense? newExpense;

  @override
  ConsumerState<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends ConsumerState<NewExpense>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  var _title = '';
  var _amount = '';
  final TextEditingController _dateTime =
      TextEditingController(text: customFormatter.format(DateTime.now()));
  final TextEditingController _amountController =
      TextEditingController(text: '');
  final TextEditingController _titleController =
      TextEditingController(text: '');
  var _description = '';
  int _selectedPaymentIndex = 0;
  String _category = '';
  List<Category> categories = [];
  bool _isHeld = false;
  late AudioRecorder audioRecord;
  bool isRecording = false;
  String audioPath = '';
  var geminiError = false;
  var _inProgress = false;
  late AnimationController _transitionController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      duration: const Duration(seconds: 2), // Adjust the duration as needed
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0), // Start off-screen to the left
      end: const Offset(1.5, 0), // Move off-screen to the right
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.linear,
    ));

    audioRecord = AudioRecorder();
    if (widget.newExpense != null) {
      setState(() {
        _titleController.text = widget.newExpense!.title;
        _amountController.text = widget.newExpense!.amount.toString();
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
    if (value != null && value != '' && value.trim().length > 20) {
      return 'Please enter only 10 characters';
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
    if (!valid || _category.isEmpty || categories.isEmpty) return;
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
        ref.read(filterProvider.notifier).setFilter(
              selectedFilterIndex: -1,
              // showAllExpenses: false,
              // selectedDate: DateTime.now(),
              // fromDate: DateTime(DateTime.now().year),
              // toDate: DateTime.now()
            );
        ref
            .read(expenseProvider.notifier)
            .loadTransactionsByDate(DateTime.now());
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

  Future<void> _sendVoiceNoteToGemini() async {
    try {
      _transitionController.repeat();
      setState(() {
        geminiError = false;
        _inProgress = true;
      });
// Access your API key as an environment variable (see "Set up your API key" above)
      const apiKey = Config.apiKey;
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = [
        Content.text(PROMPT),
        Content.data('audio/aac', await loadFileAudio(audioPath))
      ];
      final GenerateContentResponse response =
          await model.generateContent(content);
      print(
          'candidatesTokenCount: ${response.usageMetadata?.candidatesTokenCount}');
      print('promptTokenCount: ${response.usageMetadata?.promptTokenCount}');
      print('totalTokenCount: ${response.usageMetadata?.totalTokenCount}');
      print(response.text);
      _transitionController.stop();
      if (response.text != null) {
        if (response.text!.contains('Please share a clear audio')) {
          setState(() {
            geminiError = true;
          });
        }
        Map<String, dynamic> geminiResponse = jsonDecode(response.text!);
        _amountController.text = geminiResponse['amount'].toString();
        _titleController.text = geminiResponse['title'].toString();
        var categoryIndex =
            categories.indexWhere((e) => e.name == geminiResponse['category']);
        setState(() {
          if (categoryIndex > -1) _category = categories[categoryIndex].id;
          _inProgress = false;
          geminiError = false;
        });
      }
    } catch (e) {
      print('Error while getting data from gemini: $e');
      _transitionController.stop();
      setState(() {
        _inProgress = false;
        geminiError = true;
      });
    }
  }

  Future<String> _getPath() async {
    var dir = await getApplicationDocumentsDirectory();
    if (io.Platform.isAndroid) {
      dir = (await getExternalStorageDirectory())!;
    }
    return p.join(
      dir.path,
      'audio_recording.m4a',
    );
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start(const RecordConfig(), path: await _getPath());
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print('Error starting to reocrd: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        String? path = await audioRecord.stop();
        print('audio file path is: $path');
        setState(() {
          isRecording = false;
          audioPath = path!;
        });
        _sendVoiceNoteToGemini();
      }
    } catch (e) {
      print('Error stoping to reocrd: $e');
    }
  }

  void _onHoldStart() {
    startRecording();
    setState(() {
      _isHeld = true;
    });
  }

  void _onHoldEnd() {
    stopRecording();
    setState(() {
      _isHeld = false;
    });
  }

  void _setAmount(newValue) {
    _amount = newValue!;
  }

  @override
  void dispose() {
    audioRecord.dispose();
    _dateTime.dispose();
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                onSaved: _setAmount,
                // initialValue: _amount,
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
                controller: _titleController,
                onSaved: (newValue) => _title = newValue!,
                // initialValue: _title,
                maxLength: 20,
                validator: _validateTitle,
                decoration: InputDecoration(
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  hintText: 'Where did you pay? (Optional)', // Placeholder text
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
                        prefixIconColor: Theme.of(context).colorScheme.primary,
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
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Select category',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15.0),
                  SizedBox(
                    width: double.maxFinite,
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      runSpacing: 12.0,
                      // crossAxisAlignment: WrapCrossAlignment.end,
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
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTapDown: (_) => _onHoldStart(),
                            onTapUp: (_) => _onHoldEnd(),
                            onTapCancel: _onHoldEnd,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              transform: Matrix4.identity()
                                ..scale(_isHeld ? 1.2 : 1.0),
                              child: Icon(
                                Icons.mic,
                                size: 40.0,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                          // HoldIconButton()
                        ],
                      )
                    ],
                  ),
                  if (_isHeld)
                    Center(
                      child: Lottie.asset(
                        'assets/lottie/sound_wave.json', // Replace with your Lottie animation file
                        width: 200, // Adjust the size as needed
                        height: 100,
                        // fit: BoxFit.cover // Adjust the size as needed
                      ),
                    ),
                  if (geminiError && !_isHeld)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(
                          child: Text(
                        'Please share clear audio!',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      )),
                    ),
                  if (_inProgress)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(
                        child: SlideTransition(
                          position: _offsetAnimation,
                          child: Lottie.asset(
                            'assets/lottie/analysis.json', // Replace with your Lottie animation file
                            width: 200, // Adjust the size as needed
                            height: 70,
                            // fit: BoxFit.cover // Adjust the size as needed
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
