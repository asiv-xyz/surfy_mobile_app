import 'dart:math';

import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class Calculator {
  Calculator({required this.getTokenPrice});

  final GetTokenPrice getTokenPrice;

  double cryptoToFiat(Token token, BigInt amount, CurrencyType target) {
    final tokenData = tokens[token];
    if (tokenData == null) {
      return 0.0;
    }

    final tokenPrice = getTokenPrice.tokenPriceObs.value[token];
    final visibleTokenAmount = amount / BigInt.from(pow(10, tokenData.decimal));
    return visibleTokenAmount * (tokenPrice?.price ?? 0.0);
  }

  double cryptoAmountToFiat(Token token, double cryptoAmount, CurrencyType target) {
    final tokenPrice = getTokenPrice.tokenPriceObs.value[token]?.price ?? 0.0;
    return cryptoAmount * tokenPrice;
  }

  double cryptoToDouble(Token token, BigInt amount) {
    final tokenData = tokens[token];
    if (tokenData == null) {
      return 0.0;
    }

    return amount / BigInt.from(pow(10, tokenData.decimal));
  }

  double fiatToCrypto(double fiat, Token token) {
    final tokenData = tokens[token];
    if (tokenData == null) {
      return 0;
    }

    final tokenPrice = getTokenPrice.tokenPriceObs.value[token]?.price ?? 0.0;
    return fiat / tokenPrice;
  }

  BigInt fiatToCryptoAmount(double fiat, Token token) {
    final tokenData = tokens[token];
    if (tokenData == null) {
      return BigInt.zero;
    }

    final tokenPrice = getTokenPrice.tokenPriceObs.value[token]?.price ?? 0.0;
    final visibleAmount = fiat / tokenPrice;
    return BigInt.from(visibleAmount) * BigInt.from(pow(10, tokenData.decimal));
  }

  BigInt cryptoWithDecimal(Token token, double visibleCrypto) {
    final tokenData = tokens[token];
    if (tokenData == null) {
      return BigInt.zero;
    }

    return BigInt.from(visibleCrypto) * BigInt.from(pow(10, tokenData.decimal));
  }
}