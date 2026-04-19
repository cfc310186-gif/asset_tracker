import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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
  late final TextEditingController _bankController;
  late final TextEditingController _balanceController;
  late CurrencyCode _selectedCurrency;
  bool _isSaving = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _nameController = TextEditingController(text: a?.name ?? '');
    _bankController = TextEditingController(text: a?.bankName ?? '');
    _balanceController =
        TextEditingController(text: a?.balance.toString() ?? '');
    _selectedCurrency = a?.currency ?? CurrencyCode.twd;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankController.dispose();
    _balanceController.dispose();
    super.dispose();
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
                controller: _bankController,
                decoration: const InputDecoration(
                  labelText: '銀行名稱',
                  border: OutlineInputBorder(),
                ),
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
                textInputAction: TextInputAction.done,
              ),
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
        bankName: _bankController.text.trim().isEmpty
            ? null
            : _bankController.text.trim(),
        balance: balance,
        currency: _selectedCurrency,
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
