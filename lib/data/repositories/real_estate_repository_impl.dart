import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../domain/enums/currency_code.dart';
import '../../domain/models/real_estate_asset.dart';
import '../../domain/repositories/real_estate_repository.dart';
import '../database/app_database.dart';
import '../database/daos/real_estate_dao.dart';

class RealEstateRepositoryImpl implements RealEstateRepository {
  const RealEstateRepositoryImpl(this._dao);

  final RealEstateDao _dao;

  @override
  Stream<List<RealEstateAsset>> watchAll() => _dao
      .watchAll()
      .map((entries) => entries.map<RealEstateAsset>(_fromEntry).toList());

  @override
  Future<List<RealEstateAsset>> getAll() async {
    final entries = await _dao.getAll();
    return entries.map<RealEstateAsset>(_fromEntry).toList();
  }

  @override
  Future<RealEstateAsset?> getById(String id) async {
    final entry = await _dao.getById(id);
    return entry != null ? _fromEntry(entry) : null;
  }

  @override
  Future<void> save(RealEstateAsset asset) async {
    final companion = _toCompanion(asset);
    final updated = await _dao.updateOne(companion);
    if (!updated) {
      await _dao.insertOne(companion);
    }
  }

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  RealEstateAsset _fromEntry(RealEstateEntry e) => RealEstateAsset(
        id: e.id,
        name: e.name,
        address: e.address,
        estimatedValue: Decimal.parse(e.estimatedValue),
        purchasePrice: Decimal.parse(e.purchasePrice),
        purchaseDate: e.purchaseDate,
        currency: CurrencyCode.values.byName(e.currency),
        hasMortgage: e.hasMortgage,
        linkedLoanId: e.linkedLoanId,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  RealEstateCompanion _toCompanion(RealEstateAsset a) => RealEstateCompanion(
        id: Value(a.id),
        name: Value(a.name),
        address: Value(a.address),
        estimatedValue: Value(a.estimatedValue.toString()),
        purchasePrice: Value(a.purchasePrice.toString()),
        purchaseDate: Value(a.purchaseDate),
        currency: Value(a.currency.name),
        hasMortgage: Value(a.hasMortgage),
        linkedLoanId: Value(a.linkedLoanId),
        createdAt: Value(a.createdAt),
        updatedAt: Value(a.updatedAt),
      );
}
