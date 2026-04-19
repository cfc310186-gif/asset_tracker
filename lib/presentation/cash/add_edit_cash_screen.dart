import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/currency_formatter.dart';
import '../../domain/enums/currency_code.dart';
import '../../domain/models/cash_account.dart';
import '../../domain/models/transaction.dart';
import '../../providers/repository_providers.dart';
import '../../providers/usecase_providers.dart';

class AddEditCashScreen extends ConsumerStatefulWidget {
  const AddEditCashScreen({super.key, this.account});

  final CashAccount? account;

  @override
  ConsumerState<AddEditCashScreen> createState() => _AddEditCashScreenState();
}

class _AddEditCashScreenState extends ConsumerState<AddEditCashScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _annualRateController;
  late CurrencyCode _selectedCurrency;
  bool _isSaving = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _nameController = TextEditingController(text: a?.name ?? '');
    _balanceController =
        TextEditingController(text: a?.balance.toString() ?? '');
    // Display rate as percentage (e.g. 0.015 -> "1.5").
    final rateDisplay = a?.annualRate != null
        ? (a!.annualRate! * Decimal.fromInt(100)).toStringAsFixed(2)
        : '';
    _annualRateController = TextEditingController(text: rateDisplay);
    _selectedCurrency = a?.currency ?? CurrencyCode.twd;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _annualRateController.dispose();
    super.dispose();
  }

  Decimal? get _parsedAnnualRate {
    final text = _annualRateController.text.trim();
    if (text.isEmpty) return null;
    try {
      return (Decimal.parse(text) / Decimal.fromInt(100))
          .toDecimal(scaleOnInfinitePrecision: 10);
    } on FormatException {
      return null;
    }
  }

  Decimal? get _previewMonthlyInterest {
    final rate = _parsedAnnualRate;
    if (rate == null) return null;
    final balanceText = _balanceController.text.trim();
    if (balanceText.isEmpty) return null;
    try {
      final balance = Decimal.parse(balanceText);
      if (balance <= Decimal.zero) return null;
      return (balance * rate / Decimal.fromInt(12))
          .toDecimal(scaleOnInfinitePrecision: 10);
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '編輯現金帳戶' : '新增現金帳戶'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '帳戶名稱 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '請輸入帳戶名稱' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: '餘額 *',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validateBalance,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _annualRateController,
                decoration: const InputDecoration(
                  labelText: '年利率 (%)',
                  hintText: '例：1.5 代表 1.5%（可留空）',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validateOptionalRate,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.done,
              ),
              if (_previewMonthlyInterest != null) ...[
                const SizedBox(height: 8),
                _MonthlyInterestPreview(
                  interest: _previewMonthlyInterest!,
                  currency: _selectedCurrency,
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<CurrencyCode>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: '幣別',
                  border: OutlineInputBorder(),
                ),
                items: CurrencyCode.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCurrency = v);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('儲存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateBalance(String? v) {
    if (v == null || v.trim().isEmpty) return '請輸入餘額';
    try {
      final d = Decimal.parse(v.trim());
      if (d <= Decimal.zero) return '餘額必須大於 0';
    } on FormatException {
      return '請輸入有效的數字';
    }
    return null;
  }

  String? _validateOptionalRate(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    try {
      final d = Decimal.parse(v.trim());
      if (d < Decimal.zero) return '利率不能為負';
      if (d > Decimal.fromInt(100)) return '利率不能超過 100%';
    } on FormatException {
      return '請輸入有效的數字';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final balance = Decimal.parse(_balanceController.text.trim());
      final now = DateTime.now();
      final existing = widget.account;

      final account = CashAccount(
        id: existing?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        // Bank name field removed from UI; preserve existing record's value
        // on edit so prior data isn't wiped.
        bankName: existing?.bankName,
        balance: balance,
        currency: _selectedCurrency,
        annualRate: _parsedAnnualRate,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      await ref.read(cashRepositoryProvider).save(account);

      // Record the mutation as an audit entry so reports can trace changes.
      final oldBalance = existing?.balance ?? Decimal.zero;
      final delta = account.balance - oldBalance;
      if (existing == null) {
        await ref.read(recordTransactionProvider).execute(
              assetType: TransactionAssetType.cash,
              assetId: account.id,
              kind: TransactionKind.deposit,
              amount: account.balance,
              currency: account.currency,
            );
      } else if (delta != Decimal.zero) {
        await ref.read(recordTransactionProvider).execute(
              assetType: TransactionAssetType.cash,
              assetId: account.id,
              kind: delta > Decimal.zero
                  ? TransactionKind.deposit
                  : TransactionKind.withdraw,
              amount: delta,
              currency: account.currency,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? '帳戶已更新' : '帳戶已新增')),
        );
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('儲存失敗：$e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _MonthlyInterestPreview extends StatelessWidget {
  const _MonthlyInterestPreview({
    required this.interest,
    required this.currency,
  });

  final Decimal interest;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(
            Icons.savings_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '每月利息約 ${CurrencyFormatter.format(interest, currency)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
