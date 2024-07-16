import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';

class Contact {
  Contact({required this.blockchain, required this.address, this.memo});

  final Blockchain blockchain;
  final String address;
  final String? memo;

  @override
  String toString() {
    return {
      "blockchain": blockchain.name,
      "address": address,
      "memo": memo,
    }.toString();
  }
}