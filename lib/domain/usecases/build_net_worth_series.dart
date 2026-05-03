import '../enums/currency_code.dart';
import '../models/net_worth_snapshot.dart';
import '../models/time_series_point.dart';
import '../repositories/net_worth_snapshot_repository.dart';

/// Reads stored snapshots and emits a [TimeSeriesPoint] stream filtered by
/// [displayCurrency] and the requested look-back window.
class BuildNetWorthSeries {
  const BuildNetWorthSeries(this._repo);

  final NetWorthSnapshotRepository _repo;

  /// [from] inclusive, [to] exclusive. Pass null for [from] to include all.
  Future<List<TimeSeriesPoint>> build({
    required CurrencyCode displayCurrency,
    DateTime? from,
    DateTime? to,
  }) async {
    final snapshots = await _repo.getAll();
    return _build(
      snapshots,
      displayCurrency: displayCurrency,
      from: from,
      to: to,
    );
  }

  Stream<List<TimeSeriesPoint>> watch({
    required CurrencyCode displayCurrency,
    DateTime? from,
    DateTime? to,
  }) {
    return _repo.watchByCurrency(displayCurrency).map((snapshots) {
      return _build(
        snapshots,
        displayCurrency: displayCurrency,
        from: from,
        to: to,
      );
    });
  }

  List<TimeSeriesPoint> _build(
    List<NetWorthSnapshot> snapshots, {
    required CurrencyCode displayCurrency,
    DateTime? from,
    DateTime? to,
  }) {
    final sorted = snapshots
        .where((s) =>
            s.displayCurrency == displayCurrency &&
            (from == null || !s.capturedAt.isBefore(from)) &&
            (to == null || s.capturedAt.isBefore(to)))
        .toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

    return sorted
        .map((s) => TimeSeriesPoint(at: s.capturedAt, value: s.netWorth))
        .toList();
  }
}
