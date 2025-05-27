import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class Skills extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class Locations extends Table {
  TextColumn get id => text()();
  TextColumn get address => text()();
  TextColumn get city => text()();
  TextColumn get details => text().nullable()();
  BoolColumn get university => boolean().withDefault(const Constant(false))();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  @override
  Set<Column> get primaryKey => {id};
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      fromDb.split(',').where((e) => e.isNotEmpty).toList();

  @override
  String toSql(List<String> value) => value.join(',');
}

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get userType => text().named('user_type')();
  TextColumn get recommendedEvents =>
      text().map(const StringListConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
