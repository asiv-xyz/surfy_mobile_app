import 'package:surfy_mobile_app/domain/token/handlers/balance_handlers.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

import 'model/user_token_data.dart';

class GetBalance {
  final Map<Token, BalanceHandler> balanceHandlers = {
    Token.ETHEREUM: EthereumBalanceHandler(),
    Token.USDC: UsdcBalanceHandler(),
    Token.USDT: const Erc20BalanceHandler(token: Token.USDT),
    Token.DEGEN: const Erc20BalanceHandler(token: Token.DEGEN),
    // Token.DOGE: const Erc20BalanceHandler(token: Token.DOGE),
    Token.SOLANA: SolanaBalanceHandler(),
  };

  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    logger.d('getBalance, token=$token, blockchain=$blockchain, address=$address');
    final balanceHandler = balanceHandlers[token];
    try {
      if (balanceHandler == null) {
        throw Exception('No handler for token: $token');
      }

      return await balanceHandler.getBalance(token, blockchain, address);
    } catch (e) {
      logger.e('error: ${e.toString()}, token=$token, blockchain=$blockchain, address=$address}');
      return UserTokenData(blockchain: blockchain, token: token, amount: BigInt.zero, decimal: tokens[token]?.decimal ?? 1);
    }
  }
}