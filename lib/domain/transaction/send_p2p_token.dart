import 'package:get/get.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/service/blockchain/handlers/send_token_handler.dart';
import 'package:surfy_mobile_app/service/blockchain/blockchain_service.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class SendP2pToken {
  SendP2pToken({required this.transactionService});

  final BlockchainService transactionService;
  final EventBus bus = Get.find();

  Future<SendTokenResponse> send(Token token, Blockchain blockchain, String from, String to, BigInt amount) async {
    final result = await transactionService.sendToken(token, blockchain, to, amount);
    bus.emit(ForceUpdateTokenBalanceEvent(
      token: token,
      blockchain: blockchain,
      address: from,
      amount: amount,
    ));
    bus.emit(ReloadHistoryEvent());
    return result;
  }

  Future<BigInt> estimateGas(Token token, Blockchain blockchain, String to, BigInt amount) async {
    return await transactionService.estimateGas(token, blockchain, to, amount);
  }
}