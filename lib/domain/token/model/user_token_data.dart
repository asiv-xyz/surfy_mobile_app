import 'dart:math';

import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class UserTokenData {
  const UserTokenData({required this.blockchain, required this.token, required this.amount, required this.decimal});

  final Blockchain blockchain;
  final Token token;
  final BigInt amount;
  final int decimal;

  @override
  String toString() {
    return {
      "token": token,
      "amount": amount,
      "decimal": decimal,
    }.toString();
  }

  String toUiString() {
    return (amount / BigInt.from(pow(10, decimal).toInt())).toString();
  }

  double toVisibleAmount() {
    return (amount / BigInt.from(pow(10, decimal).toInt())).toDouble();
  }
}