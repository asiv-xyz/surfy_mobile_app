import 'package:flutter/foundation.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/wallet/wallet_service.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletBalancesRepository {
  WalletBalancesRepository({required this.walletService});
  final WalletService walletService;

  bool needToUpdate = true;
  static const updateThreshold = 300000; // 5 minutes
  int _lastUpdateTimestamp = 0;
  List<UserTokenData> data = [];

  bool _needToUpdate() {
    int now = DateTime.now().millisecondsSinceEpoch;
    return needToUpdate || (now - _lastUpdateTimestamp > updateThreshold) || data.isEmpty;
  }

  Future<UserTokenData> _getSingleWalletBalance(({Token token, Blockchain blockchain, String key}) arg) async {
    final address = await walletService.getWalletAddress(arg.blockchain, arg.key);
    final balance = await walletService.getBalance(arg.token, arg.blockchain, address);
    return balance;
  }

  Future<List<UserTokenData>> _loadNewData(List<Token> tokenList, String secp256k1, String ed25519) async {
    _lastUpdateTimestamp = DateTime.now().millisecondsSinceEpoch;
    final jobList = tokenList.map((token) {
      final supportedBlockchain = tokens[token]?.supportedBlockchain ?? [];
      return supportedBlockchain.map((blockchain) async {
        final blockchainData = blockchains[blockchain];
        return await compute(_getSingleWalletBalance, (token: token, blockchain: blockchain, key: blockchainData?.curve == EllipticCurve.SECP256K1 ? secp256k1 : ed25519));
      }).toList();
    }).expand((element) => element).toList();

    return (await Future.wait(jobList)).toList();
  }

  Future<List<UserTokenData>> getUserWalletBalances(List<Token> tokenList, String secp256k1, String ed25519) async {
    if (_needToUpdate()) {
      logger.i('load new wallet balances: $tokenList');
      needToUpdate = false;
      data = await _loadNewData(tokenList, secp256k1, ed25519);
    }

    return data;
  }

  Future<List<UserTokenData>> forceLoadAndGetUserWalletBalances(List<Token> tokenList, String secp256k1, String ed25519) async {
    logger.i('force loading user wallet balances!!');
    needToUpdate = true;
    return await getUserWalletBalances(tokenList, secp256k1, ed25519);
  }

  List<UserTokenData> getSingleTokenBalance(Token token, String secp256k1, String ed25519) {
    if (_needToUpdate()) {
      logger.e('Need to update!');
      throw Exception('Need to update!');
    }

    return data.where((d) => d.token == token).toList();
  }
}