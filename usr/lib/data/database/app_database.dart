import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

// Tabla de Usuarios
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get role => text().withDefault(const Constant('DIGITADOR'))(); // ADMIN, ANALISTA, DIGITADOR
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Tabla de Registros PYP (Dinámicos)
class Records extends Table {
  TextColumn get uuid => text()(); // UUID único del registro
  TextColumn get teamId => text()(); // Identificador del equipo origen
  TextColumn get lifecycle => text()(); // PRIMERA_INFANCIA, VEJEZ, etc.
  TextColumn get jsonData => text()(); // Datos del formulario en JSON
  RealColumn get adherenceScore => real()(); // Puntaje calculado
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdBy => text()(); // Usuario que creó el registro

  @override
  Set<Column> get primaryKey => {uuid};
}

// Tabla de Auditoría / Logs Locales
class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()();
  TextColumn get details => text().nullable()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get user => text().nullable()();
}

@DriftDatabase(tables: [Users, Records, AuditLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Métodos de acceso a datos (DAOs simplificados)
  Future<int> createUser(UsersCompanion entry) => into(users).insert(entry);
  Future<User?> getUser(String username) => (select(users)..where((t) => t.username.equals(username))).getSingleOrNull();
  
  Future<int> createRecord(RecordsCompanion entry) => into(records).insert(entry);
  Future<List<Record>> getAllRecords() => select(records).get();
  
  // Consulta para Dashboard: Adherencia promedio por ciclo de vida
  Future<List<AdherenceStat>> getAdherenceStats() async {
    final query = select(records).join([]);
    // Aquí iría una consulta compleja agregada, simplificada por ahora:
    return []; 
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'rias_local.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

class AdherenceStat {
  final String lifecycle;
  final double average;
  AdherenceStat(this.lifecycle, this.average);
}
