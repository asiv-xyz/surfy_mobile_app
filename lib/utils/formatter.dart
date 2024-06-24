import 'package:dartx/dartx.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

final formatter = NumberFormat.decimalPattern('en_US');

String formatCrypto(Token token, double amount) {
  final tokenData = tokens[token];
  if (tokenData == null) {
    return "0";
  }

  if (amount < 1) {
    return "${amount.toStringAsFixed(tokenData.fixedDecimal)} ${tokenData.symbol}";
  }

  return "${formatter.format(amount.toStringAsFixed(tokenData.fixedDecimal).toDouble())} ${tokenData.symbol}";
}

String formatFiat(double amount, CurrencyType currency) {
  final currencyData = currencyTypes[currency];
  return "${formatter.format(amount.toStringAsFixed(currencyData['fixedDecimal'] ?? 0).toDouble())} ${currency.name.toUpperCase()}";
}

