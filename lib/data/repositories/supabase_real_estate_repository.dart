import '../../domain/models/real_estate_asset.dart';
import '../../domain/repositories/real_estate_repository.dart';
import '../supabase/supabase_mappers.dart';
import '../supabase/supabase_repository_base.dart';

class SupabaseRealEstateRepository extends SupabaseRepositoryBase
    implements RealEstateRepository {
  const SupabaseRealEstateRepository(super.client);

  static const _table = 'real_estate_assets';

  @override
  Stream<List<RealEstateAsset>> watchAll() {
    return watchByPolling(getAll);
  }

  @override
  Future<List<RealEstateAsset>> getAll() async {
    final rows = await table(_table)
        .select()
        .isFilter('deleted_at', null)
        .order('updated_at', ascending: true);
    return _rowList(rows).map(realEstateAssetFromSupabaseRow).toList();
  }

  @override
  Future<RealEstateAsset?> getById(String id) async {
    final row = await table(_table)
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    return row == null ? null : realEstateAssetFromSupabaseRow(row);
  }

  @override
  Future<void> save(RealEstateAsset asset) async {
    await table(_table).upsert(
      realEstateAssetToSupabaseRow(asset, userId: currentUserId),
    );
  }

  @override
  Future<void> delete(String id) async {
    await table(_table).update(softDeletePayload()).eq('id', id);
  }
}

List<SupabaseRow> _rowList(Object? rows) =>
    (rows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
