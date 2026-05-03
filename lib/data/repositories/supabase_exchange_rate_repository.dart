import '../../domain/enums/currency_code.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../supabase/supabase_mappers.dart';
import '../supabase/supabase_repository_base.dart';

class SupabaseExchangeRateRepository extends SupabaseRepositoryBase
    implements ExchangeRateRepository {
  const SupabaseExchangeRateRepository(super.client);

  static const _table = 'exchange_rates';

  @override
  Stream<List<ExchangeRate>> watchAll() {
    return watchByPolling(getAll);
  }

  @override
  Future<List<ExchangeRate>> getAll() async {
    final rows = await table(_table)
        .select()
        .isFilter('deleted_at', null)
        .order('fetched_at', ascending: false);
    return _rowList(rows).map(exchangeRateFromSupabaseRow).toList();
  }

  @override
  Future<ExchangeRate?> getById(String id) async {
    final row = await table(_table)
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    return row == null ? null : exchangeRateFromSupabaseRow(row);
  }

  @override
  Future<ExchangeRate?> getByPair(
    CurrencyCode from,
    CurrencyCode to,
  ) async {
    final row = await table(_table)
        .select()
        .eq('from_currency', from.name)
        .eq('to_currency', to.name)
        .isFilter('deleted_at', null)
        .order('fetched_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : exchangeRateFromSupabaseRow(row);
  }

  @override
  Future<void> save(ExchangeRate rate) async {
    await table(_table).upsert(
      exchangeRateToSupabaseRow(rate, userId: currentUserId),
    );
  }

  @override
  Future<void> delete(String id) async {
    await table(_table).update(softDeletePayload()).eq('id', id);
  }
}

List<SupabaseRow> _rowList(Object? rows) =>
    (rows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
