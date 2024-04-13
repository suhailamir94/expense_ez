import 'package:expense_ez/db/hive_db.dart';
import 'package:flutter/material.dart';

import 'package:expense_ez/screens/tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDB.initHive();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MaterialApp(
        title: 'ExpenseEz',
        theme: ThemeData(
            fontFamily: GoogleFonts.roboto().fontFamily,
            colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color.fromARGB(255, 72, 223, 157))
                .copyWith(error: const Color.fromARGB(255, 215, 65, 55))),
        home: const TabsScreen(),
      ),
    );
  }
}
