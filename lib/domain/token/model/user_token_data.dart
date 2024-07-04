import 'dart:math';

import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class UserTokenData {
  const UserTokenData({required this.blockchain, required this.token, required this.amount, required this.decimal, required this.address});

  final Blockchain blockchain;
  final Token token;
  final BigInt amount;
  final int decimal;
  final String address;

  @override
  String toString() {
    return {
      "token": token,
      "blockchain": blockchain,
      "amount": amount,
      "decimal": decimal,
      "address": address,
    }.toString();
  }

  String toUiString() {
    return (amount / BigInt.from(pow(10, decimal).toInt())).toString();
  }

  double toVisibleAmount() {
    return (amount / BigInt.from(pow(10, decimal).toInt())).toDouble();
  }
}