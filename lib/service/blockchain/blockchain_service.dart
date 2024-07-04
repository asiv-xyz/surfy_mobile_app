import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/service/blockchain/handlers/send_token_handler.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class BlockchainService {
  BlockchainService({required this.keyService}) {
    sendHandlers = {
      Token.ETHEREUM: {
        Blockchain.ethereum: SendEthereumHandler(keyService: keyService),
        Blockchain.ethereum_sepolia: SendEthereumHandler(keyService: keyService),

        Blockchain.base: SendEthereumHandler(keyService: keyService),
        Blockchain.base_sepolia: SendEthereumHandler(keyService: keyService),
      },
      Token.USDC: {
        Blockchain.ethereum: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        ),
        Blockchain.ethereum_sepolia: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        ),
        Blockchain.base: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        ),
        Blockchain.base_sepolia: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        ),
        Blockchain.solana: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        ),
        Blockchain.solana_devnet: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        )
      },
      Token.DEGEN: {
        Blockchain.base: SendErc20Handler(keyService: keyService, token: Token.DEGEN)
      },
      Token.USDT: {
        Blockchain.ethereum: SendErc20Handler(keyService: keyService, token: Token.USDT),
        Blockchain.tron: SendTrcHandler(keyService: keyService, token: Token.USDT)
      },
      Token.SOLANA: {
        Blockchain.solana: SendSolanaHandler(keyService: keyService),
        Blockchain.solana_devnet: SendSolanaHandler(keyService: keyService)
      },

      Token.TRON: {
        Blockchain.tron: SendTronHandler(keyService: keyService),
      },

      Token.BNB: {
        Blockchain.bsc: SendEthereumHandler(keyService: keyService),
        Blockchain.opbnb: SendEthereumHandler(keyService: keyService)
      },

      Token.XRP: {
        Blockchain.xrpl: SendXrpHandler(keyService: keyService),
      },

      Token.DOGE: {
        Blockchain.dogechain: SendDogeHandler(keyService: keyService)
      },

      Token.FRAX: {
        Blockchain.ethereum: SendErc20Handler(keyService: keyService, token: Token.FRAX)
      }
    };
  }

  final KeyService keyService;
  late final Map<Token, Map<Blockchain, SendTokenHandler>> sendHandlers;

  Future<SendTokenResponse> sendToken(Token token, Blockchain blockchain, String to, BigInt amount) async {
    try {
      final handler = sendHandlers[token]?[blockchain];
      if (handler == null) {
        throw Exception('No valid handler for blockchain=$blockchain, token=$token');
      }

      return await handler.send(blockchain, to, amount);
    } catch (e) {
      logger.e("send error: $e");
      rethrow;
    }
  }

  Future<BigInt> estimateGas(Token token, Blockchain blockchain, String to, BigInt amount) async {
    try {
      final SendTokenHandler? handler = sendHandlers[token]?[blockchain];
      if (handler == null) {
        throw Exception('No valid handler for blockchain=$blockchain, token=$token');
      }
      return await handler.estimateFee(blockchain, to, amount);
    } catch (e) {
      logger.e("estimateGas error: $e");
      rethrow;
    }
  }
}
