import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../domain/enums/currency_code.dart';
import '../../domain/models/net_worth_snapshot.dart';
import '../../domain/repositories/net_worth_snapshot_repository.dart';
import '../database/app_database.dart';
import '../database/daos/net_worth_snapshot_dao.dart';

class NetWorthSnapshotRepositoryImpl implements NetWorthSnapshotRepository {
  const NetWorthSnapshotRepositoryImpl(this._dao);

  final NetWorthSnapshotDao _dao;

  @override
  Future<void> upsert(NetWorthSnapshot snapshot) async {
    await _dao.upsert(_toCompanion(snapshot));
  }

  @override
  Future<List<NetWorthSnapshot>> getAll() async {
    final entries = await _dao.getAll();
    return entries.map<NetWorthSnapshot>(_fromEntry).toList();
  }

  @override
  Stream<List<NetWorthSnapshot>> watchAll() => _dao
      .watchAll()
      .map((entries) => entries.map<NetWorthSnapshot>(_fromEntry).toList());

  @override
  Stream<List<NetWorthSnapshot>> watchByCurrency(CurrencyCode currency) => _dao
      .watchByCurrency(currency.name)
      .map((entries) => entries.map<NetWorthSnapshot>(_fromEntry).toList());

  NetWorthSnapshot _fromEntry(NetWorthSnapshotEntry e) {
    final raw = jsonDecode(e.breakdownJson) as Map<String, dynamic>;
    final breakdown = <String, Decimal>{
      for (final entry in raw.entries)
        entry.key: Decimal.parse(entry.value.toString()),
    };
    return NetWorthSnapshot(
      id: e.id,
      capturedAt: e.capturedAt,
      displayCurrency: CurrencyCode.values.byName(e.displayCurrency),
      totalAssets: Decimal.parse(e.totalAssets),
      totalLiabilities: Decimal.parse(e.totalLiabilities),
      netWorth: Decimal.parse(e.netWorth),
      breakdown: breakdown,
      createdAt: e.createdAt,
    );
  }

  NetWorthSnapshotsCompanion _toCompanion(NetWorthSnapshot s) {
    final json = jsonEncode({
      for (final entry in s.breakdown.entries) entry.key: entry.value.toString(),
    });
    return NetWorthSnapshotsCompanion(
      id: Value(s.id),
      capturedAt: Value(s.capturedAt),
      displayCurrency: Value(s.displayCurrency.name),
      totalAssets: Value(s.totalAssets.toString()),
      totalLiabilities: Value(s.totalLiabilities.toString()),
      netWorth: Value(s.netWorth.toString()),
      breakdownJson: Value(json),
      createdAt: Value(s.createdAt),
    );
  }
}
