import 'dart:developer';

import 'package:expense_ez/screens/home.dart';
import 'package:expense_ez/screens/insights.dart';
import 'package:expense_ez/widgets/filters.dart';
import 'package:expense_ez/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;
  bool _updateChildWidget = true;
  final List<String> options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];
  List<bool> selections = [false, false, false, false];

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _onModalStateChange() {
    setState(() {
      _updateChildWidget = !_updateChildWidget;
    });
  }

  bool isChecked = false;
  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Filters(
          updateHomePage: _onModalStateChange,
        );
      },
    );
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
        useSafeArea: true,
        context: context,
        builder: (ctx) => const NewExpense(),
        isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    Widget activeScreen = Home(
      updateWidget:
          _updateChildWidget, // this is a hack to reload child widget so it could call didUpdateWidget, bad approach, should have done using props/dependencies only
    );

    if (_selectedPageIndex == 1) {
      activeScreen = const Insights();
    }

    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          _showModalBottomSheet(context);
                        },
                        icon: Image.asset('assets/icons/filter_icon.png')),
                    activeScreen
                  ]))),
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 235, 242, 238),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.wallet_rounded), label: 'Expenses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: 'Insights'),
        ],
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        elevation: 30,
        iconSize: 30,
      ),
      floatingActionButton: _selectedPageIndex == 0
          ? FloatingActionButton(
              onPressed: _openAddExpenseOverlay,
              elevation: 8, // Set elevation to create shadow
              backgroundColor: const Color.fromARGB(255, 110, 241, 180),
              child: const Icon(Icons.add), // Customize button color
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Position of the button
    );
  }
}
