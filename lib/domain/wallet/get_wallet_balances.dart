import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
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
    required this.keyService,
    required this.calculator,
    required this.settingsPreference
  });
  final GetWalletAddress getWalletAddressUseCase;
  final GetTokenPrice getTokenPriceUseCase;
  final SettingsPreference settingsPreference;
  final Calculator calculator;

  final WalletBalancesRepository repository;
  final KeyService keyService;
  final isLoading = false.obs;

  final RxBool needUpdate = false.obs;

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