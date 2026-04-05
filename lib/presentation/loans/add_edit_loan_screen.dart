import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/utils/loan_calculator.dart';
import '../../domain/enums/currency_code.dart';
import '../../domain/enums/loan_type.dart';
import '../../domain/models/loan.dart';
import '../../providers/repository_providers.dart';

class AddEditLoanScreen extends ConsumerStatefulWidget {
  const AddEditLoanScreen({super.key, this.loan});

  final Loan? loan;

  @override
  ConsumerState<AddEditLoanScreen> createState() => _AddEditLoanScreenState();
}

class _AddEditLoanScreenState extends ConsumerState<AddEditLoanScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _principalCtrl;
  late final TextEditingController _remainingCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _termCtrl;
  late final TextEditingController _gracePeriodMonthsCtrl;

  late LoanType _loanType;
  late CurrencyCode _currency;
  late DateTime _startDate;
  bool _hasGracePeriod = false;
  DateTime? _gracePeriodEndDate;
  Decimal? _calculatedPayment;
  bool _isSaving = false;

  bool get _isEditing => widget.loan != null;
  bool get _showGracePeriod =>
      _loanType == LoanType.mortgage ||
      _loanType == LoanType.stockMarginLoan;

  @override
  void initState() {
    super.initState();
    final l = widget.loan;
    _nameCtrl = TextEditingController(text: l?.name ?? '');
    _principalCtrl =
        TextEditingController(text: l?.principal.toString() ?? '');
    _remainingCtrl =
        TextEditingController(text: l?.remainingBalance.toString() ?? '');

    // Display rate as percentage (e.g. 0.035 -> "3.5")
    final rateDisplay = l != null
        ? (l.interestRate * Decimal.fromInt(100)).toStringAsFixed(2)
        : '';
    _rateCtrl = TextEditingController(text: rateDisplay);
    _termCtrl =
        TextEditingController(text: l?.termMonths.toString() ?? '');
    _gracePeriodMonthsCtrl = TextEditingController(
      text: l?.gracePeriodMonths?.toString() ?? '',
    );

    _loanType = l?.type ?? LoanType.mortgage;
    _currency = l?.currency ?? CurrencyCode.twd;
    _startDate = l != null
        ? DateTime.parse(l.startDate)
        : DateTime.now();
    _hasGracePeriod = l?.hasGracePeriod ?? false;
    _gracePeriodEndDate = l?.gracePeriodEndDate != null
        ? DateTime.parse(l!.gracePeriodEndDate!)
        : null;
    _calculatedPayment = l?.monthlyPayment;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _principalCtrl.dispose();
    _remainingCtrl.dispose();
    _rateCtrl.dispose();
    _termCtrl.dispose();
    _gracePeriodMonthsCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    final principalText = _principalCtrl.text.trim();
    final rateText = _rateCtrl.text.trim();
    final termText = _termCtrl.text.trim();

    if (principalText.isEmpty || rateText.isEmpty || termText.isEmpty) return;

    try {
      final principal = Decimal.parse(principalText);
      final annualRate =
          (Decimal.parse(rateText) / Decimal.fromInt(100))
              .toDecimal(scaleOnInfinitePrecision: 10);
      final term = int.parse(termText);

      if (principal <= Decimal.zero || term <= 0) return;

      final payment = LoanCalculator.calculateMonthlyPayment(
        principal: principal,
        annualRate: annualRate,
        termMonths: term,
      );
      setState(() => _calculatedPayment = payment);
    } on Exception {
      // Ignore parse errors during typing
    } on Error {
      // Ignore argument errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '編輯貸款' : '新增貸款'),
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
                  labelText: '貸款名稱 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '請輸入貸款名稱' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<LoanType>(
                initialValue: _loanType,
                decoration: const InputDecoration(
                  labelText: '貸款種類 *',
                  border: OutlineInputBorder(),
                ),
                items: LoanType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _loanType = v;
                      if (!_showGracePeriod) _hasGracePeriod = false;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _principalCtrl,
                decoration: const InputDecoration(
                  labelText: '本金 *',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePositiveDecimal,
                onChanged: (_) => _recalculate(),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remainingCtrl,
                decoration: const InputDecoration(
                  labelText: '剩餘餘額 *',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePositiveDecimal,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rateCtrl,
                decoration: const InputDecoration(
                  labelText: '年利率 (%) *',
                  hintText: '例：3.5 代表 3.5%',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validateRate,
                onChanged: (_) => _recalculate(),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _termCtrl,
                decoration: const InputDecoration(
                  labelText: '貸款期限（月）*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validatePositiveInt,
                onChanged: (_) => _recalculate(),
                textInputAction: TextInputAction.next,
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
              _StartDateField(
                selectedDate: _startDate,
                onChanged: (d) => setState(() => _startDate = d),
              ),
              if (_showGracePeriod) ...[
                const SizedBox(height: 16),
                _GracePeriodSection(
                  hasGracePeriod: _hasGracePeriod,
                  gracePeriodMonthsCtrl: _gracePeriodMonthsCtrl,
                  gracePeriodEndDate: _gracePeriodEndDate,
                  onToggle: (v) => setState(() {
                    _hasGracePeriod = v;
                    if (!v) {
                      _gracePeriodMonthsCtrl.clear();
                      _gracePeriodEndDate = null;
                    }
                  }),
                  onEndDateChanged: (d) =>
                      setState(() => _gracePeriodEndDate = d),
                ),
              ],
              const SizedBox(height: 16),
              _MonthlyPaymentDisplay(
                payment: _calculatedPayment,
                currency: _currency,
                onRecalculate: _recalculate,
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

  String? _validatePositiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return '此欄位為必填';
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0) return '請輸入正整數';
    return null;
  }

  String? _validateRate(String? v) {
    if (v == null || v.trim().isEmpty) return '請輸入年利率';
    try {
      final d = Decimal.parse(v.trim());
      if (d <= Decimal.zero) return '利率必須大於 0';
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
      final principal = Decimal.parse(_principalCtrl.text.trim());
      final remaining = Decimal.parse(_remainingCtrl.text.trim());
      final annualRate =
          (Decimal.parse(_rateCtrl.text.trim()) / Decimal.fromInt(100))
              .toDecimal(scaleOnInfinitePrecision: 10);
      final term = int.parse(_termCtrl.text.trim());
      final now = DateTime.now();
      final existing = widget.loan;

      final payment = _calculatedPayment ??
          LoanCalculator.calculateMonthlyPayment(
            principal: principal,
            annualRate: annualRate,
            termMonths: term,
          );

      final gracePeriodMonths = (_hasGracePeriod &&
              _gracePeriodMonthsCtrl.text.trim().isNotEmpty)
          ? int.tryParse(_gracePeriodMonthsCtrl.text.trim())
          : null;

      final loan = Loan(
        id: existing?.id ?? const Uuid().v4(),
        type: _loanType,
        name: _nameCtrl.text.trim(),
        principal: principal,
        remainingBalance: remaining,
        interestRate: annualRate,
        termMonths: term,
        monthlyPayment: payment,
        currency: _currency,
        hasGracePeriod: _hasGracePeriod,
        gracePeriodMonths: gracePeriodMonths,
        gracePeriodEndDate: (_hasGracePeriod && _gracePeriodEndDate != null)
            ? _gracePeriodEndDate!.toIso8601String().substring(0, 10)
            : null,
        startDate: _startDate.toIso8601String().substring(0, 10),
        sourceType: existing?.sourceType ?? 'manual',
        sourceId: existing?.sourceId,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      await ref.read(loanRepositoryProvider).save(loan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? '貸款已更新' : '貸款已新增')),
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

class _StartDateField extends StatelessWidget {
  const _StartDateField({
    required this.selectedDate,
    required this.onChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '開始日期 *',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(selectedDate.toIso8601String().substring(0, 10)),
      ),
    );
  }
}

class _GracePeriodSection extends StatelessWidget {
  const _GracePeriodSection({
    required this.hasGracePeriod,
    required this.gracePeriodMonthsCtrl,
    required this.gracePeriodEndDate,
    required this.onToggle,
    required this.onEndDateChanged,
  });

  final bool hasGracePeriod;
  final TextEditingController gracePeriodMonthsCtrl;
  final DateTime? gracePeriodEndDate;
  final ValueChanged<bool> onToggle;
  final ValueChanged<DateTime> onEndDateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('是否有寬限期'),
          value: hasGracePeriod,
          onChanged: onToggle,
        ),
        if (hasGracePeriod) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: gracePeriodMonthsCtrl,
            decoration: const InputDecoration(
              labelText: '寬限期月數',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              final n = int.tryParse(v.trim());
              if (n == null || n <= 0) return '請輸入正整數';
              return null;
            },
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: gracePeriodEndDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) onEndDateChanged(picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '寬限期結束日期',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                gracePeriodEndDate != null
                    ? gracePeriodEndDate!.toIso8601String().substring(0, 10)
                    : '請選擇日期',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MonthlyPaymentDisplay extends StatelessWidget {
  const _MonthlyPaymentDisplay({
    required this.payment,
    required this.currency,
    required this.onRecalculate,
  });

  final Decimal? payment;
  final CurrencyCode currency;
  final VoidCallback onRecalculate;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '每月還款（試算）',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  payment != null
                      ? CurrencyFormatter.format(payment!, currency)
                      : '—',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onRecalculate,
            icon: const Icon(Icons.calculate),
            label: const Text('重新計算'),
          ),
        ],
      ),
    );
  }
}
