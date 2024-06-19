import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

import '../../settings/settings_preference.dart';

class GetWalletBalances {
  GetWalletBalances({required this.repository, required this.getWalletAddressUseCase, required this.getTokenPriceUseCase});
  final GetWalletAddress getWalletAddressUseCase;
  final GetTokenPrice getTokenPriceUseCase;
  final WalletBalancesRepository repository;
  final isLoading = false.obs;

  Future<List<UserTokenData>> getTokenDataList(Token token, String secp256k1, String ed25519) async {
    try {
      logger.d('getAggregatedTokenData');
      isLoading.value = true;
      final result = repository.getSingleTokenBalance(token, secp256k1, ed25519);
      isLoading.value = false;
      return result;
    } catch (e) {
      if (e.toString().contains('Need to update!')) {
        isLoading.value = true;
        await repository.forceLoadAndGetUserWalletBalances(Token.values, secp256k1, ed25519);
        final result = repository.getSingleTokenBalance(token, secp256k1, ed25519);
        isLoading.value = false;
        return result;
      }

      rethrow;
    }
  }

  Future<List<UserTokenData>> loadNewTokenDataList(List<Token> tokenList, String secp256k1, String ed25519) async {
    logger.d('loadNewTokenData');
    isLoading.value = true;
    final result = await repository.forceLoadAndGetUserWalletBalances(tokenList, secp256k1, ed25519);
    isLoading.value = false;
    return result;
  }

  Future<List<UserTokenData>> getMultipleTokenDataList(List<Token> tokenList, String secp256k1, String ed25519) async {
    logger.d('getMultipleTokenDataList');
    isLoading.value = true;
    final result = await repository.getUserWalletBalances(tokenList, secp256k1, ed25519);
    isLoading.value = false;
    return result;
  }

  Future<Pair<String, String>> getUiTokenBalance(Token token, CurrencyType currency) async {
    logger.d('getUiTokenBalance, token=$token, currencyType=$currency');
    final tokenPriceData = await getTokenPriceUseCase.getSingleTokenPrice(token, currency);
    final userBalanceData = await getTokenDataList(token, await Web3AuthFlutter.getPrivKey(), await Web3AuthFlutter.getEd25519PrivKey());
    final aggregatedUserBalance = userBalanceData.reduce((prev, curr) {
      return UserTokenData(
        token: prev.token,
        blockchain: prev.blockchain,
        decimal: prev.decimal,
        address: "",
        amount: prev.amount + curr.amount,
      );
    });
    final formatter = NumberFormat.decimalPattern('en_US');
    final fiat = aggregatedUserBalance.toVisibleAmount() * (tokenPriceData?.price ?? 0);
    final formattedFiat = formatter.format(fiat.toStringAsFixed(getFixedDigitBySymbol(currency)).toDouble());
    return Pair("${aggregatedUserBalance.toVisibleAmount().toStringAsFixed(tokens[token]?.fixedDecimal ?? 2)} ${tokens[token]?.symbol}", "${getCurrencySymbol(currency)} $formattedFiat");
  }

  Future<Pair<String, String>> getUiTokenBalanceWithNetwork(Token token, Blockchain blockchain, CurrencyType currency) async {
    final tokenPriceData = await getTokenPriceUseCase.getSingleTokenPrice(token, currency);
    final userBalanceData = await getTokenDataList(token, await Web3AuthFlutter.getPrivKey(), await Web3AuthFlutter.getEd25519PrivKey());
    final aggregatedUserBalance = userBalanceData.where((item) => item.blockchain == blockchain).reduce((prev, curr) {
      return UserTokenData(
        token: prev.token,
        blockchain: prev.blockchain,
        decimal: prev.decimal,
        address: "",
        amount: prev.amount + curr.amount,
      );
    });
    final formatter = NumberFormat.decimalPattern('en_US');
    final fiat = aggregatedUserBalance.toVisibleAmount() * (tokenPriceData?.price ?? 0);
    final formattedFiat = formatter.format(fiat.toStringAsFixed(getFixedDigitBySymbol(currency)).toDouble());
    return Pair("${aggregatedUserBalance.toVisibleAmount().toStringAsFixed(tokens[token]?.fixedDecimal ?? 2)} ${tokens[token]?.symbol}", "${getCurrencySymbol(currency)} $formattedFiat");
  }
}