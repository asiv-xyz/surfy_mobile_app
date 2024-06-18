import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class GetWalletBalances {
  GetWalletBalances({required this.repository});
  final GetWalletAddress getWalletAddress = Get.find();
  final WalletBalancesRepository repository;
  final isLoading = false.obs;

  List<UserTokenData> getTokenDataList(Token token, String secp256k1, String ed25519) {
    logger.i('getAggregatedTokenData');
    isLoading.value = true;
    final result = repository.getSingleTokenBalance(token, secp256k1, ed25519);
    isLoading.value = false;
    return result;
  }

  Future<List<UserTokenData>> loadNewTokenDataList(List<Token> tokenList, String secp256k1, String ed25519) async {
    logger.i('loadNewTokenData');
    isLoading.value = true;
    final result = await repository.forceLoadAndGetUserWalletBalances(tokenList, secp256k1, ed25519);
    isLoading.value = false;
    return result;
  }

  Future<List<UserTokenData>> getMultipleTokenDataList(List<Token> tokenList, String secp256k1, String ed25519) async {
    logger.i('getMultipleTokenDataList');
    isLoading.value = true;
    final result = await repository.getUserWalletBalances(tokenList, secp256k1, ed25519);
    isLoading.value = false;
    return result;
  }
}