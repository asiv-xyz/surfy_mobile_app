import 'package:dartx/dartx.dart';
import 'package:go_router/go_router.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/service/blockchain/exceptions/exceptions.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';

class DeepLink {
  static String createDeepLink(Blockchain blockchain, Token token, String receiver, { BigInt? amount }) {
    final chainData = blockchains[blockchain];
    final tokenData = tokens[token];

    if (chainData == null) {
      throw NoBlockchainException(blockchain: blockchain);
    }
    if (tokenData == null) {
      throw NoTokenException(token: token);
    }

    var deeplink = "";
    var scheme = "";
    var chainId = 1;

    scheme = "surfy";
    if (amount != null) {
      deeplink = "$scheme:com.riverbank.surfy/wallet/token/${token.name.toLowerCase()}/blockchain/${blockchain.name.toLowerCase()}/send/amount/${amount.toString()}/address/$receiver";
    } else {
      deeplink = "$scheme:com.riverbank.surfy/wallet/token/${token.name.toLowerCase()}/blockchain/${blockchain.name.toLowerCase()}/send";
    }

    // switch (blockchain) {
    //   case Blockchain.ethereum_sepolia:
    //   case Blockchain.ethereum:
    //   case Blockchain.arbitrum_sepolia:
    //   case Blockchain.arbitrum:
    //   case Blockchain.optimism_sepolia:
    //   case Blockchain.optimism:
    //   case Blockchain.base_sepolia:
    //   case Blockchain.base:
    //   case Blockchain.bsc:
    //   case Blockchain.opbnb:
    //     scheme = "ethereum";
    //     chainId = chainData.chainId!;
    //     if (tokenData.isToken) {
    //       if (amount != null) {
    //         deeplink = "$scheme:${tokenData.tokenContractAddress[blockchain]}@$chainId/transfer?address=$receiver&uint256=${amount.toString()}";
    //       } else {
    //         deeplink = "$scheme:${tokenData.tokenContractAddress[blockchain]}@$chainId/transfer?amount=$receiver";
    //       }
    //     } else {
    //       // ether
    //       if (amount != null) {
    //         final e = amount.toDouble().toStringAsExponential().replaceAll("+", "");
    //         deeplink = "$scheme:$receiver@$chainId?value=$e";
    //       } else {
    //         deeplink = "$scheme:$receiver@$chainId";
    //       }
    //     }
    //     break;
    //
    //   case Blockchain.solana_devnet:
    //   case Blockchain.solana:
    //     scheme = "solana";
    //     if (tokenData.isToken) {
    //       if (amount != null) {
    //         final amountDecimal = cryptoAmountToDecimal(tokenData, amount);
    //         deeplink = "$scheme:$receiver?amount=$amountDecimal&spl-token=${tokenData.tokenContractAddress[blockchain]}";
    //       } else {
    //         deeplink = "$scheme:$receiver";
    //       }
    //     } else {
    //       // sol
    //       if (amount != null) {
    //         final amountDecimal = cryptoAmountToDecimal(tokenData, amount);
    //         deeplink = "$scheme:$receiver?amount=$amountDecimal";
    //       } else {
    //         deeplink = "$scheme:$receiver";
    //       }
    //     }
    //     break;
    //
    //   default:
    //     scheme = "surfy";
    //     if (amount != null) {
    //       deeplink = "$scheme:com.riverbank.surfy/wallet/token/${token.name.toLowerCase()}/blockchain/${blockchain.name.toLowerCase()}/send/amount/${amount.toString()}/address/$receiver";
    //     } else {
    //       deeplink = "$scheme:com.riverbank.surfy/wallet/token/${token.name.toLowerCase()}/blockchain/${blockchain.name.toLowerCase()}/send";
    //     }
    //     break;
    // }

    return deeplink;
  }

  static void routingByDeeplink(Uri uri, GoRouter goRouter) {
    switch (uri.scheme) {
      case "https":
      case "surfy":
        print('deeplink : ${uri.pathSegments}');
        checkAuthAndGoWithGoRouter(goRouter, "/${uri.pathSegments.join('/')}");
        break;
      case "ethereum":
      // ethereum:0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359?value=2.014e18
      // ethereum:0x89205a3a3b2a69de6dbf7f01ed13b2108b2c43e7/transfer?address=0x8e23ee67d1332ad560396262c48ffbb01f93d052&uint256=1
        if (uri.pathSegments[0].startsWith('pay-')) {
          // Payment
          if (uri.pathSegments.length == 1) {
            // send ETH
            final amount = BigInt.from(num.parse(uri.queryParameters['value'] ?? "0"));
            var to = uri.pathSegments[0].split("pay-")[1];
            var chainId = 1;
            if (uri.pathSegments[0].contains("@")) {
              final seg = uri.pathSegments[0].split("@");
              to = seg[0].split("pay-")[1];
              chainId = seg[1].toInt();
            }
            final chainData = findBlockchainByChainId(chainId);
            if (amount == BigInt.zero) {
              checkAuthAndGoWithGoRouter(goRouter,
                "/wallet/token/ethereum/blockchain/${chainData.name.toLowerCase()}/send",
                extra: to
              );
            } else {
              checkAuthAndGoWithGoRouter(goRouter,
                "/wallet/token/ethereum/blockchain/${chainData.name.toLowerCase()}/send/amount/${amount.toString()}/address/$to",
              );
            }
          } else if (uri.pathSegments.length == 2 && uri.pathSegments[1] == 'transfer') {
            // send ERC20
            var contractAddress = uri.pathSegments[0];
            var chainId = 1;
            if (uri.pathSegments[0].contains("@")) {
              final seg = uri.pathSegments[0].split("@");
              contractAddress = seg[0].split("pay-")[1];
              chainId = seg[1].toInt();
            }
            final chainData = findBlockchainByChainId(chainId);
            final receiver = uri.queryParameters['address'];
            final amount = BigInt.parse(uri.queryParameters['uint256'] ?? "0");
            if (amount == BigInt.zero) {
              checkAuthAndGoWithGoRouter(goRouter,
                "/wallet/token/${findTokenByContractAddress(contractAddress).name.toLowerCase()}/blockchain/${chainData.name.toLowerCase()}/send",
                extra: receiver
              );
            } else {
              checkAuthAndGoWithGoRouter(goRouter,
                "/wallet/token/${findTokenByContractAddress(contractAddress).name.toLowerCase()}/blockchain/${chainData.name.toLowerCase()}/send/amount/${amount.toString()}/address/$receiver",
              );
            }
          }
        } else {
          // Transfer
          if (uri.pathSegments.length == 1) {
            // send ETH
            final amount = BigInt.from(num.parse(uri.queryParameters['value'] ?? "0"));
            var to = uri.pathSegments[0];
            var chainId = 1;
            if (uri.pathSegments[0].contains("@")) {
              final seg = uri.pathSegments[0].split("@");
              to = seg[0];
              chainId = seg[1].toInt();
            }
            final chainData = findBlockchainByChainId(chainId);
            if (amount == BigInt.zero) {
              checkAuthAndGoWithGoRouter(goRouter,
                "/wallet/token/ethereum/blockchain/${chainData.name.toLowerCase()}/send",
                extra: to
              );
            } else {
              checkAuthAndGoWithGoRouter(goRouter,
                "/wallet/token/ethereum/blockchain/${chainData.name.toLowerCase()}/send/amount/${amount.toString()}/address/$to",
              );
            }
          } else if (uri.pathSegments.length == 2 && uri.pathSegments[1] == 'transfer') {
            // send ERC20
            var contractAddress = uri.pathSegments[0];
            var chainId = 1;
            if (uri.pathSegments[0].contains("@")) {
              final seg = uri.pathSegments[0].split("@");
              contractAddress = seg[0];
              chainId = seg[1].toInt();
            }
            final chainData = findBlockchainByChainId(chainId);
            final receiver = uri.queryParameters['address'];
            final amount = BigInt.parse(uri.queryParameters['uint256'] ?? "0");
            if (amount == BigInt.zero) {
              checkAuthAndGoWithGoRouter(goRouter,
                "/wallet/token/${findTokenByContractAddress(contractAddress).name.toLowerCase()}/blockchain/${chainData.name.toLowerCase()}/send",
                extra: receiver
              );
            } else {
              checkAuthAndGoWithGoRouter(goRouter,
                "/wallet/token/${findTokenByContractAddress(contractAddress).name.toLowerCase()}/blockchain/${chainData.name.toLowerCase()}/send/amount/${amount.toString()}/address/$receiver",
              );
            }
          }
        }

        break;
      case "solana":
      // solana:0x123456789?amount=0.0012
      // solana:0x123456789?amount=1.0&spl-token=EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v
        final receiver = uri.pathSegments[0];
        if (uri.queryParameters.isEmpty) {
          checkAuthAndGoWithGoRouter(goRouter, "/wallet/token/solana/blockchain/solana/send");
        } else if (uri.queryParameters['amount'] != null && uri.queryParameters['spl-token'] == null) {
          final amount = uri.queryParameters['amount'];
          final cryptoAmount = cryptoDecimalToBigInt(tokens[Token.SOLANA]!, amount!.toDouble());
          checkAuthAndGoWithGoRouter(goRouter, "/wallet/token/solana/blockchain/solana/send/amount/${cryptoAmount.toString()}/address/$receiver");
        } else {
          final amount = uri.queryParameters['amount'];
          final cryptoAmount = cryptoDecimalToBigInt(tokens[Token.SOLANA]!, amount!.toDouble());
          final tokenContractAddress = uri.queryParameters['spl-token'];
          final token = findTokenByContractAddress(tokenContractAddress!);
          print("routing: /wallet/token/${token.name.toLowerCase()}/blockchain/solana/send/amount/${cryptoAmount.toString()}/address/$receiver");
          checkAuthAndGoWithGoRouter(goRouter, "/wallet/token/${token.name.toLowerCase()}/blockchain/solana/send/amount/${cryptoAmount.toString()}/address/$receiver");
        }
        break;
    }
  }
}