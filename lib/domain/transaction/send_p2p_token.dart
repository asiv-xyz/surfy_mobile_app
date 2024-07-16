import 'package:get/get.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/service/blockchain/handlers/send_token_handler.dart';
import 'package:surfy_mobile_app/service/blockchain/blockchain_service.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class SendP2pToken {
  SendP2pToken({required this.blockchainService});

  final BlockchainService blockchainService;
  final EventBus bus = Get.find();

  Future<SendTokenResponse> send(Token token, Blockchain blockchain, String from, String to, BigInt amount, String? memo) async {
    return await blockchainService.sendToken(token, blockchain, to, amount, memo);
  }

  Future<BigInt> estimateGas(Token token, Blockchain blockchain, String to, BigInt amount) async {
    return await blockchainService.estimateGas(token, blockchain, to, amount);
  }

  Stream subscribeTransaction(Token token, Blockchain blockchain, String transactionHash) {
    return blockchainService.subscribeTransaction(token, blockchain, transactionHash);
  }
}