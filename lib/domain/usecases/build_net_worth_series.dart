import '../enums/currency_code.dart';
import '../models/time_series_point.dart';
import '../repositories/net_worth_snapshot_repository.dart';

/// Reads stored snapshots and emits a [TimeSeriesPoint] stream filtered by
/// [displayCurrency] and the requested look-back window.
class BuildNetWorthSeries {
  const BuildNetWorthSeries(this._repo);

  final NetWorthSnapshotRepository _repo;

  /// [from] inclusive, [to] exclusive. Pass null for [from] to include all.
  Stream<List<TimeSeriesPoint>> watch({
    required CurrencyCode displayCurrency,
    DateTime? from,
    DateTime? to,
  }) {
    return _repo.watchByCurrency(displayCurrency).map((snapshots) {
      return snapshots
          .where((s) =>
              (from == null || !s.capturedAt.isBefore(from)) &&
              (to == null || s.capturedAt.isBefore(to)))
          .map((s) => TimeSeriesPoint(at: s.capturedAt, value: s.netWorth))
          .toList();
    });
  }
}
