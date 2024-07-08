import 'dart:math';

import 'package:surfy_mobile_app/entity/token/token.dart';

double cryptoAmountToFiat(TokenData token, BigInt cryptoAmount, double tokenPrice) {
  final decimalAmount = cryptoAmount / BigInt.from(pow(10, token.decimal));
  final result = decimalAmount * tokenPrice;
  return result;
}

double decimalCryptoAmountToFiat(double decimalAmount, double tokenPrice) {
  return decimalAmount * tokenPrice;
}

double cryptoAmountToDecimal(TokenData token, BigInt amount) {
  return amount / BigInt.from(pow(10, token.decimal));
}

double fiatToVisibleCryptoAmount(double fiat, double tokenPrice){
  return fiat / tokenPrice;
}

BigInt fiatToCryptoBigInt(double fiat, TokenData token, double tokenPrice) {
  final decimalAmount = fiat / tokenPrice;
  return BigInt.from(decimalAmount * pow(10, token.decimal));
}

BigInt cryptoDecimalToBigInt(TokenData token, double decimalAmount) {
  return BigInt.from(decimalAmount * pow(10, token.decimal));
}