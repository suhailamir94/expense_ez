import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

const uuid = Uuid();

@HiveType(typeId: 2)
class Category {
  Category({required this.name, required this.icon}) : id = uuid.v4();

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon;
}
