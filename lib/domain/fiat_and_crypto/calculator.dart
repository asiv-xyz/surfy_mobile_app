import 'dart:math';

import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class Calculator {
  Calculator({required this.getTokenPrice});

  final GetTokenPrice getTokenPrice;

  double cryptoToFiatV2(Token token, BigInt amount, double tokenPrice) {
    final tokenData = tokens[token];
    if (tokenData == null) {
      return 0.0;
    }

    final visibleTokenAmount = amount / BigInt.from(pow(10, tokenData.decimal));
    final result = visibleTokenAmount * tokenPrice;
    return result;
  }

  double cryptoAmountToFiatV2(double cryptoAmount, double tokenPrice) {
    return cryptoAmount * tokenPrice;
  }

  double cryptoToDouble(Token token, BigInt amount) {
    print('cryptoToDouble, $token, $amount');
    final tokenData = tokens[token];
    if (tokenData == null) {
      return 0.0;
    }

    return amount / BigInt.from(pow(10, tokenData.decimal));
  }

  double fiatToCryptoV2(double fiat, double tokenPrice) {
    return fiat / tokenPrice;
  }

  BigInt fiatToCryptoAmountV2(double fiat, Token token, double tokenPrice) {
    final tokenData = tokens[token];
    if (tokenData == null) {
      return BigInt.zero;
    }

    final visibleAmount = fiat / tokenPrice;
    return BigInt.from(visibleAmount * pow(10, tokenData.decimal));
  }

  BigInt cryptoWithDecimal(Token token, double visibleCrypto) {
    print('cryptoWithDecimal, $token, $visibleCrypto');
    final tokenData = tokens[token];
    if (tokenData == null) {
      return BigInt.zero;
    }

    return BigInt.from(visibleCrypto * pow(10, tokenData.decimal));
  }
}