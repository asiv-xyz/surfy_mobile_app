import 'dart:isolate';

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

    Blockchain.OP_BNB: EthereumAddressHandler(),

    Blockchain.SOLANA: SolanaAddressHandler(),
    Blockchain.SOLANA_DEVNET: SolanaAddressHandler(),

    Blockchain.XRPL: XrplAddressHandler(),

    Blockchain.TRON: TronAddressHandler(),
  };

  final Map<Token, Map<Blockchain, BalanceHandler>> balanceHandlers = {
    Token.ETHEREUM: {
      Blockchain.ETHEREUM: EthereumBalanceHandler(),
      Blockchain.ETHEREUM_SEPOLIA: EthereumBalanceHandler(),
      Blockchain.BASE: EthereumBalanceHandler(),
      Blockchain.BASE_SEPOLIA: EthereumBalanceHandler(),
    },

    Token.USDC: {
      Blockchain.ETHEREUM: UsdcBalanceHandler(),
      Blockchain.ETHEREUM_SEPOLIA: UsdcBalanceHandler(),
      Blockchain.BASE: UsdcBalanceHandler(),
      Blockchain.BASE_SEPOLIA: UsdcBalanceHandler(),

      Blockchain.SOLANA: UsdcBalanceHandler()
    },

    Token.USDT: {
      Blockchain.ETHEREUM: const Erc20BalanceHandler(token: Token.USDT),
      Blockchain.TRON: TrcBalanceHandler(),
    },

    Token.DEGEN: {
      Blockchain.BASE: const Erc20BalanceHandler(token: Token.DEGEN)
    },
    // Token.DOGE: const Erc20BalanceHandler(token: Token.DOGE),

    Token.BNB: {
      Blockchain.BSC: EthereumBalanceHandler(),
      Blockchain.OP_BNB: EthereumBalanceHandler(),
    },

    Token.SOLANA: {
      Blockchain.SOLANA: SolanaBalanceHandler(),
      Blockchain.SOLANA_DEVNET: SolanaBalanceHandler(),
    },

    Token.XRP: {
      Blockchain.XRPL: XrpBalanceHandler()
    },

    Token.TRON: {
      Blockchain.TRON: TronBalanceHandler(),
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
      print('getBalance: $token, $blockchain, $startTime');
      final balanceHandler = balanceHandlers[token]?[blockchain];
      if (balanceHandler == null) {
        throw Exception('No balance handler for token: $token, chain: $blockchain');
      }

      final result = await balanceHandler.getBalance(token, blockchain, address);
      print('getBalance end: $token, $blockchain, ${DateTime.now().millisecondsSinceEpoch - startTime}');
      return result;
    } catch (e) {
      print('catch: $e');
      return UserTokenData(token: token, blockchain: blockchain, address: address, amount: BigInt.zero, decimal: tokens[token]?.decimal ?? 0);
    }
  }
}