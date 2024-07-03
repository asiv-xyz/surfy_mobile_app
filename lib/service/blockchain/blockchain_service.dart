import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/service/blockchain/handlers/send_token_handler.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class BlockchainService {
  BlockchainService({required this.keyService}) {
    sendHandlers = {
      Token.ETHEREUM: {
        Blockchain.ETHEREUM: SendEthereumHandler(keyService: keyService),
        Blockchain.ETHEREUM_SEPOLIA: SendEthereumHandler(keyService: keyService),

        Blockchain.BASE: SendEthereumHandler(keyService: keyService),
        Blockchain.BASE_SEPOLIA: SendEthereumHandler(keyService: keyService),
      },
      Token.USDC: {
        Blockchain.ETHEREUM: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        ),
        Blockchain.ETHEREUM_SEPOLIA: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        ),
        Blockchain.BASE: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        ),
        Blockchain.BASE_SEPOLIA: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        ),
        Blockchain.SOLANA: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        ),
        Blockchain.SOLANA_DEVNET: SendUsdcHandler(
          erc20Handler: SendErc20Handler(keyService: keyService, token: Token.USDC),
          splHandler: SendSplHandler(token: Token.USDC, keyService: keyService),
        )
      },
      Token.DEGEN: {
        Blockchain.BASE: SendErc20Handler(keyService: keyService, token: Token.DEGEN)
      },
      Token.USDT: {
        Blockchain.ETHEREUM: SendErc20Handler(keyService: keyService, token: Token.USDT),
        Blockchain.TRON: SendTrcHandler(keyService: keyService, token: Token.USDT)
      },
      Token.SOLANA: {
        Blockchain.SOLANA: SendSolanaHandler(keyService: keyService),
        Blockchain.SOLANA_DEVNET: SendSolanaHandler(keyService: keyService)
      },

      Token.TRON: {
        Blockchain.TRON: SendTronHandler(keyService: keyService),
      },

      Token.BNB: {
        Blockchain.BSC: SendEthereumHandler(keyService: keyService),
        Blockchain.OP_BNB: SendEthereumHandler(keyService: keyService)
      },

      Token.XRP: {
        Blockchain.XRPL: SendXrpHandler(keyService: keyService),
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
      print('error: $e');
      return BigInt.zero;
    }
  }
}