import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/real_estate_table.dart';

part 'real_estate_dao.g.dart';

@DriftAccessor(tables: [RealEstate])
class RealEstateDao extends DatabaseAccessor<AppDatabase>
    with _$RealEstateDaoMixin {
  RealEstateDao(super.db);

  Stream<List<RealEstateEntry>> watchAll() => select(realEstate).watch();

  Future<List<RealEstateEntry>> getAll() => select(realEstate).get();

  Future<RealEstateEntry?> getById(String id) =>
      (select(realEstate)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertOne(RealEstateCompanion entry) =>
      into(realEstate).insert(entry);

  Future<bool> updateOne(RealEstateCompanion entry) =>
      update(realEstate).replace(entry);

  Future<int> deleteById(String id) =>
      (delete(realEstate)..where((t) => t.id.equals(id))).go();
}
