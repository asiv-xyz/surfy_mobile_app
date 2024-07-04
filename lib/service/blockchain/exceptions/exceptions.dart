import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class NoTokenException implements Exception {
  NoTokenException({required this.token});

  final Token token;

  @override
  String toString() {
    return "Invalid token (${token.name})";
  }
}

class NoBlockchainException implements Exception {
  NoBlockchainException({required this.blockchain});

  final Blockchain blockchain;

  @override
  String toString() {
    return "Invalid blockchain (${blockchain.name})";
  }
}

class NoTokenContractException implements Exception {
  NoTokenContractException({required this.token, required this.blockchain});

  final Token token;
  final Blockchain blockchain;

  @override
  String toString() {
    return "Invalid tokenContract (${blockchain.name}, ${token.name})";
  }
}

// Tron
class NotActivatedAccountException implements Exception {
  @override
  String toString() {
    return "Your account is not activated. You need to send 1TRX to your account.";
  }
}

class TransactionFailedException implements Exception {
  TransactionFailedException({required this.token, required this.blockchain, required this.message});

  final Token token;
  final Blockchain blockchain;
  final String? message;

  @override
  String toString() {
    return "Transaction fail: $message (${token.name}, ${blockchain.name})";
  }
}