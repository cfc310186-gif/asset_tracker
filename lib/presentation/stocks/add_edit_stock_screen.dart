import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/currency_code.dart';
import '../../domain/enums/market_code.dart';
import '../../domain/models/stock_holding.dart';
import '../../domain/models/transaction.dart';
import '../../providers/repository_providers.dart';
import '../../providers/usecase_providers.dart';

/// Returns true if [symbol] looks like a Taiwan stock code:
/// 4–6 digits optionally followed by one uppercase letter (e.g. 2330, 00881, 3034A).
bool _isTaiwanSymbol(String symbol) =>
    RegExp(r'^\d{4,6}[A-Z]?$').hasMatch(symbol.toUpperCase().trim());

class AddEditStockScreen extends ConsumerStatefulWidget {
  const AddEditStockScreen({super.key, this.holding});

  final StockHolding? holding;

  @override
  ConsumerState<AddEditStockScreen> createState() =>
      _AddEditStockScreenState();
}

class _AddEditStockScreenState extends ConsumerState<AddEditStockScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _symbolCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _avgCostCtrl;
  late final TextEditingController _marginAmountCtrl;

  late MarketCode _market;
  late CurrencyCode _currency;
  late bool _isMargin;
  bool _isSaving = false;

  bool get _isEditing => widget.holding != null;

  /// True when the symbol matches the Taiwan pattern → hide market selector.
  bool get _isTaiwan => _market == MarketCode.taiwan;

  @override
  void initState() {
    super.initState();
    final h = widget.holding;
    _symbolCtrl = TextEditingController(text: h?.symbol ?? '');
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _quantityCtrl = TextEditingController(text: h?.quantity.toString() ?? '');
    _avgCostCtrl = TextEditingController(text: h?.avgCost.toString() ?? '');
    _marginAmountCtrl = TextEditingController(
      text: h?.marginAmount?.toString() ?? '',
    );
    _market = h?.market ?? _detectMarket(_symbolCtrl.text);
    _currency = _market.defaultCurrency;

    _symbolCtrl.addListener(_onSymbolChanged);
  }

  @override
  void dispose() {
    _symbolCtrl.removeListener(_onSymbolChanged);
    _symbolCtrl.dispose();
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _avgCostCtrl.dispose();
    _marginAmountCtrl.dispose();
    super.dispose();
  }

  MarketCode _detectMarket(String symbol) {
    if (_isTaiwanSymbol(symbol)) return MarketCode.taiwan;
    // Keep current non-taiwan market if already set to us/uk.
    if (_market == MarketCode.us || _market == MarketCode.uk) return _market;
    return MarketCode.us;
  }

  void _onSymbolChanged() {
    final detected = _detectMarket(_symbolCtrl.text);
    if (detected != _market) {
      setState(() {
        _market = detected;
        _currency = _market.defaultCurrency;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '編輯股票' : '新增股票'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _symbolCtrl,
                decoration: InputDecoration(
                  labelText: '股票代號 *',
                  hintText: _isTaiwan
                      ? '例：2330、00881'
                      : _market == MarketCode.uk
                          ? '例：VWRA、BP（英股代號）'
                          : '例：AAPL、MSFT',
                  border: const OutlineInputBorder(),
                  suffixIcon: _isTaiwan
                      ? const Tooltip(
                          message: '數字代號自動識別為台股',
                          child: Icon(Icons.flag, color: Colors.blue, size: 18),
                        )
                      : null,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '請輸入股票代號' : null,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: '股票名稱 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '請輸入股票名稱' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Market selector: hidden for Taiwan (auto-detected),
              // shown as US/UK dropdown for foreign stocks.
              if (_isTaiwan)
                _MarketReadonlyTile(market: _market)
              else
                _ForeignMarketDropdown(
                  value: _market,
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _market = v;
                        _currency = _market.defaultCurrency;
                      });
                    }
                  },
                ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityCtrl,
                decoration: const InputDecoration(
                  labelText: '股數 *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validatePositiveInt,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avgCostCtrl,
                decoration: InputDecoration(
                  labelText: '平均成本（每股）*',
                  suffixText: _currency.displayName,
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePositiveDecimal,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              _MarginSection(
                isMargin: _isMargin,
                marginAmountCtrl: _marginAmountCtrl,
                onToggle: (v) => setState(() => _isMargin = v),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final existing = widget.holding;
      final id = existing?.id ?? const Uuid().v4();

      final wasMargin = existing?.isMargin ?? false;
      final hadLinkedLoan = existing?.linkedLoanId != null;
      final needsNewLoan = _isMargin && (!wasMargin || !hadLinkedLoan);

      String? linkedLoanId = existing?.linkedLoanId;

      Decimal? marginAmount;
      if (_isMargin && _marginAmountCtrl.text.trim().isNotEmpty) {
        marginAmount = Decimal.parse(_marginAmountCtrl.text.trim());
      }

      final holding = StockHolding(
        id: id,
        symbol: _symbolCtrl.text.trim().toUpperCase(),
        market: _market,
        name: _nameCtrl.text.trim(),
        quantity: int.parse(_quantityCtrl.text.trim()),
        avgCost: Decimal.parse(_avgCostCtrl.text.trim()),
        currency: _currency,
        isMargin: _isMargin,
        marginAmount: marginAmount,
        linkedLoanId: linkedLoanId,
        latestPrice: existing?.latestPrice,
        priceUpdatedAt: existing?.priceUpdatedAt,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      await ref.read(stockRepositoryProvider).save(holding);

      // Audit-log entry. New holdings record a buy; edits record an adjust
      // with the delta in shares (skip if quantity unchanged).
      final qtyDelta = holding.quantity - (existing?.quantity ?? 0);
      if (existing == null) {
        await ref.read(recordTransactionProvider).execute(
              assetType: TransactionAssetType.stock,
              assetId: holding.id,
              kind: TransactionKind.buy,
              quantity: Decimal.fromInt(holding.quantity),
              price: holding.avgCost,
              amount: -(holding.avgCost *
                  Decimal.fromInt(holding.quantity)),
              currency: holding.currency,
            );
      } else if (qtyDelta != 0) {
        await ref.read(recordTransactionProvider).execute(
              assetType: TransactionAssetType.stock,
              assetId: holding.id,
              kind: qtyDelta > 0 ? TransactionKind.buy : TransactionKind.sell,
              quantity: Decimal.fromInt(qtyDelta.abs()),
              price: holding.avgCost,
              amount: -(holding.avgCost * Decimal.fromInt(qtyDelta)),
              currency: holding.currency,
            );
      }

      if (needsNewLoan && marginAmount != null) {
        await ref.read(createMarginLoanProvider).execute(holding);
      } else if (_isMargin &&
          holding.linkedLoanId != null &&
          marginAmount != null) {
        await ref.read(syncLinkedLoansProvider).onMarginAmountChanged(holding);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? '股票已更新' : '股票已新增')),
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

// ---------------------------------------------------------------------------

class _MarketReadonlyTile extends StatelessWidget {
  const _MarketReadonlyTile({required this.market});
  final MarketCode market;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.flag, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(
            '市場：${market.displayName}（自動識別）',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _ForeignMarketDropdown extends StatelessWidget {
  const _ForeignMarketDropdown({
    required this.value,
    required this.onChanged,
  });
  final MarketCode value;
  final ValueChanged<MarketCode?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MarketCode>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: '市場 *',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: MarketCode.us, child: Text('美股')),
        DropdownMenuItem(value: MarketCode.uk, child: Text('英股')),
      ],
      onChanged: onChanged,
    );
  }
}

class _MarginSection extends StatelessWidget {
  const _MarginSection({
    required this.isMargin,
    required this.marginAmountCtrl,
    required this.onToggle,
  });

  final bool isMargin;
  final TextEditingController marginAmountCtrl;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('是否融資'),
          value: isMargin,
          onChanged: onToggle,
        ),
        if (isMargin) ...[
          TextFormField(
            controller: marginAmountCtrl,
            decoration: const InputDecoration(
              labelText: '融資金額 *',
              border: OutlineInputBorder(),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '請輸入融資金額';
              try {
                final d = Decimal.parse(v.trim());
                if (d <= Decimal.zero) return '必須大於 0';
              } on FormatException {
                return '請輸入有效的數字';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '融資金額將自動新增至貸款項目',
                    style: TextStyle(fontSize: 13, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
