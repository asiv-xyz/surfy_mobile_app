import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/ui/type/balance.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

import '../../settings/settings_preference.dart';

class GetWalletBalances {
  GetWalletBalances({
    required this.repository,
    required this.getWalletAddressUseCase,
    required this.getTokenPriceUseCase,
    required this.keySerivce,
    required this.calculator,
  });
  final GetWalletAddress getWalletAddressUseCase;
  final GetTokenPrice getTokenPriceUseCase;
  final Calculator calculator;

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

  // refactoring
  Future<BigInt> getBalance(Token token, Blockchain blockchain, String address) async {
    return await repository.getBalance(token,
        blockchain,
        address,
    );
  }

  Future<BigInt> getBalanceFromRemote(Token token, Blockchain blockchain, String address) async {
    return await repository.getBalance(token,
      blockchain,
      address,
    );
  }

  Future<List<FiatBalance>> getBalancesByDesc(List<Pair<Token, Blockchain>> args, CurrencyType currency) async {
    final job = args.map((pair) async {
      final address = await getWalletAddressUseCase.getAddress(pair.second);
      final balance = await getBalance(pair.first, pair.second, address);
      final tokenPrice = await getTokenPriceUseCase.getSingleTokenPrice(pair.first, currency);
      final prettyBalance = calculator.cryptoToDouble(pair.first, balance);
      final fiat = prettyBalance * (tokenPrice?.price ?? 0);
      return FiatBalance(token: pair.first, blockchain: pair.second, balance: fiat, cryptoBalance: balance, currencyType: currency);
    });

    final balances = await Future.wait(job);
    balances.sort((a, b) {
      if (a.balance < b.balance) {
        return 1;
      } else if (a.balance == b.balance) {
        return 0;
      } else {
        return -1;
      }
    });

    return balances;
  }
}