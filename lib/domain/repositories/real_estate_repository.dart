import '../models/real_estate_asset.dart';

abstract interface class RealEstateRepository {
  Stream<List<RealEstateAsset>> watchAll();
  Future<List<RealEstateAsset>> getAll();
  Future<RealEstateAsset?> getById(String id);
  Future<void> save(RealEstateAsset asset);
  Future<void> delete(String id);
}
