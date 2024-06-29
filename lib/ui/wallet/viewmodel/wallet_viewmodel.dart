import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/type/balance.dart';
import 'package:surfy_mobile_app/ui/wallet/wallet_view.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletViewModel {

  late WalletPageInterface listener;

  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetWalletAddress _getWalletAddressUseCase = Get.find();
  final GetTokenPrice _getTokenPrice = Get.find();
  final SettingsPreference _preference = Get.find();

  Rx<List<Balance>> balances = Rx([]);
  Rx<Map<Token, TokenPrice>> prices = Rx({});

  void setListener(WalletPageInterface item) {
    listener = item;
  }

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    var startTime = DateTime.now().millisecondsSinceEpoch;
    listener.onLoading();

    final getBalanceJobList = Token.values.map((token) async {
      final networks = tokens[token]?.supportedBlockchain;
      final balanceList = networks?.map((network) async {
        final address = await _getWalletAddressUseCase.getAddress(network);
        final balance = await _getWalletBalancesUseCase.getBalanceFromRemote(token, network, address);
        return Balance(
          token: token,
          blockchain: network,
          balance: balance
        );
      }).toList() ?? [];

      return await Future.wait(balanceList);
    }).toList();

    final balanceList = (await Future.wait(getBalanceJobList)).expand((e) => e);
    balances.value = [];
    for (var balance in balanceList) {
      balances.value.add(balance);
    }

    final tokenPrices = await _getTokenPrice.getTokenPrice(Token.values, _preference.userCurrencyType.value);
    prices.value = tokenPrices;

    listener.offLoading();
  }
}