import 'dart:math';

import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class Balance {
  const Balance({
    required this.token,
    required this.blockchain,
    required this.balance,
  });

  final Token token;
  final Blockchain blockchain;
  final BigInt balance;

  @override
  String toString() {
    return {
      "token": token.name,
      "blockchain": blockchain.name,
      "balance": balance,
    }.toString();
  }

  double toFiat(double tokenPrice) {
    final cryptoAmount = balance / BigInt.from(pow(10, tokens[token]?.decimal ?? 0));
    return cryptoAmount * tokenPrice;
  }
}

class FiatBalance {
  FiatBalance({
    required this.token,
    required this.blockchain,
    required this.cryptoBalance,
    required this.balance,
    required this.currencyType,
  });

  final Token token;
  final Blockchain blockchain;
  final BigInt cryptoBalance;
  final double balance;
  final CurrencyType currencyType;

  @override
  String toString() {
    return {
      "token": token,
      "blockchain": blockchain,
      "cryptoBalance": cryptoBalance,
      "balance": balance,
      "currencyType": currencyType.name,
    }.toString();
  }
}