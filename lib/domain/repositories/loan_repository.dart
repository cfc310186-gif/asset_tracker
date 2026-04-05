import '../models/loan.dart';

abstract interface class LoanRepository {
  Stream<List<Loan>> watchAll();
  Future<List<Loan>> getAll();
  Future<Loan?> getById(String id);
  Future<void> save(Loan loan);
  Future<void> delete(String id);
}
