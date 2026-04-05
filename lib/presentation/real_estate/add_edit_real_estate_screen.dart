import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/currency_code.dart';
import '../../domain/enums/loan_type.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/real_estate_asset.dart';
import '../../providers/repository_providers.dart';

class AddEditRealEstateScreen extends ConsumerStatefulWidget {
  const AddEditRealEstateScreen({super.key, this.asset});

  final RealEstateAsset? asset;

  @override
  ConsumerState<AddEditRealEstateScreen> createState() =>
      _AddEditRealEstateScreenState();
}

class _AddEditRealEstateScreenState
    extends ConsumerState<AddEditRealEstateScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _estimatedValueCtrl;
  late final TextEditingController _purchasePriceCtrl;

  late CurrencyCode _currency;
  late DateTime _purchaseDate;
  late bool _hasMortgage;
  bool _isSaving = false;

  bool get _isEditing => widget.asset != null;

  @override
  void initState() {
    super.initState();
    final a = widget.asset;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _addressCtrl = TextEditingController(text: a?.address ?? '');
    _estimatedValueCtrl = TextEditingController(
      text: a?.estimatedValue.toString() ?? '',
    );
    _purchasePriceCtrl = TextEditingController(
      text: a?.purchasePrice.toString() ?? '',
    );
    _currency = a?.currency ?? CurrencyCode.twd;
    _purchaseDate =
        a != null ? DateTime.parse(a.purchaseDate) : DateTime.now();
    _hasMortgage = a?.hasMortgage ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _estimatedValueCtrl.dispose();
    _purchasePriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '編輯不動產' : '新增不動產'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: '名稱 *',
                  hintText: '例：台北市大安區住宅',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '請輸入名稱' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: '地址 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '請輸入地址' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _estimatedValueCtrl,
                decoration: const InputDecoration(
                  labelText: '現值 *',
                  hintText: '目前市場估值',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePositiveDecimal,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purchasePriceCtrl,
                decoration: const InputDecoration(
                  labelText: '購入價格 *',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePositiveDecimal,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              _DatePickerField(
                label: '購入日期 *',
                selectedDate: _purchaseDate,
                onChanged: (d) => setState(() => _purchaseDate = d),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CurrencyCode>(
                initialValue: _currency,
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
                  if (v != null) setState(() => _currency = v);
                },
              ),
              const SizedBox(height: 16),
              _MortgageToggle(
                hasMortgage: _hasMortgage,
                isEditing: _isEditing,
                existingLinkedLoanId: widget.asset?.linkedLoanId,
                onChanged: (value) => _handleMortgageToggle(value),
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

  Future<void> _handleMortgageToggle(bool value) async {
    if (!value && _isEditing && widget.asset?.linkedLoanId != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('移除房貸連結'),
          content: const Text('關閉房貸連結將移除貸款記錄，確定要繼續嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('確定'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() => _hasMortgage = value);
  }

  String? _validatePositiveDecimal(String? v) {
    if (v == null || v.trim().isEmpty) return '此欄位為必填';
    try {
      final d = Decimal.parse(v.trim());
      if (d <= Decimal.zero) return '必須大於 0';
    } on FormatException {
      return '請輸入有效的數字';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final existing = widget.asset;
      final id = existing?.id ?? const Uuid().v4();

      // Determine loan linkage changes
      final wasHasMortgage = existing?.hasMortgage ?? false;
      final hadLinkedLoan = existing?.linkedLoanId != null;
      final needsNewLoan =
          _hasMortgage && (!wasHasMortgage || !hadLinkedLoan);
      final needsLoanRemoval =
          !_hasMortgage && wasHasMortgage && hadLinkedLoan;

      String? linkedLoanId = existing?.linkedLoanId;

      if (needsLoanRemoval) {
        // Delete the linked loan
        if (linkedLoanId != null) {
          await ref.read(loanRepositoryProvider).delete(linkedLoanId);
        }
        linkedLoanId = null;
      }

      final asset = RealEstateAsset(
        id: id,
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        estimatedValue: Decimal.parse(_estimatedValueCtrl.text.trim()),
        purchasePrice: Decimal.parse(_purchasePriceCtrl.text.trim()),
        purchaseDate: _purchaseDate.toIso8601String().substring(0, 10),
        currency: _currency,
        hasMortgage: _hasMortgage,
        linkedLoanId: linkedLoanId,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      await ref.read(realEstateRepositoryProvider).save(asset);

      if (needsNewLoan) {
        final loanId = const Uuid().v4();
        final placeholderLoan = Loan(
          id: loanId,
          type: LoanType.mortgage,
          name: '${_nameCtrl.text.trim()} 房貸',
          principal: Decimal.zero,
          remainingBalance: Decimal.zero,
          interestRate: Decimal.zero,
          termMonths: 0,
          monthlyPayment: Decimal.zero,
          currency: _currency,
          hasGracePeriod: false,
          startDate: now.toIso8601String().substring(0, 10),
          sourceType: 'real_estate',
          sourceId: id,
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(loanRepositoryProvider).save(placeholderLoan);

        // Update asset with linked loan id
        final assetWithLoan = asset.copyWith(linkedLoanId: loanId);
        await ref.read(realEstateRepositoryProvider).save(assetWithLoan);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? '不動產已更新' : '不動產已新增')),
        );
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onChanged,
  });

  final String label;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(1950),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(selectedDate.toIso8601String().substring(0, 10)),
      ),
    );
  }
}

class _MortgageToggle extends StatelessWidget {
  const _MortgageToggle({
    required this.hasMortgage,
    required this.isEditing,
    required this.existingLinkedLoanId,
    required this.onChanged,
  });

  final bool hasMortgage;
  final bool isEditing;
  final String? existingLinkedLoanId;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('是否有房貸'),
          value: hasMortgage,
          onChanged: onChanged,
        ),
        if (hasMortgage)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '儲存後將自動建立貸款項目，請至貸款頁面填寫詳細資訊',
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
