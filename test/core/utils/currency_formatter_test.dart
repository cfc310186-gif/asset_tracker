import 'package:asset_tracker/core/utils/currency_formatter.dart';
import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats TWD unit prices with decimals when present', () {
    expect(
      CurrencyFormatter.formatUnitPrice(
        Decimal.parse('123.45'),
        CurrencyCode.twd,
      ),
      'NT\$123.45',
    );
    expect(
      CurrencyFormatter.format(Decimal.parse('123.45'), CurrencyCode.twd),
      'NT\$123',
    );
  });
}
