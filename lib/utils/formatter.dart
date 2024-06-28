import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/service/transaction/exceptions/exceptions.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

final formatter = NumberFormat.decimalPattern('en_US');

String formatCrypto(Token? token, double amount) {
  final tokenData = tokens[token];
  int fixedDecimal = 0;
  if (amount == 0) {
    fixedDecimal = 0;
  } else if (amount >= 1.0) {
    fixedDecimal = tokenData?.fixedDecimal ?? 0;
    return "${formatter.format(amount.toStringAsFixed(fixedDecimal).toDouble())} ${tokenData?.symbol}";
  } else if (amount >= 0.1) {
    fixedDecimal = 2;
  } else if (amount >= 0.01) {
    fixedDecimal = 3;
  } else if (amount >= 0.001) {
    fixedDecimal = 4;
  } else if (amount >= 0.0001) {
    fixedDecimal = 5;
  } else if (amount >= 0.00001) {
    fixedDecimal = 6;
  } else if (amount >= 0.000001) {
    fixedDecimal = 7;
  } else if (amount >= 0.0000001) {
    fixedDecimal = 8;
  } else if (amount >= 0.00000001) {
    fixedDecimal = 9;
  } else {
    fixedDecimal = 10;
  }

  return "${amount.toStringAsFixed(fixedDecimal)} ${tokenData?.symbol}";
}

String formatFiat(double amount, CurrencyType currency) {
  final currencyData = currencyTypes[currency];
  int fixedDecimal = 0;
  if (amount == 0) {
    fixedDecimal = 0;
  } else if (amount >= 1.0) {
    fixedDecimal = currencyData["fixedDecimal"] ?? 0;
    return "${formatter.format(amount.toStringAsFixed(fixedDecimal).toDouble())} ${currency.name.toUpperCase()}";
  } else if (amount >= 0.1) {
    fixedDecimal = 2;
  } else if (amount >= 0.01) {
    fixedDecimal = 3;
  } else if (amount >= 0.001) {
    fixedDecimal = 4;
  } else if (amount >= 0.0001) {
    fixedDecimal = 5;
  } else if (amount >= 0.00001) {
    fixedDecimal = 6;
  } else if (amount >= 0.000001) {
    fixedDecimal = 7;
  } else if (amount >= 0.0000001) {
    fixedDecimal = 8;
  } else if (amount >= 0.00000001) {
    fixedDecimal = 9;
  } else {
    fixedDecimal = 10;
  }
  return "${amount.toStringAsFixed(fixedDecimal)} ${currency.name.toUpperCase()}";
}

double cryptoToFiat(Token token, BigInt tokenAmount, double tokenPrice, CurrencyType targetCurrency) {
  final tokenData = tokens[token];
  if (tokenData == null) {
    return 0.0;
  }

  final visibleAmount = tokenAmount / BigInt.from(pow(10, tokenData.decimal));
  return visibleAmount * tokenPrice;
}

double fiatToCrypto(double amount, double tokenPrice) {
  return amount / tokenPrice;
}