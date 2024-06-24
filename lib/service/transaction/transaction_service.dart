import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/service/transaction/handlers/send_token_handler.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class TransactionService {
  TransactionService({required this.keyService}) {
    sendHandlers = {
      Token.ETHEREUM: SendEthereumHandler(keyService: keyService),
      Token.USDC: SendUsdcHandler(
        erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
        splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
      ),
      Token.DEGEN: SendErc20Handler(keyService: keyService, token: Token.DEGEN),
      Token.USDT: SendErc20Handler(keyService: keyService, token: Token.USDT),
      Token.SOLANA: SendSolanaHandler(keyService: keyService),
    };
  }

  final KeyService keyService;
  late final Map<Token, SendTokenHandler> sendHandlers;

  Future<SendTokenResponse> sendToken(Token token, Blockchain blockchain, String to, double amount) async {
    final handler = sendHandlers[token];
    if (handler == null) {
      throw Exception('No valid handler for blockchain=$blockchain, token=$token');
    }

    return await handler.send(blockchain, to, amount);
  }

  Future<BigInt> estimateGas(Token token, Blockchain blockchain, String to, double amount) async {
    final handler = sendHandlers[token];
    if (handler == null) {
      throw Exception('No valid handler for blockchain=$blockchain, token=$token');
    }

    return await handler.estimateFee(blockchain, to, amount);
  }
}