import '../../domain/models/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../supabase/supabase_mappers.dart';
import '../supabase/supabase_repository_base.dart';

class SupabaseLoanRepository extends SupabaseRepositoryBase
    implements LoanRepository {
  const SupabaseLoanRepository(super.client);

  static const _table = 'loans';

  @override
  Stream<List<Loan>> watchAll() {
    return watchByPolling(getAll);
  }

  @override
  Future<List<Loan>> getAll() async {
    final rows = await table(_table)
        .select()
        .isFilter('deleted_at', null)
        .order('updated_at', ascending: true);
    return _rowList(rows).map(loanFromSupabaseRow).toList();
  }

  @override
  Future<Loan?> getById(String id) async {
    final row = await table(_table)
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    return row == null ? null : loanFromSupabaseRow(row);
  }

  @override
  Future<void> save(Loan loan) async {
    await table(_table).upsert(loanToSupabaseRow(loan, userId: currentUserId));
  }

  @override
  Future<void> delete(String id) async {
    await table(_table).update(softDeletePayload()).eq('id', id);
  }
}

List<SupabaseRow> _rowList(Object? rows) =>
    (rows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
