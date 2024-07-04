import 'package:surfy_mobile_app/abi/erc20.g.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/service/wallet/address_handlers/address_handlers.dart';
import 'package:surfy_mobile_app/service/wallet/balance_handlers/balance_handlers.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class WalletService {
  final Map<Blockchain, AddressHandler> addressHandlers = {
    // TODO : fix each handler to singleton
    Blockchain.ethereum: EthereumAddressHandler(),
    Blockchain.ethereum_sepolia: EthereumAddressHandler(),

    Blockchain.base: EthereumAddressHandler(),
    Blockchain.base_sepolia: EthereumAddressHandler(),

    Blockchain.optimism: EthereumAddressHandler(),
    Blockchain.optimism_sepolia: EthereumAddressHandler(),

    Blockchain.arbitrum: EthereumAddressHandler(),
    Blockchain.arbitrum_sepolia: EthereumAddressHandler(),

    Blockchain.bsc: EthereumAddressHandler(),

    Blockchain.opbnb: EthereumAddressHandler(),

    Blockchain.solana: SolanaAddressHandler(),
    Blockchain.solana_devnet: SolanaAddressHandler(),

    Blockchain.xrpl: XrplAddressHandler(),

    Blockchain.tron: TronAddressHandler(),

    Blockchain.dogechain: DogeAddressHandler(),
  };

  final Map<Token, Map<Blockchain, BalanceHandler>> balanceHandlers = {
    Token.ETHEREUM: {
      Blockchain.ethereum: EthereumBalanceHandler(),
      Blockchain.ethereum_sepolia: EthereumBalanceHandler(),
      Blockchain.base: EthereumBalanceHandler(),
      Blockchain.base_sepolia: EthereumBalanceHandler(),
    },

    Token.USDC: {
      Blockchain.ethereum: UsdcBalanceHandler(),
      Blockchain.ethereum_sepolia: UsdcBalanceHandler(),
      Blockchain.base: UsdcBalanceHandler(),
      Blockchain.base_sepolia: UsdcBalanceHandler(),

      Blockchain.solana: UsdcBalanceHandler()
    },

    Token.USDT: {
      Blockchain.ethereum: const Erc20BalanceHandler(token: Token.USDT),
      Blockchain.tron: TrcBalanceHandler(),
    },

    Token.DEGEN: {
      Blockchain.base: const Erc20BalanceHandler(token: Token.DEGEN)
    },

    Token.DOGE: {
      // Blockchain.bsc: const Erc20BalanceHandler(token: Token.DOGE),
      Blockchain.dogechain: DogeBalanceHandler(),
    },
    // Token.DOGE: const Erc20BalanceHandler(token: Token.DOGE),

    Token.BNB: {
      Blockchain.bsc: EthereumBalanceHandler(),
      Blockchain.opbnb: Erc20BalanceHandler(token: Token.BNB),
    },

    Token.SOLANA: {
      Blockchain.solana: SolanaBalanceHandler(),
      Blockchain.solana_devnet: SolanaBalanceHandler(),
    },

    Token.XRP: {
      Blockchain.xrpl: XrpBalanceHandler()
    },

    Token.TRON: {
      Blockchain.tron: TronBalanceHandler(),
    },

    Token.FRAX: {
      Blockchain.ethereum: Erc20BalanceHandler(token: Token.FRAX),
    }
  };

  Future<String> getWalletAddress(Blockchain blockchain, String privateKey) async {
    final handler = addressHandlers[blockchain];
    if (handler == null) {
      throw Exception('No address handler for chain: $blockchain');
    }

    return await handler.getAddress(privateKey);
  }

  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    try {
      var startTime = DateTime.now().millisecondsSinceEpoch;
      final balanceHandler = balanceHandlers[token]?[blockchain];
      if (balanceHandler == null) {
        throw Exception('No balance handler for token: $token, chain: $blockchain');
      }

      final result = await balanceHandler.getBalance(token, blockchain, address);
      return result;
    } catch (e) {
      return UserTokenData(token: token, blockchain: blockchain, address: address, amount: BigInt.zero, decimal: tokens[token]?.decimal ?? 0);
    }
  }
}