import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/service/wallet/address_handlers/address_handlers.dart';
import 'package:surfy_mobile_app/service/wallet/balance_handlers/balance_handlers.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletService {
  final Map<Blockchain, AddressHandler> addressHandlers = {
    // TODO : fix each handler to singleton
    Blockchain.ETHEREUM: EthereumAddressHandler(),
    Blockchain.ETHEREUM_SEPOLIA: EthereumAddressHandler(),
    Blockchain.BASE: EthereumAddressHandler(),
    Blockchain.BASE_SEPOLIA: EthereumAddressHandler(),
    Blockchain.OPTIMISM: EthereumAddressHandler(),
    Blockchain.OPTIMISM_SEPOLIA: EthereumAddressHandler(),
    Blockchain.ARBITRUM: EthereumAddressHandler(),
    Blockchain.ARBITRUM_SEPOLIA: EthereumAddressHandler(),
    Blockchain.BSC: EthereumAddressHandler(),
    Blockchain.SOLANA: SolanaAddressHandler(),
    Blockchain.SOLANA_DEVNET: SolanaAddressHandler(),
  };

  final Map<Token, BalanceHandler> balanceHandlers = {
    Token.ETHEREUM: EthereumBalanceHandler(),
    Token.USDC: UsdcBalanceHandler(),
    Token.USDT: const Erc20BalanceHandler(token: Token.USDT),
    Token.DEGEN: const Erc20BalanceHandler(token: Token.DEGEN),
    // Token.DOGE: const Erc20BalanceHandler(token: Token.DOGE),
    Token.SOLANA: SolanaBalanceHandler(),
  };

  Future<String> getWalletAddress(Blockchain blockchain, String privateKey) async {
    final handler = addressHandlers[blockchain];
    if (handler == null) {
      throw Exception('Invalid blockchain: $blockchain');
    }

    return await handler.getAddress(privateKey);
  }

  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    final balanceHandler = balanceHandlers[token];
    try {
      if (balanceHandler == null) {
        throw Exception('No handler for token: $token');
      }

      return await balanceHandler.getBalance(token, blockchain, address);
    } catch (e) {
      return UserTokenData(blockchain: blockchain, token: token, amount: BigInt.zero, decimal: tokens[token]?.decimal ?? 1, address: address);
    }
  }
}