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
