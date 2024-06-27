import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

import '../../settings/settings_preference.dart';

class GetWalletBalances {
  GetWalletBalances({required this.repository, required this.getWalletAddressUseCase, required this.getTokenPriceUseCase, required this.keySerivce});
  final GetWalletAddress getWalletAddressUseCase;
  final GetTokenPrice getTokenPriceUseCase;
  final WalletBalancesRepository repository;
  final KeyService keySerivce;
  final isLoading = false.obs;
  final Rx<List<UserTokenData>> userDataObs = Rx([]);

  final RxBool needUpdate = false.obs;

  Future<List<UserTokenData>> getTokenDataList(Token token) async {
    final key = await keySerivce.getKey();
    try {
      logger.d('getAggregatedTokenData');
      isLoading.value = true;
      final result = repository.getSingleTokenBalance(token, key.first, key.second);
      isLoading.value = false;
      return result;
    } catch (e) {
      if (e.toString().contains('Need to update!')) {
        isLoading.value = true;
        await repository.forceLoadAndGetUserWalletBalances(Token.values, key.first, key.second);
        final result = repository.getSingleTokenBalance(token, key.first, key.second);
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
    userDataObs.value = result;
    isLoading.value = false;
    return result;
  }

  Future<List<UserTokenData>> getMultipleTokenDataList(List<Token> tokenList) async {
    logger.d('getMultipleTokenDataList');
    isLoading.value = true;
    final key = await keySerivce.getKey();
    final result = await repository.getUserWalletBalances(tokenList, key.first, key.second);
    isLoading.value = false;
    return result;
  }

  Pair<Token, double> aggregateTokenBalance(
      Token token,
      List<UserTokenData> useTokenDataList,
      double tokenPrice,
      CurrencyType currency) {
    final aggregatedUserBalance = useTokenDataList.where((t) => t.token == token).reduce((prev, curr) {
      return UserTokenData(
        token: prev.token,
        blockchain: prev.blockchain,
        decimal: prev.decimal,
        address: "",
        amount: prev.amount + curr.amount,
      );
    });

    final totalPrice = aggregatedUserBalance.toVisibleAmount() * tokenPrice;
    return Pair(token, totalPrice);
  }

  double aggregateUserTokenAmount(Token token, List<UserTokenData> userTokenDataList) {
    final aggregatedUserBalance = userTokenDataList.where((t) => t.token == token).reduce((prev, curr) {
      return UserTokenData(
        token: prev.token,
        blockchain: prev.blockchain,
        decimal: prev.decimal,
        address: "",
        amount: prev.amount + curr.amount,
      );
    });

    return aggregatedUserBalance.toVisibleAmount();
  }

  double aggregateUserTokenAmountByBlockchain(Token token, Blockchain blockchain, List<UserTokenData> userTokenDataList) {
    final aggregatedUserBalance = userTokenDataList.where((t) => t.token == token && t.blockchain == blockchain).reduce((prev, curr) {
    return UserTokenData(
      token: prev.token,
      blockchain: prev.blockchain,
        decimal: prev.decimal,
        address: "",
        amount: prev.amount + curr.amount,
      );
    });

    return aggregatedUserBalance.toVisibleAmount();
  }

  Pair<String, String> parseTotalTokenBalanceForUi(
      Token token,
      List<UserTokenData> useTokenDataList,
      double tokenPrice,
      CurrencyType currency) {
    final aggregatedUserBalance = useTokenDataList.reduce((prev, curr) {
      return UserTokenData(
        token: prev.token,
        blockchain: prev.blockchain,
        decimal: prev.decimal,
        address: "",
        amount: prev.amount + curr.amount,
      );
    });
    final formatter = NumberFormat.decimalPattern('en_US');
    final fiat = aggregatedUserBalance.toVisibleAmount() * tokenPrice;
    final formattedFiat = formatter.format(fiat.toStringAsFixed(getFixedDigitBySymbol(currency)).toDouble());
    return Pair("${aggregatedUserBalance.toVisibleAmount().toStringAsFixed(tokens[token]?.fixedDecimal ?? 2)} ${tokens[token]?.symbol}", "${getCurrencySymbol(currency)} $formattedFiat");
  }

  Pair<String, String> parseSingleTokenBalanceForUi(Token token,
      Blockchain blockchain,
      List<UserTokenData> useTokenDataList,
      double tokenPrice,
      CurrencyType currency) {
    final aggregatedUserBalance = useTokenDataList.where((item) => item.blockchain == blockchain).reduce((prev, curr) {
      return UserTokenData(
        token: prev.token,
        blockchain: prev.blockchain,
        decimal: prev.decimal,
        address: "",
        amount: prev.amount + curr.amount,
      );
    });
    final formatter = NumberFormat.decimalPattern('en_US');
    final fiat = aggregatedUserBalance.toVisibleAmount() * tokenPrice;
    final formattedFiat = formatter.format(fiat.toStringAsFixed(getFixedDigitBySymbol(currency)).toDouble());
    return Pair("${aggregatedUserBalance.toVisibleAmount().toStringAsFixed(tokens[token]?.fixedDecimal ?? 2)} ${tokens[token]?.symbol}", "${getCurrencySymbol(currency)} $formattedFiat");
  }

  Future<Pair<String, String>> getUiTokenBalance(Token token, CurrencyType currency) async {
    logger.d('getUiTokenBalance, token=$token, currencyType=$currency');
    final tokenPriceData = await getTokenPriceUseCase.getSingleTokenPrice(token, currency);
    final userBalanceData = await getTokenDataList(token);
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
    final key = await keySerivce.getKey();
    final userBalanceData = await getTokenDataList(token);
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