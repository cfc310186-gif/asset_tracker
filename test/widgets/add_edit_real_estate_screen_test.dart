import 'package:asset_tracker/presentation/real_estate/add_edit_real_estate_screen.dart';
import 'package:asset_tracker/providers/repository_providers.dart';
import 'package:asset_tracker/providers/usecase_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../usecases/_fakes.dart';

void main() {
  testWidgets('saving a new real estate asset uses a cloud-safe address',
      (tester) async {
    final realEstateRepo = FakeRealEstateRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockRepositoryProvider.overrideWithValue(FakeStockRepository()),
          realEstateRepositoryProvider.overrideWithValue(realEstateRepo),
          loanRepositoryProvider.overrideWithValue(FakeLoanRepository()),
          cashRepositoryProvider.overrideWithValue(FakeCashRepository()),
          exchangeRateRepositoryProvider.overrideWithValue(
            FakeExchangeRateRepository(),
          ),
          netWorthSnapshotRepositoryProvider.overrideWithValue(
            FakeSnapshotRepository(),
          ),
          portfolioRevisionProvider.overrideWith((ref) => 0),
        ],
        child: const MaterialApp(
          home: AddEditRealEstateScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Cloud Home');
    await tester.enterText(find.byType(TextFormField).at(1), '9000000');
    await tester.enterText(find.byType(TextFormField).at(2), '7500000');

    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(realEstateRepo.items, hasLength(1));
    expect(realEstateRepo.items.single.address, '-');
    expect(realEstateRepo.items.single.purchaseDate, isNotEmpty);
  });
}
