import 'package:flutter/foundation.dart';
import 'package:surfy_mobile_app/domain/token/get_balance.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class GetWalletBalances {
  final getWalletAddress = GetWalletAddress();
  final getBalance = GetBalance();
  
  Future<UserTokenData> _getUserTokenData(({Blockchain blockchain, Token token, String privateKey}) arg) async {
    logger.d('_getUserTokenData, blockchain=${arg.blockchain}, token=${arg.token}, privateKey=${arg.privateKey}');
    final walletAddress = await getWalletAddress.getAddress(arg.blockchain, arg.privateKey);
    final balance = await getBalance.getBalance(arg.token, arg.blockchain, walletAddress);
    return balance;
  }

  Future<UserTokenData> getUserToken(({Blockchain blockchain, Token token, String privateKey}) arg) async {
    logger.d('_getUserTokenData, blockchain=${arg.blockchain}, token=${arg.token}, privateKey=${arg.privateKey}');
    final walletAddress = await getWalletAddress.getAddress(arg.blockchain, arg.privateKey);
    final balance = await getBalance.getBalance(arg.token, arg.blockchain, walletAddress);
    return balance;
  }

  Future<List<UserTokenData>> getAggregatedTokenData(Token token, String secp256k1, String ed25519) {
    logger.d('getAggregatedTokenData');
    final supportedBlockchain = tokens[token]?.supportedBlockchain ?? [];
    return Future.wait(supportedBlockchain.map((blockchain) async {
      var blockchainData = blockchains[blockchain];
      var address = await getWalletAddress.getAddress(blockchain, blockchainData?.curve == EllipticCurve.SECP256K1 ? secp256k1 : ed25519);
      var balance = await getBalance.getBalance(token, blockchain, address);
      return balance;
    }).toList());
  }


  Future<Map<Token, Map<Blockchain, UserTokenData>>> getWalletBalances(String secp256k1Key, String ed25519Key) async {
    logger.i("start!");
    final Map<Token, Map<Blockchain, UserTokenData>> result = {};

    for (final tokenEntry in tokens.entries) {
      final tokenKey = tokenEntry.key;
      final tokenData = tokenEntry.value;
      final Map<Blockchain, UserTokenData> tokenDataMap = {};
      for (final blockchain in tokenData.supportedBlockchain) {
        try {
          final blockchainData = blockchains[blockchain];
          if (blockchainData == null || blockchainData.rpc == "") {
            // TODO : for debugging
            continue;
          }
          compute(_getUserTokenData, (blockchain: blockchain, token: tokenKey, privateKey: blockchainData.curve == EllipticCurve.SECP256K1 ? secp256k1Key : ed25519Key));
        } catch (e) {
          continue;
        }
      }

      // result[tokenKey] = tokenDataMap;
    }
    return result;
  }
}