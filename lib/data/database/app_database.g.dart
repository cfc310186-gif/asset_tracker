// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StocksTable extends Stocks with TableInfo<$StocksTable, StockEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
      'market', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _avgCostMeta =
      const VerificationMeta('avgCost');
  @override
  late final GeneratedColumn<String> avgCost = GeneratedColumn<String>(
      'avg_cost', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isMarginMeta =
      const VerificationMeta('isMargin');
  @override
  late final GeneratedColumn<bool> isMargin = GeneratedColumn<bool>(
      'is_margin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_margin" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _marginAmountMeta =
      const VerificationMeta('marginAmount');
  @override
  late final GeneratedColumn<String> marginAmount = GeneratedColumn<String>(
      'margin_amount', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linkedLoanIdMeta =
      const VerificationMeta('linkedLoanId');
  @override
  late final GeneratedColumn<String> linkedLoanId = GeneratedColumn<String>(
      'linked_loan_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latestPriceMeta =
      const VerificationMeta('latestPrice');
  @override
  late final GeneratedColumn<String> latestPrice = GeneratedColumn<String>(
      'latest_price', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priceUpdatedAtMeta =
      const VerificationMeta('priceUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> priceUpdatedAt =
      GeneratedColumn<DateTime>('price_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        symbol,
        market,
        name,
        quantity,
        avgCost,
        currency,
        isMargin,
        marginAmount,
        linkedLoanId,
        latestPrice,
        priceUpdatedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stocks';
  @override
  VerificationContext validateIntegrity(Insertable<StockEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('market')) {
      context.handle(_marketMeta,
          market.isAcceptableOrUnknown(data['market']!, _marketMeta));
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('avg_cost')) {
      context.handle(_avgCostMeta,
          avgCost.isAcceptableOrUnknown(data['avg_cost']!, _avgCostMeta));
    } else if (isInserting) {
      context.missing(_avgCostMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('is_margin')) {
      context.handle(_isMarginMeta,
          isMargin.isAcceptableOrUnknown(data['is_margin']!, _isMarginMeta));
    }
    if (data.containsKey('margin_amount')) {
      context.handle(
          _marginAmountMeta,
          marginAmount.isAcceptableOrUnknown(
              data['margin_amount']!, _marginAmountMeta));
    }
    if (data.containsKey('linked_loan_id')) {
      context.handle(
          _linkedLoanIdMeta,
          linkedLoanId.isAcceptableOrUnknown(
              data['linked_loan_id']!, _linkedLoanIdMeta));
    }
    if (data.containsKey('latest_price')) {
      context.handle(
          _latestPriceMeta,
          latestPrice.isAcceptableOrUnknown(
              data['latest_price']!, _latestPriceMeta));
    }
    if (data.containsKey('price_updated_at')) {
      context.handle(
          _priceUpdatedAtMeta,
          priceUpdatedAt.isAcceptableOrUnknown(
              data['price_updated_at']!, _priceUpdatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      market: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}market'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      avgCost: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avg_cost'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      isMargin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_margin'])!,
      marginAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}margin_amount']),
      linkedLoanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linked_loan_id']),
      latestPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}latest_price']),
      priceUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}price_updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StocksTable createAlias(String alias) {
    return $StocksTable(attachedDatabase, alias);
  }
}

class StockEntry extends DataClass implements Insertable<StockEntry> {
  final String id;
  final String symbol;
  final String market;
  final String name;
  final int quantity;
  final String avgCost;
  final String currency;
  final bool isMargin;
  final String? marginAmount;
  final String? linkedLoanId;
  final String? latestPrice;
  final DateTime? priceUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StockEntry(
      {required this.id,
      required this.symbol,
      required this.market,
      required this.name,
      required this.quantity,
      required this.avgCost,
      required this.currency,
      required this.isMargin,
      this.marginAmount,
      this.linkedLoanId,
      this.latestPrice,
      this.priceUpdatedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['symbol'] = Variable<String>(symbol);
    map['market'] = Variable<String>(market);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<int>(quantity);
    map['avg_cost'] = Variable<String>(avgCost);
    map['currency'] = Variable<String>(currency);
    map['is_margin'] = Variable<bool>(isMargin);
    if (!nullToAbsent || marginAmount != null) {
      map['margin_amount'] = Variable<String>(marginAmount);
    }
    if (!nullToAbsent || linkedLoanId != null) {
      map['linked_loan_id'] = Variable<String>(linkedLoanId);
    }
    if (!nullToAbsent || latestPrice != null) {
      map['latest_price'] = Variable<String>(latestPrice);
    }
    if (!nullToAbsent || priceUpdatedAt != null) {
      map['price_updated_at'] = Variable<DateTime>(priceUpdatedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StocksCompanion toCompanion(bool nullToAbsent) {
    return StocksCompanion(
      id: Value(id),
      symbol: Value(symbol),
      market: Value(market),
      name: Value(name),
      quantity: Value(quantity),
      avgCost: Value(avgCost),
      currency: Value(currency),
      isMargin: Value(isMargin),
      marginAmount: marginAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(marginAmount),
      linkedLoanId: linkedLoanId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedLoanId),
      latestPrice: latestPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(latestPrice),
      priceUpdatedAt: priceUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(priceUpdatedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StockEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockEntry(
      id: serializer.fromJson<String>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      market: serializer.fromJson<String>(json['market']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<int>(json['quantity']),
      avgCost: serializer.fromJson<String>(json['avgCost']),
      currency: serializer.fromJson<String>(json['currency']),
      isMargin: serializer.fromJson<bool>(json['isMargin']),
      marginAmount: serializer.fromJson<String?>(json['marginAmount']),
      linkedLoanId: serializer.fromJson<String?>(json['linkedLoanId']),
      latestPrice: serializer.fromJson<String?>(json['latestPrice']),
      priceUpdatedAt: serializer.fromJson<DateTime?>(json['priceUpdatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'symbol': serializer.toJson<String>(symbol),
      'market': serializer.toJson<String>(market),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<int>(quantity),
      'avgCost': serializer.toJson<String>(avgCost),
      'currency': serializer.toJson<String>(currency),
      'isMargin': serializer.toJson<bool>(isMargin),
      'marginAmount': serializer.toJson<String?>(marginAmount),
      'linkedLoanId': serializer.toJson<String?>(linkedLoanId),
      'latestPrice': serializer.toJson<String?>(latestPrice),
      'priceUpdatedAt': serializer.toJson<DateTime?>(priceUpdatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StockEntry copyWith(
          {String? id,
          String? symbol,
          String? market,
          String? name,
          int? quantity,
          String? avgCost,
          String? currency,
          bool? isMargin,
          Value<String?> marginAmount = const Value.absent(),
          Value<String?> linkedLoanId = const Value.absent(),
          Value<String?> latestPrice = const Value.absent(),
          Value<DateTime?> priceUpdatedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      StockEntry(
        id: id ?? this.id,
        symbol: symbol ?? this.symbol,
        market: market ?? this.market,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        avgCost: avgCost ?? this.avgCost,
        currency: currency ?? this.currency,
        isMargin: isMargin ?? this.isMargin,
        marginAmount:
            marginAmount.present ? marginAmount.value : this.marginAmount,
        linkedLoanId:
            linkedLoanId.present ? linkedLoanId.value : this.linkedLoanId,
        latestPrice: latestPrice.present ? latestPrice.value : this.latestPrice,
        priceUpdatedAt:
            priceUpdatedAt.present ? priceUpdatedAt.value : this.priceUpdatedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StockEntry copyWithCompanion(StocksCompanion data) {
    return StockEntry(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      market: data.market.present ? data.market.value : this.market,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      avgCost: data.avgCost.present ? data.avgCost.value : this.avgCost,
      currency: data.currency.present ? data.currency.value : this.currency,
      isMargin: data.isMargin.present ? data.isMargin.value : this.isMargin,
      marginAmount: data.marginAmount.present
          ? data.marginAmount.value
          : this.marginAmount,
      linkedLoanId: data.linkedLoanId.present
          ? data.linkedLoanId.value
          : this.linkedLoanId,
      latestPrice:
          data.latestPrice.present ? data.latestPrice.value : this.latestPrice,
      priceUpdatedAt: data.priceUpdatedAt.present
          ? data.priceUpdatedAt.value
          : this.priceUpdatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockEntry(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('avgCost: $avgCost, ')
          ..write('currency: $currency, ')
          ..write('isMargin: $isMargin, ')
          ..write('marginAmount: $marginAmount, ')
          ..write('linkedLoanId: $linkedLoanId, ')
          ..write('latestPrice: $latestPrice, ')
          ..write('priceUpdatedAt: $priceUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      symbol,
      market,
      name,
      quantity,
      avgCost,
      currency,
      isMargin,
      marginAmount,
      linkedLoanId,
      latestPrice,
      priceUpdatedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockEntry &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.market == this.market &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.avgCost == this.avgCost &&
          other.currency == this.currency &&
          other.isMargin == this.isMargin &&
          other.marginAmount == this.marginAmount &&
          other.linkedLoanId == this.linkedLoanId &&
          other.latestPrice == this.latestPrice &&
          other.priceUpdatedAt == this.priceUpdatedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StocksCompanion extends UpdateCompanion<StockEntry> {
  final Value<String> id;
  final Value<String> symbol;
  final Value<String> market;
  final Value<String> name;
  final Value<int> quantity;
  final Value<String> avgCost;
  final Value<String> currency;
  final Value<bool> isMargin;
  final Value<String?> marginAmount;
  final Value<String?> linkedLoanId;
  final Value<String?> latestPrice;
  final Value<DateTime?> priceUpdatedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StocksCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.market = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.avgCost = const Value.absent(),
    this.currency = const Value.absent(),
    this.isMargin = const Value.absent(),
    this.marginAmount = const Value.absent(),
    this.linkedLoanId = const Value.absent(),
    this.latestPrice = const Value.absent(),
    this.priceUpdatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StocksCompanion.insert({
    required String id,
    required String symbol,
    required String market,
    required String name,
    required int quantity,
    required String avgCost,
    required String currency,
    this.isMargin = const Value.absent(),
    this.marginAmount = const Value.absent(),
    this.linkedLoanId = const Value.absent(),
    this.latestPrice = const Value.absent(),
    this.priceUpdatedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        symbol = Value(symbol),
        market = Value(market),
        name = Value(name),
        quantity = Value(quantity),
        avgCost = Value(avgCost),
        currency = Value(currency),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<StockEntry> custom({
    Expression<String>? id,
    Expression<String>? symbol,
    Expression<String>? market,
    Expression<String>? name,
    Expression<int>? quantity,
    Expression<String>? avgCost,
    Expression<String>? currency,
    Expression<bool>? isMargin,
    Expression<String>? marginAmount,
    Expression<String>? linkedLoanId,
    Expression<String>? latestPrice,
    Expression<DateTime>? priceUpdatedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (market != null) 'market': market,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (avgCost != null) 'avg_cost': avgCost,
      if (currency != null) 'currency': currency,
      if (isMargin != null) 'is_margin': isMargin,
      if (marginAmount != null) 'margin_amount': marginAmount,
      if (linkedLoanId != null) 'linked_loan_id': linkedLoanId,
      if (latestPrice != null) 'latest_price': latestPrice,
      if (priceUpdatedAt != null) 'price_updated_at': priceUpdatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StocksCompanion copyWith(
      {Value<String>? id,
      Value<String>? symbol,
      Value<String>? market,
      Value<String>? name,
      Value<int>? quantity,
      Value<String>? avgCost,
      Value<String>? currency,
      Value<bool>? isMargin,
      Value<String?>? marginAmount,
      Value<String?>? linkedLoanId,
      Value<String?>? latestPrice,
      Value<DateTime?>? priceUpdatedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return StocksCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      market: market ?? this.market,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      avgCost: avgCost ?? this.avgCost,
      currency: currency ?? this.currency,
      isMargin: isMargin ?? this.isMargin,
      marginAmount: marginAmount ?? this.marginAmount,
      linkedLoanId: linkedLoanId ?? this.linkedLoanId,
      latestPrice: latestPrice ?? this.latestPrice,
      priceUpdatedAt: priceUpdatedAt ?? this.priceUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (avgCost.present) {
      map['avg_cost'] = Variable<String>(avgCost.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (isMargin.present) {
      map['is_margin'] = Variable<bool>(isMargin.value);
    }
    if (marginAmount.present) {
      map['margin_amount'] = Variable<String>(marginAmount.value);
    }
    if (linkedLoanId.present) {
      map['linked_loan_id'] = Variable<String>(linkedLoanId.value);
    }
    if (latestPrice.present) {
      map['latest_price'] = Variable<String>(latestPrice.value);
    }
    if (priceUpdatedAt.present) {
      map['price_updated_at'] = Variable<DateTime>(priceUpdatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StocksCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('avgCost: $avgCost, ')
          ..write('currency: $currency, ')
          ..write('isMargin: $isMargin, ')
          ..write('marginAmount: $marginAmount, ')
          ..write('linkedLoanId: $linkedLoanId, ')
          ..write('latestPrice: $latestPrice, ')
          ..write('priceUpdatedAt: $priceUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RealEstateTable extends RealEstate
    with TableInfo<$RealEstateTable, RealEstateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RealEstateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _estimatedValueMeta =
      const VerificationMeta('estimatedValue');
  @override
  late final GeneratedColumn<String> estimatedValue = GeneratedColumn<String>(
      'estimated_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<String> purchasePrice = GeneratedColumn<String>(
      'purchase_price', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<String> purchaseDate = GeneratedColumn<String>(
      'purchase_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hasMortgageMeta =
      const VerificationMeta('hasMortgage');
  @override
  late final GeneratedColumn<bool> hasMortgage = GeneratedColumn<bool>(
      'has_mortgage', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_mortgage" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _linkedLoanIdMeta =
      const VerificationMeta('linkedLoanId');
  @override
  late final GeneratedColumn<String> linkedLoanId = GeneratedColumn<String>(
      'linked_loan_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        address,
        estimatedValue,
        purchasePrice,
        purchaseDate,
        currency,
        hasMortgage,
        linkedLoanId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'real_estate';
  @override
  VerificationContext validateIntegrity(Insertable<RealEstateEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('estimated_value')) {
      context.handle(
          _estimatedValueMeta,
          estimatedValue.isAcceptableOrUnknown(
              data['estimated_value']!, _estimatedValueMeta));
    } else if (isInserting) {
      context.missing(_estimatedValueMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('has_mortgage')) {
      context.handle(
          _hasMortgageMeta,
          hasMortgage.isAcceptableOrUnknown(
              data['has_mortgage']!, _hasMortgageMeta));
    }
    if (data.containsKey('linked_loan_id')) {
      context.handle(
          _linkedLoanIdMeta,
          linkedLoanId.isAcceptableOrUnknown(
              data['linked_loan_id']!, _linkedLoanIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RealEstateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RealEstateEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      estimatedValue: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}estimated_value'])!,
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_price'])!,
      purchaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_date'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      hasMortgage: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_mortgage'])!,
      linkedLoanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linked_loan_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RealEstateTable createAlias(String alias) {
    return $RealEstateTable(attachedDatabase, alias);
  }
}

class RealEstateEntry extends DataClass implements Insertable<RealEstateEntry> {
  final String id;
  final String name;
  final String address;
  final String estimatedValue;
  final String purchasePrice;
  final String purchaseDate;
  final String currency;
  final bool hasMortgage;
  final String? linkedLoanId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RealEstateEntry(
      {required this.id,
      required this.name,
      required this.address,
      required this.estimatedValue,
      required this.purchasePrice,
      required this.purchaseDate,
      required this.currency,
      required this.hasMortgage,
      this.linkedLoanId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    map['estimated_value'] = Variable<String>(estimatedValue);
    map['purchase_price'] = Variable<String>(purchasePrice);
    map['purchase_date'] = Variable<String>(purchaseDate);
    map['currency'] = Variable<String>(currency);
    map['has_mortgage'] = Variable<bool>(hasMortgage);
    if (!nullToAbsent || linkedLoanId != null) {
      map['linked_loan_id'] = Variable<String>(linkedLoanId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RealEstateCompanion toCompanion(bool nullToAbsent) {
    return RealEstateCompanion(
      id: Value(id),
      name: Value(name),
      address: Value(address),
      estimatedValue: Value(estimatedValue),
      purchasePrice: Value(purchasePrice),
      purchaseDate: Value(purchaseDate),
      currency: Value(currency),
      hasMortgage: Value(hasMortgage),
      linkedLoanId: linkedLoanId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedLoanId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RealEstateEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RealEstateEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      estimatedValue: serializer.fromJson<String>(json['estimatedValue']),
      purchasePrice: serializer.fromJson<String>(json['purchasePrice']),
      purchaseDate: serializer.fromJson<String>(json['purchaseDate']),
      currency: serializer.fromJson<String>(json['currency']),
      hasMortgage: serializer.fromJson<bool>(json['hasMortgage']),
      linkedLoanId: serializer.fromJson<String?>(json['linkedLoanId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'estimatedValue': serializer.toJson<String>(estimatedValue),
      'purchasePrice': serializer.toJson<String>(purchasePrice),
      'purchaseDate': serializer.toJson<String>(purchaseDate),
      'currency': serializer.toJson<String>(currency),
      'hasMortgage': serializer.toJson<bool>(hasMortgage),
      'linkedLoanId': serializer.toJson<String?>(linkedLoanId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RealEstateEntry copyWith(
          {String? id,
          String? name,
          String? address,
          String? estimatedValue,
          String? purchasePrice,
          String? purchaseDate,
          String? currency,
          bool? hasMortgage,
          Value<String?> linkedLoanId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RealEstateEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        estimatedValue: estimatedValue ?? this.estimatedValue,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        currency: currency ?? this.currency,
        hasMortgage: hasMortgage ?? this.hasMortgage,
        linkedLoanId:
            linkedLoanId.present ? linkedLoanId.value : this.linkedLoanId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RealEstateEntry copyWithCompanion(RealEstateCompanion data) {
    return RealEstateEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      estimatedValue: data.estimatedValue.present
          ? data.estimatedValue.value
          : this.estimatedValue,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      currency: data.currency.present ? data.currency.value : this.currency,
      hasMortgage:
          data.hasMortgage.present ? data.hasMortgage.value : this.hasMortgage,
      linkedLoanId: data.linkedLoanId.present
          ? data.linkedLoanId.value
          : this.linkedLoanId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RealEstateEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('estimatedValue: $estimatedValue, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('currency: $currency, ')
          ..write('hasMortgage: $hasMortgage, ')
          ..write('linkedLoanId: $linkedLoanId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      address,
      estimatedValue,
      purchasePrice,
      purchaseDate,
      currency,
      hasMortgage,
      linkedLoanId,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RealEstateEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.estimatedValue == this.estimatedValue &&
          other.purchasePrice == this.purchasePrice &&
          other.purchaseDate == this.purchaseDate &&
          other.currency == this.currency &&
          other.hasMortgage == this.hasMortgage &&
          other.linkedLoanId == this.linkedLoanId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RealEstateCompanion extends UpdateCompanion<RealEstateEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> address;
  final Value<String> estimatedValue;
  final Value<String> purchasePrice;
  final Value<String> purchaseDate;
  final Value<String> currency;
  final Value<bool> hasMortgage;
  final Value<String?> linkedLoanId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RealEstateCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.estimatedValue = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.currency = const Value.absent(),
    this.hasMortgage = const Value.absent(),
    this.linkedLoanId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RealEstateCompanion.insert({
    required String id,
    required String name,
    required String address,
    required String estimatedValue,
    required String purchasePrice,
    required String purchaseDate,
    required String currency,
    this.hasMortgage = const Value.absent(),
    this.linkedLoanId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        address = Value(address),
        estimatedValue = Value(estimatedValue),
        purchasePrice = Value(purchasePrice),
        purchaseDate = Value(purchaseDate),
        currency = Value(currency),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RealEstateEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? estimatedValue,
    Expression<String>? purchasePrice,
    Expression<String>? purchaseDate,
    Expression<String>? currency,
    Expression<bool>? hasMortgage,
    Expression<String>? linkedLoanId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (estimatedValue != null) 'estimated_value': estimatedValue,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (currency != null) 'currency': currency,
      if (hasMortgage != null) 'has_mortgage': hasMortgage,
      if (linkedLoanId != null) 'linked_loan_id': linkedLoanId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RealEstateCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? address,
      Value<String>? estimatedValue,
      Value<String>? purchasePrice,
      Value<String>? purchaseDate,
      Value<String>? currency,
      Value<bool>? hasMortgage,
      Value<String?>? linkedLoanId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RealEstateCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      currency: currency ?? this.currency,
      hasMortgage: hasMortgage ?? this.hasMortgage,
      linkedLoanId: linkedLoanId ?? this.linkedLoanId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (estimatedValue.present) {
      map['estimated_value'] = Variable<String>(estimatedValue.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<String>(purchasePrice.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<String>(purchaseDate.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (hasMortgage.present) {
      map['has_mortgage'] = Variable<bool>(hasMortgage.value);
    }
    if (linkedLoanId.present) {
      map['linked_loan_id'] = Variable<String>(linkedLoanId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RealEstateCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('estimatedValue: $estimatedValue, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('currency: $currency, ')
          ..write('hasMortgage: $hasMortgage, ')
          ..write('linkedLoanId: $linkedLoanId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, LoanEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _principalMeta =
      const VerificationMeta('principal');
  @override
  late final GeneratedColumn<String> principal = GeneratedColumn<String>(
      'principal', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remainingBalanceMeta =
      const VerificationMeta('remainingBalance');
  @override
  late final GeneratedColumn<String> remainingBalance = GeneratedColumn<String>(
      'remaining_balance', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _interestRateMeta =
      const VerificationMeta('interestRate');
  @override
  late final GeneratedColumn<String> interestRate = GeneratedColumn<String>(
      'interest_rate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _termMonthsMeta =
      const VerificationMeta('termMonths');
  @override
  late final GeneratedColumn<int> termMonths = GeneratedColumn<int>(
      'term_months', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _monthlyPaymentMeta =
      const VerificationMeta('monthlyPayment');
  @override
  late final GeneratedColumn<String> monthlyPayment = GeneratedColumn<String>(
      'monthly_payment', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hasGracePeriodMeta =
      const VerificationMeta('hasGracePeriod');
  @override
  late final GeneratedColumn<bool> hasGracePeriod = GeneratedColumn<bool>(
      'has_grace_period', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_grace_period" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _gracePeriodMonthsMeta =
      const VerificationMeta('gracePeriodMonths');
  @override
  late final GeneratedColumn<int> gracePeriodMonths = GeneratedColumn<int>(
      'grace_period_months', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _gracePeriodEndDateMeta =
      const VerificationMeta('gracePeriodEndDate');
  @override
  late final GeneratedColumn<String> gracePeriodEndDate =
      GeneratedColumn<String>('grace_period_end_date', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        name,
        principal,
        remainingBalance,
        interestRate,
        termMonths,
        monthlyPayment,
        currency,
        hasGracePeriod,
        gracePeriodMonths,
        gracePeriodEndDate,
        startDate,
        sourceType,
        sourceId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(Insertable<LoanEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('principal')) {
      context.handle(_principalMeta,
          principal.isAcceptableOrUnknown(data['principal']!, _principalMeta));
    } else if (isInserting) {
      context.missing(_principalMeta);
    }
    if (data.containsKey('remaining_balance')) {
      context.handle(
          _remainingBalanceMeta,
          remainingBalance.isAcceptableOrUnknown(
              data['remaining_balance']!, _remainingBalanceMeta));
    } else if (isInserting) {
      context.missing(_remainingBalanceMeta);
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
          _interestRateMeta,
          interestRate.isAcceptableOrUnknown(
              data['interest_rate']!, _interestRateMeta));
    } else if (isInserting) {
      context.missing(_interestRateMeta);
    }
    if (data.containsKey('term_months')) {
      context.handle(
          _termMonthsMeta,
          termMonths.isAcceptableOrUnknown(
              data['term_months']!, _termMonthsMeta));
    } else if (isInserting) {
      context.missing(_termMonthsMeta);
    }
    if (data.containsKey('monthly_payment')) {
      context.handle(
          _monthlyPaymentMeta,
          monthlyPayment.isAcceptableOrUnknown(
              data['monthly_payment']!, _monthlyPaymentMeta));
    } else if (isInserting) {
      context.missing(_monthlyPaymentMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('has_grace_period')) {
      context.handle(
          _hasGracePeriodMeta,
          hasGracePeriod.isAcceptableOrUnknown(
              data['has_grace_period']!, _hasGracePeriodMeta));
    }
    if (data.containsKey('grace_period_months')) {
      context.handle(
          _gracePeriodMonthsMeta,
          gracePeriodMonths.isAcceptableOrUnknown(
              data['grace_period_months']!, _gracePeriodMonthsMeta));
    }
    if (data.containsKey('grace_period_end_date')) {
      context.handle(
          _gracePeriodEndDateMeta,
          gracePeriodEndDate.isAcceptableOrUnknown(
              data['grace_period_end_date']!, _gracePeriodEndDateMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoanEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoanEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      principal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}principal'])!,
      remainingBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remaining_balance'])!,
      interestRate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}interest_rate'])!,
      termMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}term_months'])!,
      monthlyPayment: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}monthly_payment'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      hasGracePeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_grace_period'])!,
      gracePeriodMonths: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}grace_period_months']),
      gracePeriodEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}grace_period_end_date']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class LoanEntry extends DataClass implements Insertable<LoanEntry> {
  final String id;
  final String type;
  final String name;
  final String principal;
  final String remainingBalance;
  final String interestRate;
  final int termMonths;
  final String monthlyPayment;
  final String currency;
  final bool hasGracePeriod;
  final int? gracePeriodMonths;
  final String? gracePeriodEndDate;
  final String startDate;
  final String sourceType;
  final String? sourceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LoanEntry(
      {required this.id,
      required this.type,
      required this.name,
      required this.principal,
      required this.remainingBalance,
      required this.interestRate,
      required this.termMonths,
      required this.monthlyPayment,
      required this.currency,
      required this.hasGracePeriod,
      this.gracePeriodMonths,
      this.gracePeriodEndDate,
      required this.startDate,
      required this.sourceType,
      this.sourceId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['principal'] = Variable<String>(principal);
    map['remaining_balance'] = Variable<String>(remainingBalance);
    map['interest_rate'] = Variable<String>(interestRate);
    map['term_months'] = Variable<int>(termMonths);
    map['monthly_payment'] = Variable<String>(monthlyPayment);
    map['currency'] = Variable<String>(currency);
    map['has_grace_period'] = Variable<bool>(hasGracePeriod);
    if (!nullToAbsent || gracePeriodMonths != null) {
      map['grace_period_months'] = Variable<int>(gracePeriodMonths);
    }
    if (!nullToAbsent || gracePeriodEndDate != null) {
      map['grace_period_end_date'] = Variable<String>(gracePeriodEndDate);
    }
    map['start_date'] = Variable<String>(startDate);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      type: Value(type),
      name: Value(name),
      principal: Value(principal),
      remainingBalance: Value(remainingBalance),
      interestRate: Value(interestRate),
      termMonths: Value(termMonths),
      monthlyPayment: Value(monthlyPayment),
      currency: Value(currency),
      hasGracePeriod: Value(hasGracePeriod),
      gracePeriodMonths: gracePeriodMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(gracePeriodMonths),
      gracePeriodEndDate: gracePeriodEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(gracePeriodEndDate),
      startDate: Value(startDate),
      sourceType: Value(sourceType),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LoanEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoanEntry(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      principal: serializer.fromJson<String>(json['principal']),
      remainingBalance: serializer.fromJson<String>(json['remainingBalance']),
      interestRate: serializer.fromJson<String>(json['interestRate']),
      termMonths: serializer.fromJson<int>(json['termMonths']),
      monthlyPayment: serializer.fromJson<String>(json['monthlyPayment']),
      currency: serializer.fromJson<String>(json['currency']),
      hasGracePeriod: serializer.fromJson<bool>(json['hasGracePeriod']),
      gracePeriodMonths: serializer.fromJson<int?>(json['gracePeriodMonths']),
      gracePeriodEndDate:
          serializer.fromJson<String?>(json['gracePeriodEndDate']),
      startDate: serializer.fromJson<String>(json['startDate']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'principal': serializer.toJson<String>(principal),
      'remainingBalance': serializer.toJson<String>(remainingBalance),
      'interestRate': serializer.toJson<String>(interestRate),
      'termMonths': serializer.toJson<int>(termMonths),
      'monthlyPayment': serializer.toJson<String>(monthlyPayment),
      'currency': serializer.toJson<String>(currency),
      'hasGracePeriod': serializer.toJson<bool>(hasGracePeriod),
      'gracePeriodMonths': serializer.toJson<int?>(gracePeriodMonths),
      'gracePeriodEndDate': serializer.toJson<String?>(gracePeriodEndDate),
      'startDate': serializer.toJson<String>(startDate),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String?>(sourceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LoanEntry copyWith(
          {String? id,
          String? type,
          String? name,
          String? principal,
          String? remainingBalance,
          String? interestRate,
          int? termMonths,
          String? monthlyPayment,
          String? currency,
          bool? hasGracePeriod,
          Value<int?> gracePeriodMonths = const Value.absent(),
          Value<String?> gracePeriodEndDate = const Value.absent(),
          String? startDate,
          String? sourceType,
          Value<String?> sourceId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      LoanEntry(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        principal: principal ?? this.principal,
        remainingBalance: remainingBalance ?? this.remainingBalance,
        interestRate: interestRate ?? this.interestRate,
        termMonths: termMonths ?? this.termMonths,
        monthlyPayment: monthlyPayment ?? this.monthlyPayment,
        currency: currency ?? this.currency,
        hasGracePeriod: hasGracePeriod ?? this.hasGracePeriod,
        gracePeriodMonths: gracePeriodMonths.present
            ? gracePeriodMonths.value
            : this.gracePeriodMonths,
        gracePeriodEndDate: gracePeriodEndDate.present
            ? gracePeriodEndDate.value
            : this.gracePeriodEndDate,
        startDate: startDate ?? this.startDate,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LoanEntry copyWithCompanion(LoansCompanion data) {
    return LoanEntry(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      principal: data.principal.present ? data.principal.value : this.principal,
      remainingBalance: data.remainingBalance.present
          ? data.remainingBalance.value
          : this.remainingBalance,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      termMonths:
          data.termMonths.present ? data.termMonths.value : this.termMonths,
      monthlyPayment: data.monthlyPayment.present
          ? data.monthlyPayment.value
          : this.monthlyPayment,
      currency: data.currency.present ? data.currency.value : this.currency,
      hasGracePeriod: data.hasGracePeriod.present
          ? data.hasGracePeriod.value
          : this.hasGracePeriod,
      gracePeriodMonths: data.gracePeriodMonths.present
          ? data.gracePeriodMonths.value
          : this.gracePeriodMonths,
      gracePeriodEndDate: data.gracePeriodEndDate.present
          ? data.gracePeriodEndDate.value
          : this.gracePeriodEndDate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoanEntry(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('principal: $principal, ')
          ..write('remainingBalance: $remainingBalance, ')
          ..write('interestRate: $interestRate, ')
          ..write('termMonths: $termMonths, ')
          ..write('monthlyPayment: $monthlyPayment, ')
          ..write('currency: $currency, ')
          ..write('hasGracePeriod: $hasGracePeriod, ')
          ..write('gracePeriodMonths: $gracePeriodMonths, ')
          ..write('gracePeriodEndDate: $gracePeriodEndDate, ')
          ..write('startDate: $startDate, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      name,
      principal,
      remainingBalance,
      interestRate,
      termMonths,
      monthlyPayment,
      currency,
      hasGracePeriod,
      gracePeriodMonths,
      gracePeriodEndDate,
      startDate,
      sourceType,
      sourceId,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoanEntry &&
          other.id == this.id &&
          other.type == this.type &&
          other.name == this.name &&
          other.principal == this.principal &&
          other.remainingBalance == this.remainingBalance &&
          other.interestRate == this.interestRate &&
          other.termMonths == this.termMonths &&
          other.monthlyPayment == this.monthlyPayment &&
          other.currency == this.currency &&
          other.hasGracePeriod == this.hasGracePeriod &&
          other.gracePeriodMonths == this.gracePeriodMonths &&
          other.gracePeriodEndDate == this.gracePeriodEndDate &&
          other.startDate == this.startDate &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LoansCompanion extends UpdateCompanion<LoanEntry> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> name;
  final Value<String> principal;
  final Value<String> remainingBalance;
  final Value<String> interestRate;
  final Value<int> termMonths;
  final Value<String> monthlyPayment;
  final Value<String> currency;
  final Value<bool> hasGracePeriod;
  final Value<int?> gracePeriodMonths;
  final Value<String?> gracePeriodEndDate;
  final Value<String> startDate;
  final Value<String> sourceType;
  final Value<String?> sourceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.principal = const Value.absent(),
    this.remainingBalance = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.termMonths = const Value.absent(),
    this.monthlyPayment = const Value.absent(),
    this.currency = const Value.absent(),
    this.hasGracePeriod = const Value.absent(),
    this.gracePeriodMonths = const Value.absent(),
    this.gracePeriodEndDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoansCompanion.insert({
    required String id,
    required String type,
    required String name,
    required String principal,
    required String remainingBalance,
    required String interestRate,
    required int termMonths,
    required String monthlyPayment,
    required String currency,
    this.hasGracePeriod = const Value.absent(),
    this.gracePeriodMonths = const Value.absent(),
    this.gracePeriodEndDate = const Value.absent(),
    required String startDate,
    required String sourceType,
    this.sourceId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        name = Value(name),
        principal = Value(principal),
        remainingBalance = Value(remainingBalance),
        interestRate = Value(interestRate),
        termMonths = Value(termMonths),
        monthlyPayment = Value(monthlyPayment),
        currency = Value(currency),
        startDate = Value(startDate),
        sourceType = Value(sourceType),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LoanEntry> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? principal,
    Expression<String>? remainingBalance,
    Expression<String>? interestRate,
    Expression<int>? termMonths,
    Expression<String>? monthlyPayment,
    Expression<String>? currency,
    Expression<bool>? hasGracePeriod,
    Expression<int>? gracePeriodMonths,
    Expression<String>? gracePeriodEndDate,
    Expression<String>? startDate,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (principal != null) 'principal': principal,
      if (remainingBalance != null) 'remaining_balance': remainingBalance,
      if (interestRate != null) 'interest_rate': interestRate,
      if (termMonths != null) 'term_months': termMonths,
      if (monthlyPayment != null) 'monthly_payment': monthlyPayment,
      if (currency != null) 'currency': currency,
      if (hasGracePeriod != null) 'has_grace_period': hasGracePeriod,
      if (gracePeriodMonths != null) 'grace_period_months': gracePeriodMonths,
      if (gracePeriodEndDate != null)
        'grace_period_end_date': gracePeriodEndDate,
      if (startDate != null) 'start_date': startDate,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoansCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? name,
      Value<String>? principal,
      Value<String>? remainingBalance,
      Value<String>? interestRate,
      Value<int>? termMonths,
      Value<String>? monthlyPayment,
      Value<String>? currency,
      Value<bool>? hasGracePeriod,
      Value<int?>? gracePeriodMonths,
      Value<String?>? gracePeriodEndDate,
      Value<String>? startDate,
      Value<String>? sourceType,
      Value<String?>? sourceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LoansCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      principal: principal ?? this.principal,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      interestRate: interestRate ?? this.interestRate,
      termMonths: termMonths ?? this.termMonths,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      currency: currency ?? this.currency,
      hasGracePeriod: hasGracePeriod ?? this.hasGracePeriod,
      gracePeriodMonths: gracePeriodMonths ?? this.gracePeriodMonths,
      gracePeriodEndDate: gracePeriodEndDate ?? this.gracePeriodEndDate,
      startDate: startDate ?? this.startDate,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (principal.present) {
      map['principal'] = Variable<String>(principal.value);
    }
    if (remainingBalance.present) {
      map['remaining_balance'] = Variable<String>(remainingBalance.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<String>(interestRate.value);
    }
    if (termMonths.present) {
      map['term_months'] = Variable<int>(termMonths.value);
    }
    if (monthlyPayment.present) {
      map['monthly_payment'] = Variable<String>(monthlyPayment.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (hasGracePeriod.present) {
      map['has_grace_period'] = Variable<bool>(hasGracePeriod.value);
    }
    if (gracePeriodMonths.present) {
      map['grace_period_months'] = Variable<int>(gracePeriodMonths.value);
    }
    if (gracePeriodEndDate.present) {
      map['grace_period_end_date'] = Variable<String>(gracePeriodEndDate.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('principal: $principal, ')
          ..write('remainingBalance: $remainingBalance, ')
          ..write('interestRate: $interestRate, ')
          ..write('termMonths: $termMonths, ')
          ..write('monthlyPayment: $monthlyPayment, ')
          ..write('currency: $currency, ')
          ..write('hasGracePeriod: $hasGracePeriod, ')
          ..write('gracePeriodMonths: $gracePeriodMonths, ')
          ..write('gracePeriodEndDate: $gracePeriodEndDate, ')
          ..write('startDate: $startDate, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashAccountsTable extends CashAccounts
    with TableInfo<$CashAccountsTable, CashAccountEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<String> balance = GeneratedColumn<String>(
      'balance', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, bankName, balance, currency, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<CashAccountEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashAccountEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashAccountEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name']),
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}balance'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CashAccountsTable createAlias(String alias) {
    return $CashAccountsTable(attachedDatabase, alias);
  }
}

class CashAccountEntry extends DataClass
    implements Insertable<CashAccountEntry> {
  final String id;
  final String name;
  final String? bankName;
  final String balance;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CashAccountEntry(
      {required this.id,
      required this.name,
      this.bankName,
      required this.balance,
      required this.currency,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || bankName != null) {
      map['bank_name'] = Variable<String>(bankName);
    }
    map['balance'] = Variable<String>(balance);
    map['currency'] = Variable<String>(currency);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CashAccountsCompanion toCompanion(bool nullToAbsent) {
    return CashAccountsCompanion(
      id: Value(id),
      name: Value(name),
      bankName: bankName == null && nullToAbsent
          ? const Value.absent()
          : Value(bankName),
      balance: Value(balance),
      currency: Value(currency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CashAccountEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashAccountEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bankName: serializer.fromJson<String?>(json['bankName']),
      balance: serializer.fromJson<String>(json['balance']),
      currency: serializer.fromJson<String>(json['currency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bankName': serializer.toJson<String?>(bankName),
      'balance': serializer.toJson<String>(balance),
      'currency': serializer.toJson<String>(currency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CashAccountEntry copyWith(
          {String? id,
          String? name,
          Value<String?> bankName = const Value.absent(),
          String? balance,
          String? currency,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CashAccountEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        bankName: bankName.present ? bankName.value : this.bankName,
        balance: balance ?? this.balance,
        currency: currency ?? this.currency,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CashAccountEntry copyWithCompanion(CashAccountsCompanion data) {
    return CashAccountEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      balance: data.balance.present ? data.balance.value : this.balance,
      currency: data.currency.present ? data.currency.value : this.currency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashAccountEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bankName: $bankName, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, bankName, balance, currency, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashAccountEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.bankName == this.bankName &&
          other.balance == this.balance &&
          other.currency == this.currency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CashAccountsCompanion extends UpdateCompanion<CashAccountEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> bankName;
  final Value<String> balance;
  final Value<String> currency;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CashAccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bankName = const Value.absent(),
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashAccountsCompanion.insert({
    required String id,
    required String name,
    this.bankName = const Value.absent(),
    required String balance,
    required String currency,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        balance = Value(balance),
        currency = Value(currency),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CashAccountEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bankName,
    Expression<String>? balance,
    Expression<String>? currency,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bankName != null) 'bank_name': bankName,
      if (balance != null) 'balance': balance,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashAccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? bankName,
      Value<String>? balance,
      Value<String>? currency,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CashAccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (balance.present) {
      map['balance'] = Variable<String>(balance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashAccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bankName: $bankName, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRatesTable extends ExchangeRates
    with TableInfo<$ExchangeRatesTable, ExchangeRateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromCurrencyMeta =
      const VerificationMeta('fromCurrency');
  @override
  late final GeneratedColumn<String> fromCurrency = GeneratedColumn<String>(
      'from_currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toCurrencyMeta =
      const VerificationMeta('toCurrency');
  @override
  late final GeneratedColumn<String> toCurrency = GeneratedColumn<String>(
      'to_currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<String> rate = GeneratedColumn<String>(
      'rate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, fromCurrency, toCurrency, rate, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rates';
  @override
  VerificationContext validateIntegrity(Insertable<ExchangeRateEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_currency')) {
      context.handle(
          _fromCurrencyMeta,
          fromCurrency.isAcceptableOrUnknown(
              data['from_currency']!, _fromCurrencyMeta));
    } else if (isInserting) {
      context.missing(_fromCurrencyMeta);
    }
    if (data.containsKey('to_currency')) {
      context.handle(
          _toCurrencyMeta,
          toCurrency.isAcceptableOrUnknown(
              data['to_currency']!, _toCurrencyMeta));
    } else if (isInserting) {
      context.missing(_toCurrencyMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
          _rateMeta, rate.isAcceptableOrUnknown(data['rate']!, _rateMeta));
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExchangeRateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRateEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fromCurrency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_currency'])!,
      toCurrency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_currency'])!,
      rate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rate'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $ExchangeRatesTable createAlias(String alias) {
    return $ExchangeRatesTable(attachedDatabase, alias);
  }
}

class ExchangeRateEntry extends DataClass
    implements Insertable<ExchangeRateEntry> {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final String rate;
  final DateTime fetchedAt;
  const ExchangeRateEntry(
      {required this.id,
      required this.fromCurrency,
      required this.toCurrency,
      required this.rate,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_currency'] = Variable<String>(fromCurrency);
    map['to_currency'] = Variable<String>(toCurrency);
    map['rate'] = Variable<String>(rate);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesCompanion(
      id: Value(id),
      fromCurrency: Value(fromCurrency),
      toCurrency: Value(toCurrency),
      rate: Value(rate),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ExchangeRateEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRateEntry(
      id: serializer.fromJson<String>(json['id']),
      fromCurrency: serializer.fromJson<String>(json['fromCurrency']),
      toCurrency: serializer.fromJson<String>(json['toCurrency']),
      rate: serializer.fromJson<String>(json['rate']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromCurrency': serializer.toJson<String>(fromCurrency),
      'toCurrency': serializer.toJson<String>(toCurrency),
      'rate': serializer.toJson<String>(rate),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ExchangeRateEntry copyWith(
          {String? id,
          String? fromCurrency,
          String? toCurrency,
          String? rate,
          DateTime? fetchedAt}) =>
      ExchangeRateEntry(
        id: id ?? this.id,
        fromCurrency: fromCurrency ?? this.fromCurrency,
        toCurrency: toCurrency ?? this.toCurrency,
        rate: rate ?? this.rate,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  ExchangeRateEntry copyWithCompanion(ExchangeRatesCompanion data) {
    return ExchangeRateEntry(
      id: data.id.present ? data.id.value : this.id,
      fromCurrency: data.fromCurrency.present
          ? data.fromCurrency.value
          : this.fromCurrency,
      toCurrency:
          data.toCurrency.present ? data.toCurrency.value : this.toCurrency,
      rate: data.rate.present ? data.rate.value : this.rate,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateEntry(')
          ..write('id: $id, ')
          ..write('fromCurrency: $fromCurrency, ')
          ..write('toCurrency: $toCurrency, ')
          ..write('rate: $rate, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fromCurrency, toCurrency, rate, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRateEntry &&
          other.id == this.id &&
          other.fromCurrency == this.fromCurrency &&
          other.toCurrency == this.toCurrency &&
          other.rate == this.rate &&
          other.fetchedAt == this.fetchedAt);
}

class ExchangeRatesCompanion extends UpdateCompanion<ExchangeRateEntry> {
  final Value<String> id;
  final Value<String> fromCurrency;
  final Value<String> toCurrency;
  final Value<String> rate;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const ExchangeRatesCompanion({
    this.id = const Value.absent(),
    this.fromCurrency = const Value.absent(),
    this.toCurrency = const Value.absent(),
    this.rate = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeRatesCompanion.insert({
    required String id,
    required String fromCurrency,
    required String toCurrency,
    required String rate,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fromCurrency = Value(fromCurrency),
        toCurrency = Value(toCurrency),
        rate = Value(rate),
        fetchedAt = Value(fetchedAt);
  static Insertable<ExchangeRateEntry> custom({
    Expression<String>? id,
    Expression<String>? fromCurrency,
    Expression<String>? toCurrency,
    Expression<String>? rate,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromCurrency != null) 'from_currency': fromCurrency,
      if (toCurrency != null) 'to_currency': toCurrency,
      if (rate != null) 'rate': rate,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeRatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? fromCurrency,
      Value<String>? toCurrency,
      Value<String>? rate,
      Value<DateTime>? fetchedAt,
      Value<int>? rowid}) {
    return ExchangeRatesCompanion(
      id: id ?? this.id,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rate: rate ?? this.rate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromCurrency.present) {
      map['from_currency'] = Variable<String>(fromCurrency.value);
    }
    if (toCurrency.present) {
      map['to_currency'] = Variable<String>(toCurrency.value);
    }
    if (rate.present) {
      map['rate'] = Variable<String>(rate.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRatesCompanion(')
          ..write('id: $id, ')
          ..write('fromCurrency: $fromCurrency, ')
          ..write('toCurrency: $toCurrency, ')
          ..write('rate: $rate, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StocksTable stocks = $StocksTable(this);
  late final $RealEstateTable realEstate = $RealEstateTable(this);
  late final $LoansTable loans = $LoansTable(this);
  late final $CashAccountsTable cashAccounts = $CashAccountsTable(this);
  late final $ExchangeRatesTable exchangeRates = $ExchangeRatesTable(this);
  late final StockDao stockDao = StockDao(this as AppDatabase);
  late final RealEstateDao realEstateDao = RealEstateDao(this as AppDatabase);
  late final LoanDao loanDao = LoanDao(this as AppDatabase);
  late final CashDao cashDao = CashDao(this as AppDatabase);
  late final ExchangeRateDao exchangeRateDao =
      ExchangeRateDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [stocks, realEstate, loans, cashAccounts, exchangeRates];
}

typedef $$StocksTableCreateCompanionBuilder = StocksCompanion Function({
  required String id,
  required String symbol,
  required String market,
  required String name,
  required int quantity,
  required String avgCost,
  required String currency,
  Value<bool> isMargin,
  Value<String?> marginAmount,
  Value<String?> linkedLoanId,
  Value<String?> latestPrice,
  Value<DateTime?> priceUpdatedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$StocksTableUpdateCompanionBuilder = StocksCompanion Function({
  Value<String> id,
  Value<String> symbol,
  Value<String> market,
  Value<String> name,
  Value<int> quantity,
  Value<String> avgCost,
  Value<String> currency,
  Value<bool> isMargin,
  Value<String?> marginAmount,
  Value<String?> linkedLoanId,
  Value<String?> latestPrice,
  Value<DateTime?> priceUpdatedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$StocksTableFilterComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get market => $composableBuilder(
      column: $table.market, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avgCost => $composableBuilder(
      column: $table.avgCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMargin => $composableBuilder(
      column: $table.isMargin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get marginAmount => $composableBuilder(
      column: $table.marginAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedLoanId => $composableBuilder(
      column: $table.linkedLoanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get latestPrice => $composableBuilder(
      column: $table.latestPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get priceUpdatedAt => $composableBuilder(
      column: $table.priceUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$StocksTableOrderingComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get market => $composableBuilder(
      column: $table.market, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avgCost => $composableBuilder(
      column: $table.avgCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMargin => $composableBuilder(
      column: $table.isMargin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get marginAmount => $composableBuilder(
      column: $table.marginAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedLoanId => $composableBuilder(
      column: $table.linkedLoanId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get latestPrice => $composableBuilder(
      column: $table.latestPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get priceUpdatedAt => $composableBuilder(
      column: $table.priceUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$StocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get avgCost =>
      $composableBuilder(column: $table.avgCost, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get isMargin =>
      $composableBuilder(column: $table.isMargin, builder: (column) => column);

  GeneratedColumn<String> get marginAmount => $composableBuilder(
      column: $table.marginAmount, builder: (column) => column);

  GeneratedColumn<String> get linkedLoanId => $composableBuilder(
      column: $table.linkedLoanId, builder: (column) => column);

  GeneratedColumn<String> get latestPrice => $composableBuilder(
      column: $table.latestPrice, builder: (column) => column);

  GeneratedColumn<DateTime> get priceUpdatedAt => $composableBuilder(
      column: $table.priceUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StocksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StocksTable,
    StockEntry,
    $$StocksTableFilterComposer,
    $$StocksTableOrderingComposer,
    $$StocksTableAnnotationComposer,
    $$StocksTableCreateCompanionBuilder,
    $$StocksTableUpdateCompanionBuilder,
    (StockEntry, BaseReferences<_$AppDatabase, $StocksTable, StockEntry>),
    StockEntry,
    PrefetchHooks Function()> {
  $$StocksTableTableManager(_$AppDatabase db, $StocksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<String> market = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> avgCost = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> isMargin = const Value.absent(),
            Value<String?> marginAmount = const Value.absent(),
            Value<String?> linkedLoanId = const Value.absent(),
            Value<String?> latestPrice = const Value.absent(),
            Value<DateTime?> priceUpdatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StocksCompanion(
            id: id,
            symbol: symbol,
            market: market,
            name: name,
            quantity: quantity,
            avgCost: avgCost,
            currency: currency,
            isMargin: isMargin,
            marginAmount: marginAmount,
            linkedLoanId: linkedLoanId,
            latestPrice: latestPrice,
            priceUpdatedAt: priceUpdatedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String symbol,
            required String market,
            required String name,
            required int quantity,
            required String avgCost,
            required String currency,
            Value<bool> isMargin = const Value.absent(),
            Value<String?> marginAmount = const Value.absent(),
            Value<String?> linkedLoanId = const Value.absent(),
            Value<String?> latestPrice = const Value.absent(),
            Value<DateTime?> priceUpdatedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StocksCompanion.insert(
            id: id,
            symbol: symbol,
            market: market,
            name: name,
            quantity: quantity,
            avgCost: avgCost,
            currency: currency,
            isMargin: isMargin,
            marginAmount: marginAmount,
            linkedLoanId: linkedLoanId,
            latestPrice: latestPrice,
            priceUpdatedAt: priceUpdatedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StocksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StocksTable,
    StockEntry,
    $$StocksTableFilterComposer,
    $$StocksTableOrderingComposer,
    $$StocksTableAnnotationComposer,
    $$StocksTableCreateCompanionBuilder,
    $$StocksTableUpdateCompanionBuilder,
    (StockEntry, BaseReferences<_$AppDatabase, $StocksTable, StockEntry>),
    StockEntry,
    PrefetchHooks Function()>;
typedef $$RealEstateTableCreateCompanionBuilder = RealEstateCompanion Function({
  required String id,
  required String name,
  required String address,
  required String estimatedValue,
  required String purchasePrice,
  required String purchaseDate,
  required String currency,
  Value<bool> hasMortgage,
  Value<String?> linkedLoanId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RealEstateTableUpdateCompanionBuilder = RealEstateCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> address,
  Value<String> estimatedValue,
  Value<String> purchasePrice,
  Value<String> purchaseDate,
  Value<String> currency,
  Value<bool> hasMortgage,
  Value<String?> linkedLoanId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RealEstateTableFilterComposer
    extends Composer<_$AppDatabase, $RealEstateTable> {
  $$RealEstateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estimatedValue => $composableBuilder(
      column: $table.estimatedValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasMortgage => $composableBuilder(
      column: $table.hasMortgage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedLoanId => $composableBuilder(
      column: $table.linkedLoanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$RealEstateTableOrderingComposer
    extends Composer<_$AppDatabase, $RealEstateTable> {
  $$RealEstateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estimatedValue => $composableBuilder(
      column: $table.estimatedValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasMortgage => $composableBuilder(
      column: $table.hasMortgage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedLoanId => $composableBuilder(
      column: $table.linkedLoanId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RealEstateTableAnnotationComposer
    extends Composer<_$AppDatabase, $RealEstateTable> {
  $$RealEstateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get estimatedValue => $composableBuilder(
      column: $table.estimatedValue, builder: (column) => column);

  GeneratedColumn<String> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<String> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get hasMortgage => $composableBuilder(
      column: $table.hasMortgage, builder: (column) => column);

  GeneratedColumn<String> get linkedLoanId => $composableBuilder(
      column: $table.linkedLoanId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RealEstateTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RealEstateTable,
    RealEstateEntry,
    $$RealEstateTableFilterComposer,
    $$RealEstateTableOrderingComposer,
    $$RealEstateTableAnnotationComposer,
    $$RealEstateTableCreateCompanionBuilder,
    $$RealEstateTableUpdateCompanionBuilder,
    (
      RealEstateEntry,
      BaseReferences<_$AppDatabase, $RealEstateTable, RealEstateEntry>
    ),
    RealEstateEntry,
    PrefetchHooks Function()> {
  $$RealEstateTableTableManager(_$AppDatabase db, $RealEstateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RealEstateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RealEstateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RealEstateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> estimatedValue = const Value.absent(),
            Value<String> purchasePrice = const Value.absent(),
            Value<String> purchaseDate = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> hasMortgage = const Value.absent(),
            Value<String?> linkedLoanId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RealEstateCompanion(
            id: id,
            name: name,
            address: address,
            estimatedValue: estimatedValue,
            purchasePrice: purchasePrice,
            purchaseDate: purchaseDate,
            currency: currency,
            hasMortgage: hasMortgage,
            linkedLoanId: linkedLoanId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String address,
            required String estimatedValue,
            required String purchasePrice,
            required String purchaseDate,
            required String currency,
            Value<bool> hasMortgage = const Value.absent(),
            Value<String?> linkedLoanId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RealEstateCompanion.insert(
            id: id,
            name: name,
            address: address,
            estimatedValue: estimatedValue,
            purchasePrice: purchasePrice,
            purchaseDate: purchaseDate,
            currency: currency,
            hasMortgage: hasMortgage,
            linkedLoanId: linkedLoanId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RealEstateTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RealEstateTable,
    RealEstateEntry,
    $$RealEstateTableFilterComposer,
    $$RealEstateTableOrderingComposer,
    $$RealEstateTableAnnotationComposer,
    $$RealEstateTableCreateCompanionBuilder,
    $$RealEstateTableUpdateCompanionBuilder,
    (
      RealEstateEntry,
      BaseReferences<_$AppDatabase, $RealEstateTable, RealEstateEntry>
    ),
    RealEstateEntry,
    PrefetchHooks Function()>;
typedef $$LoansTableCreateCompanionBuilder = LoansCompanion Function({
  required String id,
  required String type,
  required String name,
  required String principal,
  required String remainingBalance,
  required String interestRate,
  required int termMonths,
  required String monthlyPayment,
  required String currency,
  Value<bool> hasGracePeriod,
  Value<int?> gracePeriodMonths,
  Value<String?> gracePeriodEndDate,
  required String startDate,
  required String sourceType,
  Value<String?> sourceId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$LoansTableUpdateCompanionBuilder = LoansCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> name,
  Value<String> principal,
  Value<String> remainingBalance,
  Value<String> interestRate,
  Value<int> termMonths,
  Value<String> monthlyPayment,
  Value<String> currency,
  Value<bool> hasGracePeriod,
  Value<int?> gracePeriodMonths,
  Value<String?> gracePeriodEndDate,
  Value<String> startDate,
  Value<String> sourceType,
  Value<String?> sourceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LoansTableFilterComposer extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get principal => $composableBuilder(
      column: $table.principal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remainingBalance => $composableBuilder(
      column: $table.remainingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get interestRate => $composableBuilder(
      column: $table.interestRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get termMonths => $composableBuilder(
      column: $table.termMonths, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get monthlyPayment => $composableBuilder(
      column: $table.monthlyPayment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasGracePeriod => $composableBuilder(
      column: $table.hasGracePeriod,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gracePeriodMonths => $composableBuilder(
      column: $table.gracePeriodMonths,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gracePeriodEndDate => $composableBuilder(
      column: $table.gracePeriodEndDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LoansTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get principal => $composableBuilder(
      column: $table.principal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remainingBalance => $composableBuilder(
      column: $table.remainingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get interestRate => $composableBuilder(
      column: $table.interestRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get termMonths => $composableBuilder(
      column: $table.termMonths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get monthlyPayment => $composableBuilder(
      column: $table.monthlyPayment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasGracePeriod => $composableBuilder(
      column: $table.hasGracePeriod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gracePeriodMonths => $composableBuilder(
      column: $table.gracePeriodMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gracePeriodEndDate => $composableBuilder(
      column: $table.gracePeriodEndDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get principal =>
      $composableBuilder(column: $table.principal, builder: (column) => column);

  GeneratedColumn<String> get remainingBalance => $composableBuilder(
      column: $table.remainingBalance, builder: (column) => column);

  GeneratedColumn<String> get interestRate => $composableBuilder(
      column: $table.interestRate, builder: (column) => column);

  GeneratedColumn<int> get termMonths => $composableBuilder(
      column: $table.termMonths, builder: (column) => column);

  GeneratedColumn<String> get monthlyPayment => $composableBuilder(
      column: $table.monthlyPayment, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get hasGracePeriod => $composableBuilder(
      column: $table.hasGracePeriod, builder: (column) => column);

  GeneratedColumn<int> get gracePeriodMonths => $composableBuilder(
      column: $table.gracePeriodMonths, builder: (column) => column);

  GeneratedColumn<String> get gracePeriodEndDate => $composableBuilder(
      column: $table.gracePeriodEndDate, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LoansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LoansTable,
    LoanEntry,
    $$LoansTableFilterComposer,
    $$LoansTableOrderingComposer,
    $$LoansTableAnnotationComposer,
    $$LoansTableCreateCompanionBuilder,
    $$LoansTableUpdateCompanionBuilder,
    (LoanEntry, BaseReferences<_$AppDatabase, $LoansTable, LoanEntry>),
    LoanEntry,
    PrefetchHooks Function()> {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> principal = const Value.absent(),
            Value<String> remainingBalance = const Value.absent(),
            Value<String> interestRate = const Value.absent(),
            Value<int> termMonths = const Value.absent(),
            Value<String> monthlyPayment = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> hasGracePeriod = const Value.absent(),
            Value<int?> gracePeriodMonths = const Value.absent(),
            Value<String?> gracePeriodEndDate = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String?> sourceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoansCompanion(
            id: id,
            type: type,
            name: name,
            principal: principal,
            remainingBalance: remainingBalance,
            interestRate: interestRate,
            termMonths: termMonths,
            monthlyPayment: monthlyPayment,
            currency: currency,
            hasGracePeriod: hasGracePeriod,
            gracePeriodMonths: gracePeriodMonths,
            gracePeriodEndDate: gracePeriodEndDate,
            startDate: startDate,
            sourceType: sourceType,
            sourceId: sourceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String name,
            required String principal,
            required String remainingBalance,
            required String interestRate,
            required int termMonths,
            required String monthlyPayment,
            required String currency,
            Value<bool> hasGracePeriod = const Value.absent(),
            Value<int?> gracePeriodMonths = const Value.absent(),
            Value<String?> gracePeriodEndDate = const Value.absent(),
            required String startDate,
            required String sourceType,
            Value<String?> sourceId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LoansCompanion.insert(
            id: id,
            type: type,
            name: name,
            principal: principal,
            remainingBalance: remainingBalance,
            interestRate: interestRate,
            termMonths: termMonths,
            monthlyPayment: monthlyPayment,
            currency: currency,
            hasGracePeriod: hasGracePeriod,
            gracePeriodMonths: gracePeriodMonths,
            gracePeriodEndDate: gracePeriodEndDate,
            startDate: startDate,
            sourceType: sourceType,
            sourceId: sourceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LoansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LoansTable,
    LoanEntry,
    $$LoansTableFilterComposer,
    $$LoansTableOrderingComposer,
    $$LoansTableAnnotationComposer,
    $$LoansTableCreateCompanionBuilder,
    $$LoansTableUpdateCompanionBuilder,
    (LoanEntry, BaseReferences<_$AppDatabase, $LoansTable, LoanEntry>),
    LoanEntry,
    PrefetchHooks Function()>;
typedef $$CashAccountsTableCreateCompanionBuilder = CashAccountsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> bankName,
  required String balance,
  required String currency,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CashAccountsTableUpdateCompanionBuilder = CashAccountsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> bankName,
  Value<String> balance,
  Value<String> currency,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CashAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $CashAccountsTable> {
  $$CashAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CashAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashAccountsTable> {
  $$CashAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CashAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashAccountsTable> {
  $$CashAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CashAccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CashAccountsTable,
    CashAccountEntry,
    $$CashAccountsTableFilterComposer,
    $$CashAccountsTableOrderingComposer,
    $$CashAccountsTableAnnotationComposer,
    $$CashAccountsTableCreateCompanionBuilder,
    $$CashAccountsTableUpdateCompanionBuilder,
    (
      CashAccountEntry,
      BaseReferences<_$AppDatabase, $CashAccountsTable, CashAccountEntry>
    ),
    CashAccountEntry,
    PrefetchHooks Function()> {
  $$CashAccountsTableTableManager(_$AppDatabase db, $CashAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> bankName = const Value.absent(),
            Value<String> balance = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CashAccountsCompanion(
            id: id,
            name: name,
            bankName: bankName,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> bankName = const Value.absent(),
            required String balance,
            required String currency,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CashAccountsCompanion.insert(
            id: id,
            name: name,
            bankName: bankName,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CashAccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CashAccountsTable,
    CashAccountEntry,
    $$CashAccountsTableFilterComposer,
    $$CashAccountsTableOrderingComposer,
    $$CashAccountsTableAnnotationComposer,
    $$CashAccountsTableCreateCompanionBuilder,
    $$CashAccountsTableUpdateCompanionBuilder,
    (
      CashAccountEntry,
      BaseReferences<_$AppDatabase, $CashAccountsTable, CashAccountEntry>
    ),
    CashAccountEntry,
    PrefetchHooks Function()>;
typedef $$ExchangeRatesTableCreateCompanionBuilder = ExchangeRatesCompanion
    Function({
  required String id,
  required String fromCurrency,
  required String toCurrency,
  required String rate,
  required DateTime fetchedAt,
  Value<int> rowid,
});
typedef $$ExchangeRatesTableUpdateCompanionBuilder = ExchangeRatesCompanion
    Function({
  Value<String> id,
  Value<String> fromCurrency,
  Value<String> toCurrency,
  Value<String> rate,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});

class $$ExchangeRatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromCurrency => $composableBuilder(
      column: $table.fromCurrency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toCurrency => $composableBuilder(
      column: $table.toCurrency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rate => $composableBuilder(
      column: $table.rate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));
}

class $$ExchangeRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromCurrency => $composableBuilder(
      column: $table.fromCurrency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toCurrency => $composableBuilder(
      column: $table.toCurrency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rate => $composableBuilder(
      column: $table.rate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));
}

class $$ExchangeRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromCurrency => $composableBuilder(
      column: $table.fromCurrency, builder: (column) => column);

  GeneratedColumn<String> get toCurrency => $composableBuilder(
      column: $table.toCurrency, builder: (column) => column);

  GeneratedColumn<String> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ExchangeRatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExchangeRatesTable,
    ExchangeRateEntry,
    $$ExchangeRatesTableFilterComposer,
    $$ExchangeRatesTableOrderingComposer,
    $$ExchangeRatesTableAnnotationComposer,
    $$ExchangeRatesTableCreateCompanionBuilder,
    $$ExchangeRatesTableUpdateCompanionBuilder,
    (
      ExchangeRateEntry,
      BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRateEntry>
    ),
    ExchangeRateEntry,
    PrefetchHooks Function()> {
  $$ExchangeRatesTableTableManager(_$AppDatabase db, $ExchangeRatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fromCurrency = const Value.absent(),
            Value<String> toCurrency = const Value.absent(),
            Value<String> rate = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExchangeRatesCompanion(
            id: id,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            rate: rate,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fromCurrency,
            required String toCurrency,
            required String rate,
            required DateTime fetchedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExchangeRatesCompanion.insert(
            id: id,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            rate: rate,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExchangeRatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExchangeRatesTable,
    ExchangeRateEntry,
    $$ExchangeRatesTableFilterComposer,
    $$ExchangeRatesTableOrderingComposer,
    $$ExchangeRatesTableAnnotationComposer,
    $$ExchangeRatesTableCreateCompanionBuilder,
    $$ExchangeRatesTableUpdateCompanionBuilder,
    (
      ExchangeRateEntry,
      BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRateEntry>
    ),
    ExchangeRateEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StocksTableTableManager get stocks =>
      $$StocksTableTableManager(_db, _db.stocks);
  $$RealEstateTableTableManager get realEstate =>
      $$RealEstateTableTableManager(_db, _db.realEstate);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
  $$CashAccountsTableTableManager get cashAccounts =>
      $$CashAccountsTableTableManager(_db, _db.cashAccounts);
  $$ExchangeRatesTableTableManager get exchangeRates =>
      $$ExchangeRatesTableTableManager(_db, _db.exchangeRates);
}
