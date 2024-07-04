import 'package:get/get.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

enum TransactionType {
  transfer,
  payment,
}

TransactionType _getType(String type) {
  switch (type.toLowerCase()) {
    case "transfer":
      return TransactionType.transfer;
    case "payment":
      return TransactionType.payment;
    default:
      throw Exception();
  }
}

class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.transactionHash,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.senderAddress,
    required this.receiverAddress,
    required this.token,
    required this.blockchain,
    required this.createdAt,
    required this.storeId,
    required this.fiat,
    required this.currencyType,
  });

  final String id;
  final TransactionType type;
  final String transactionHash;
  final String sender;
  final String? receiver;
  final BigInt amount;
  final String senderAddress;
  final String receiverAddress;
  final Token token;
  final Blockchain blockchain;
  final DateTime createdAt;
  final String? storeId;
  final double? fiat;
  final CurrencyType? currencyType;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
        id: json["id"],
        type: _getType(json["type"]),
        transactionHash: json["transactionHash"],
        sender: json["sender"],
        receiver: json["receiver"],
        amount: BigInt.parse(json["amount"]),
        senderAddress: json["senderAddress"],
        receiverAddress: json["receiverAddress"],
        token: findTokenByName(json["token"]),
        blockchain: findBlockchainByName(json["blockchain"]),
        createdAt: DateTime.parse(json["createdAt"]),
        storeId: json["storeId"],
        fiat: json["fiat"]?.toDouble(),
        currencyType: json["currencyType"] == null ? null : findCurrencyTypeByName(json["currencyType"])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type.name.toLowerCase(),
      "transactionHash": transactionHash,
      "sender": sender,
      "receiver": receiver,
      "amount": amount.toString(),
      "senderAddress": senderAddress,
      "receiverAddress": receiverAddress,
      "token": token.name.toLowerCase(),
      "blockchain": blockchain.name.toLowerCase(),
      "createdAt": createdAt.toIso8601String(),
      "storeId": storeId,
      "fiat": fiat,
      "currencyType": currencyType?.name.toLowerCase(),
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}