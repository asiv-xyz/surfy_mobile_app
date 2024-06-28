import 'package:surfy_mobile_app/service/transaction/handlers/send_token_handler.dart';
import 'package:surfy_mobile_app/service/transaction/transaction_service.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class SendP2pToken {
  SendP2pToken({required this.transactionService});

  final TransactionService transactionService;

  Future<SendTokenResponse> send(Token token, Blockchain blockchain, String to, BigInt amount) async {
    return await transactionService.sendToken(token, blockchain, to, amount);
  }

  Future<BigInt> estimateGas(Token token, Blockchain blockchain, String to, BigInt amount) async {
    return await transactionService.estimateGas(token, blockchain, to, amount);
  }
}