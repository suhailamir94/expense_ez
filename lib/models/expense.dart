import 'package:expense_ez/models/category.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'expense.g.dart';

const uuid = Uuid();
final formatter = DateFormat.yMd();

@HiveType(typeId: 0) // Specify the type ID for the enum
enum PaymentMode {
  @HiveField(0)
  cash,
  @HiveField(1)
  online
}

@HiveType(typeId: 1)
class Expense {
  Expense(
      {String? id,
      required this.title,
      required this.timestamp,
      required this.description,
      required this.amount,
      required this.paymentMode,
      required this.category})
      : id = id ?? uuid.v4();

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final PaymentMode paymentMode;

  @HiveField(5)
  final Category category;

  @HiveField(6)
  final int amount;

  // Add a factory constructor to create Expense objects without specifying 'id'
  Expense copyWith({
    required String id,
    required String title,
    required DateTime timestamp,
    required String description,
    required PaymentMode paymentMode,
    required Category category,
    required int amount,
  }) {
    return Expense(
        id: id,
        title: title,
        timestamp: timestamp,
        description: description,
        paymentMode: paymentMode,
        category: category,
        amount: amount);
  }

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, description: $description, timestamp: ${timestamp.toString()}, category: $category)';
  }

  get formattedDate {
    DateFormat formatter = DateFormat('MM-dd-yyyy');
    return formatter.format(timestamp);
  }
}
