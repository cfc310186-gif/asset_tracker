import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/enums/currency_code.dart';
import '../../providers/price_providers.dart';
import '../../providers/settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _alphaVantageController = TextEditingController();
  final _exchangeRateController = TextEditingController();

  bool _isRefreshingPrices = false;
  bool _isRefreshingRates = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _alphaVantageController.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefsAsync = ref.read(sharedPrefsProvider);
    prefsAsync.whenData((prefs) {
      final currency = loadDisplayCurrency(prefs);
      ref.read(displayCurrencyProvider.notifier).state = currency;

      final avKey =
          prefs.getString(AppConstants.prefAlphaVantageApiKey) ?? '';
      final erKey =
          prefs.getString(AppConstants.prefExchangeRateApiKey) ?? '';

      if (mounted) {
        setState(() {
          _alphaVantageController.text = avKey;
          _exchangeRateController.text = erKey;
        });
      }
    });
  }

  Future<void> _onCurrencyChanged(CurrencyCode? value) async {
    if (value == null) return;
    ref.read(displayCurrencyProvider.notifier).state = value;

    final prefsAsync = ref.read(sharedPrefsProvider);
    prefsAsync.whenData((prefs) async {
      await saveDisplayCurrency(prefs, value);
    });
  }

  Future<void> _saveAlphaVantageKey(String value) async {
    final prefsAsync = ref.read(sharedPrefsProvider);
    prefsAsync.whenData(
      (prefs) => prefs.setString(AppConstants.prefAlphaVantageApiKey, value),
    );
  }

  Future<void> _saveExchangeRateKey(String value) async {
    final prefsAsync = ref.read(sharedPrefsProvider);
    prefsAsync.whenData(
      (prefs) => prefs.setString(AppConstants.prefExchangeRateApiKey, value),
    );
  }

  Future<void> _refreshStockPrices() async {
    setState(() {
      _isRefreshingPrices = true;
      _statusMessage = null;
    });
    try {
      await ref.read(refreshStockPricesProvider).execute();
      if (mounted) {
        setState(() => _statusMessage = '股價更新完成');
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _statusMessage = '更新失敗：$e');
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshingPrices = false);
      }
    }
  }

  Future<void> _refreshExchangeRates() async {
    setState(() {
      _isRefreshingRates = true;
      _statusMessage = null;
    });
    try {
      await ref.read(refreshExchangeRatesProvider).execute();
      if (mounted) {
        setState(() => _statusMessage = '匯率更新完成');
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _statusMessage = '更新失敗：$e');
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshingRates = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCurrency = ref.watch(displayCurrencyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 顯示設定 ──────────────────────────────────────────────────
          _SectionHeader(title: '顯示設定'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Expanded(child: Text('顯示幣別')),
                  DropdownButton<CurrencyCode>(
                    value: displayCurrency,
                    onChanged: _onCurrencyChanged,
                    items: CurrencyCode.values
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.displayName),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── 股價更新 ──────────────────────────────────────────────────
          _SectionHeader(title: '股價更新'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _alphaVantageController,
                    decoration: const InputDecoration(
                      labelText: 'Alpha Vantage API Key（可選）',
                      helperText: '用於美股 / 英股價格備援',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _saveAlphaVantageKey,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _exchangeRateController,
                    decoration: const InputDecoration(
                      labelText: 'ExchangeRate-API Key（可選）',
                      helperText: '用於即時匯率查詢',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _saveExchangeRateKey,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isRefreshingPrices ? null : _refreshStockPrices,
                    icon: _isRefreshingPrices
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('立即更新股價'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isRefreshingRates ? null : _refreshExchangeRates,
                    icon: _isRefreshingRates
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.currency_exchange),
                    label: const Text('更新匯率'),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _statusMessage!.startsWith('更新失敗')
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── 關於 ──────────────────────────────────────────────────────
          _SectionHeader(title: '關於'),
          Card(
            child: Column(
              children: [
                _InfoTile(label: 'App 名稱', value: '個人資產管理'),
                const Divider(height: 1),
                _InfoTile(label: '版本', value: '1.0.0'),
                const Divider(height: 1),
                _InfoTile(label: '平台', value: 'Web'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
