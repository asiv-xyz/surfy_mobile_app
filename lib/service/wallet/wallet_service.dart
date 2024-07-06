import 'package:surfy_mobile_app/abi/erc20.g.dart';
import 'package:surfy_mobile_app/cache/wallet/wallet_cache.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/service/wallet/address_handlers/address_handlers.dart';
import 'package:surfy_mobile_app/service/wallet/balance_handlers/balance_handlers.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class WalletService {
  WalletService({required this.walletCache}) {
    final ethereumAddressHandler = EthereumAddressHandler(walletCache: walletCache);
    final solanaAddressHandler = SolanaAddressHandler(walletCache: walletCache);
    final xrplAddressHandler = XrplAddressHandler(walletCache: walletCache);
    final tronAddressHandler = TronAddressHandler(walletCache: walletCache);
    final dogeAddressHandler = DogeAddressHandler(walletCache: walletCache);
    addressHandlers = {
      // TODO : fix each handler to singleton
      Blockchain.ethereum: ethereumAddressHandler,
      Blockchain.ethereum_sepolia: ethereumAddressHandler,

      Blockchain.base: ethereumAddressHandler,
      Blockchain.base_sepolia: ethereumAddressHandler,

      Blockchain.optimism: ethereumAddressHandler,
      Blockchain.optimism_sepolia: ethereumAddressHandler,

      Blockchain.arbitrum: ethereumAddressHandler,
      Blockchain.arbitrum_sepolia: ethereumAddressHandler,

      Blockchain.bsc: ethereumAddressHandler,

      Blockchain.opbnb: ethereumAddressHandler,

      Blockchain.solana: solanaAddressHandler,
      Blockchain.solana_devnet: solanaAddressHandler,

      Blockchain.xrpl: xrplAddressHandler,

      Blockchain.tron: tronAddressHandler,

      Blockchain.dogechain: dogeAddressHandler,
    };
  }

  final WalletCache walletCache;

  late final Map<Blockchain, AddressHandler> addressHandlers;

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
      Blockchain.solana: const SplBalanceHandler(token: Token.USDT),
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

    final address = await handler.getAddress(privateKey);
    print('blockchain=$blockchain, privatekey=$privateKey, address=$address');
    return address;
  }

  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    try {
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